require 'shellwords'

module Travis
  class Worker
    module Shell
      module Helpers
        def export(name, value, options = nil)
          execute(*["export #{name}=#{value}", options].compact) if name
        end

        def export_line(line, options = nil)
          execute(*["export #{line}", options].compact) if line
        end


        def chdir(dir)
          execute("mkdir -p #{dir}", :echo => false)
          execute("cd #{dir}")
        end

        def cwd
          evaluate('pwd').to_s.strip
        end

        def file_exists?(filename)
          execute("test -f #{filename}", :echo => false)
        end

        # Executes a command within the ssh shell, returning true or false depending
        # if the command succeded.
        #
        # command - The command to be executed.
        # options - Optional Hash options (default: {}):
        #           :timeout - The max amount of second to wait before aborting the command.
        #           :echo    - true or false if the command should be echod to the log
        #
        # Returns true if the command completed successfully, false if it failed.
        def execute(command, options = {})
          command = timetrap(command, :timeout => timeout(options)) if options[:timeout]
          command = echoize(command) unless options[:echo] == false

          exec(command) { |p, data| buffer << data } == 0
        end

        # Evaluates a command within the ssh shell, returning the command output.
        #
        # command - The command to be evaluated.
        # options - Optional Hash options (default: {}):
        #           :echo - true or false if the command should be echod to the log
        #
        # Returns the output from the command.
        # Raises RuntimeError if the commands exit status is 1
        def evaluate(command, options = {})
          result = ''
          command = echoize(command) if options[:echo]
          status = exec(command) do |p, data|
            result << data
            buffer << data if options[:echo]
          end
          raise("command #{command} failed: #{result}") unless status == 0
          result
        end

        def echo(output)
          buffer << output
        end

        def terminate(message)
          execute("sudo shutdown -n now #{message}")
        end

        # Formats a shell command to be echod and executed by a ssh session.
        #
        # cmd - command to format.
        #
        # Returns the cmd formatted.
        def echoize(cmd, options = {})
          [cmd].flatten.join("\n").split("\n").map do |cmd|
            "echo #{Shellwords.escape("$ #{cmd.gsub(/timetrap (?:-t \d* )?/, '')}")}\n#{cmd}"
          end.join("\n")
        end

        # Formats a shell command to be run within a timetrap.
        #
        # cmd     - command to format.
        # options - Optional Hash options to be used for configuring the timeout. (default: {})
        #           :timeout - The timeout, in seconds, to be used.
        #
        # Returns the cmd formatted.
        def timetrap(cmd, options = {})
          vars, cmd = parse_cmd(cmd)
          opts = options[:timeout] ? "-t #{options[:timeout]}" : nil
          [vars, 'timetrap', opts, cmd].compact.join(' ')
        end

        # Formats a shell command to be echod and executed by a ssh session.
        #
        # cmd - command to format.
        #
        # Returns the cmd formatted.
        def parse_cmd(cmd)
          cmd.match(/^(\S+=\S+ )*(.*)/).to_a[1..-1].map { |token| token.strip if token }
        end

        def timeout(options)
          if options[:timeout].is_a?(Numeric)
            options[:timeout]
          else
            config.timeouts[options[:timeout] || :default]
          end
        end
      end
    end
  end
end
