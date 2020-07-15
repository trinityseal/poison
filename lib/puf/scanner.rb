# frozen_string_literal: true

class PUFBadValue < StandardError; end

module Poison
  class Scanner
    def initialize
      @valid_codes = %w[200 204 301 302 400 401 403 405 500]
      @default_agent = 'Poison URL Fuzzer'
      @opts = OpenStruct.new
      yield @opts
    end

    def check_url
      pinfo('Checking target url...', verbose: true)
      @opts.url.gsub!(%r{\/$}, '')

      unless @opts.url =~ %r{^(https?\:\/\/)}

        pwarn("The URL protocol was not identified! Using 'http' by default", verbose: true)
        @opts.url = 'http://' + @opts.url

      end

      url = URI.parse(@opts.url)

      raise(PUFBadValue, 'hostname not found') unless url.host
    rescue URI::Error, PUFBadValue => e
      perror("Invalid target URL (#{e.message.red})")
    end

    def check_port
      pinfo('Checking port number...', verbose: true)
      raise(PUFBadValue, 'not in range') unless @opts.port.positive? && @opts.port <= 655_35
    rescue PUFBadValue => e
      perror("Invalid port number (#{e.message.red})")
    end

    def check_file(file)
      pinfo("Checking #{file} file...", verbose: true)
      f = File.readlines(file).map(&:chomp)

      !f.empty? ? f : raise(PUFBadValue, 'file is empty')
    rescue StandardError, PUFBadValue => e
      perror("Failed to load '#{file}' file (#{e.message.red})")
    end

    def url(path = nil)
      URI.parse("#{@opts.url}#{path}")
    rescue URI::Error => e
      perror("Failed to convert into URI (#{e.message.red})", exit_: false)
    end

    def user_agent
      if @opts.random_agent
        @agents_wlist.sample
      else
        @opts.user_agent || @default_agent
      end
    end

    def threads
      raise(PUFBadValue, 'threads value must be positive') unless @opts.threads.positive?

      @opts.threads
    rescue PUFBadValue => e
      perror("Threads error (#{e.message.red})")
    end

    def headers
      { 'User-Agent' => user_agent }
    end

    def http_code(path = nil)
      url = url(path)
      return 'Invalid URI' if url.nil?

      port = @opts.port || url.port
      http = Net::HTTP.new(url.hostname, port)
      http.use_ssl = (url.scheme == 'https')
      code = http.get(url, headers).code

      yield code, url
    rescue StandardError => e
      perror("Unexpected error (#{e.message.red})", exit_: false)
    end

    def valid_code?(code)
      @valid_codes.include?(code)
    end

    def info_panel
      panel = <<~PANEL
      Target:     #{url}
      Port:       #{@opts.port || 'Automatic'}
      Threads:    #{threads}
      User-Agent: #{@opts.random_agent ? 'Random' : (@opts.user_agent || @default_agent)}
      PANEL
      puts('-' * 35)
      panel.split(/\n/).each { |msg| pinfo(msg) }
      puts('-' * 35)
    end

    def init_all
      check_url
      check_port if @opts.port

      info_panel

      @wordlist = check_file(@opts.wordlist)
      @agents_wlist = check_file(@opts.agents_wlist) if @opts.random_agent
    end

    def start
      init_all

      @wordlist.peach(threads) do |path, idx|
        path = '/' + path unless path[0] == '/'

        http_code(path) do |code, url|
          if valid_code?(code)
            psuccess('[FOUND]'.green + " (#{code}) #{url}")

          else
            pinfo("(#{code.red}) Scanning: \e[K#{path}\r", endl: false)
          end
          $stdout.flush
        end
      end

      psuccess('Poison scan finished successful...')
    end
  end
end