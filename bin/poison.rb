#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))

require 'poison'

def init_scanner(opts)
  Poison::Scanner.new do |puf|
    puf.url           = opts[:url]
    puf.port          = opts[:port]
    puf.threads       = opts[:threads] || 1
    puf.user_agent    = opts[:user_agent]
    puf.random_agent  = opts[:random_agent]
    puf.wordlist      = opts[:wordlist] || 'wordlist.txt'
    puf.agents_wlist  = opts[:agents_wlist] || 'user-agents.txt'
  end.start
end

def parse_args(args)
  puf_base = File.basename($0)
  opts = {}
  opt = OptionParser.new
  banner = puf_banner
  banner << "\nUsage: #{puf_base} -u URL [options]\n"
  banner << "Example: #{puf_base} -u http://example.com -t 10 -r\n"
  opt.banner = banner

  opt.separator("\nOptions:")

  opt.on('-u', '--url=URL', 'Target url (required)')
  opt.on('-p', '--port=PORT', 'Port number', Integer)
  opt.on('-t', '--threads=THREADS', 'Threads to create', Integer)
  opt.on('-a', '--user_agent=AGENT', 'Use a user-agent')
  opt.on('-r', '--random_agent', 'Use a random user-agent')
  opt.on('--wordlist=WLIST', 'Use a another wordlist')
  opt.on('--agents_wlist=WLIST', 'Use a another user-agent wordlist')
  opt.on('--verbose', 'Verbose mode')

  opt.on('-v', '--verson', 'Show version') do
    puts(puf_banner)
    exit
  end
  opt.on('-h', '--help', 'Show this message') do
    puts(opt)
    exit
  end

  opt.parse!(args, into: opts)

  unless opts.key?(:url)
    puts(opt)
    perror('Target URL is required') unless opts.empty?
    exit
  end

  opts
rescue OptionParser::InvalidOption => e
  perror("Invalid option: #{e.args[0]}")
rescue OptionParser::MissingArgument => e
  perror("Missing required argument for '#{e.args[0]}' option")
rescue OptionParser::InvalidArgument => e
  perror("Invalid argument for '#{e.args[0]}' option")
rescue StandardError => e
  perror(e.backtrace, "Unexpected error (#{e.message.red})")
end

begin
  opts = parse_args(ARGV)
  # puts(opts)
  init_scanner(opts)
rescue StandardError => e
  $stderr.puts(e.backtrace)
  perror("Unexpected error (#{e.message.red})")
end