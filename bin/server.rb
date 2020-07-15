#!/usr/bin/env ruby

require 'webrick'

class Server < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    puts(req.path)
    if %w[/valid_dir /invalid^directory /another_valid_dir /.valid_file].include?(req.path)
      res.status = [200, 301, 302].sample
    else
      res.status = [501, 404].sample
    end
  end
end

sv = WEBrick::HTTPServer.new(:Port => 8080)
sv.mount('/', Server)

sv.start