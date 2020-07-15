module Poison
  module Prettyp
    module Colors
      def colorize(text, color_code)
        "#{color_code}#{text}\e[0m"
      end

      def red
        colorize(self, "\e[1m\e[31m")
      end

      def green
        colorize(self, "\e[1m\e[32m")
      end

      def blue
        colorize(self, "\e[1m\e[34m")
      end

      def yellow
        colorize(self, "\e[1m\e[33m")
      end
    end

    module Printer
      # Discriminator variable
      $verbose = false
      def verbose?(verbose)
        yield true if !verbose || $verbose && verbose
      end

      def psuccess(msg, endl: true, verbose: false)
        verbose?(verbose) { print('[+]'.green + " #{msg}#{"\n" if endl}") }
      end

      def pinfo(msg, endl: true, verbose: false)
        verbose?(verbose) { print('[i]'.blue + " #{msg}#{"\n" if endl}") }
      end

      def pwarn(msg, endl: true, verbose: false)
        verbose?(verbose) { print('[!]'.yellow + " #{msg}#{"\n" if endl}") }
      end

      def perror(msg, endl: true, verbose: false, exit_: true)
        verbose?(verbose) do
          print('[-]'.red + " #{msg}#{"\n" if endl}")

          exit if exit_
        end
      end

      ###
      # Utils methods
      ###

      def puf_banner
        fmt_author = "Created by #{'yexploit (yato)'.yellow}"
        fmt_version = "Version: #{Poison::VERSION.yellow}"

        <<~BANNER
                         _                
            ____  ____  (_)________  ____ 
           / __ \\/ __ \\/ / ___/ __ \\/ __ \\
          / /_/ / /_/ / (__  ) /_/ / / / /  #{fmt_author}
         / .___/\\____/_/____/\\____/_/ /_/   #{fmt_version}
        /_/                               
        BANNER
      end
    end
  end
end