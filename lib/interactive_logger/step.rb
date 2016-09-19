# coding: utf-8
require 'io/console'

class InteractiveLogger
  class Step
    PROGRESS_SYMBOLS = %w(- \\ | /)
    FAILURE_SYMBOL = '✗'.red
    SUCCESS_SYMBOL = '✓'.green
    LB = '['.light_black
    RB = ']'.light_black

    def initialize(str, show_time: true)
      @last_str = str
      @start = Time.now
      @show_time = show_time
      @pos = 0
      print_trimmed(in_progress_prefix << str)
    end

    def continue(str = nil)
      @pos += 1
      blank
      @last_str = str if str
      print_trimmed(in_progress_prefix << @last_str)
    end

    def failure(str = nil)
      blank
      @last_str = str if str
      print_msg(prefix(FAILURE_SYMBOL) << @last_str)
    end

    def success(str = nil)
      blank
      @last_str = str if str
      print_msg(prefix(SUCCESS_SYMBOL) << @last_str)
    end

    # Blank out the current line.
    def blank
      print "\r"
      if @last_print_msg
        print ' ' * IO.console.winsize[1]
      end
      print "\r"
    end

    def repaint
      print @last_print_msg
    end

    private

    def in_progress_prefix
      prefix(PROGRESS_SYMBOLS[@pos % PROGRESS_SYMBOLS.size].yellow)
    end

    def prefix(str)
      show_time = ''
      if @show_time
        show_time = Duration.new(Time.now.to_i - @start.to_i)
                            .format(" #{LB} %tmm %ss #{RB}")
      end
      "#{LB} #{str} #{RB}#{show_time} "
    end

    def print_msg(str)
      blank
      @last_print_msg = str
      print str
    end

    # Trim string to current terminal width and break at newline so it can be
    # replaced rather than causing the same line to print multiple times.
    #
    # The bulk of this logic is dedicated to counting only printable
    # characters, and ensure we reset the colors afterward.
    def print_trimmed(str)
      terminal_width = IO.console.winsize[1]

      # Take only the first line.
      str = str.lines.first.chomp
      @last_print_msg = ""

      len = 0 # Printable length of characters sent to screen so far.
      pos = 0 # Position in input string buffer.
      c = true # Are we counting characters?

      # Copy characters, including nonprintables, until we have copied
      # terminal_width - 4 printables, then add an elipsis and call it
      # a day.
      loop do
        if str[pos, 2] == "\e["
          @last_print_msg << "\e["
          pos += 2
          c = false
          next
        end

        if c == false && str[pos] == "m"
          @last_print_msg << str[pos]
          pos += 1
          c = true
          next
        end

        # Everything fits, nothing to do.
        if pos == str.size
          break
        end

        # We are going to run out of space, reset color to normal and draw an elipsis.
        if len == terminal_width - 5 && str.size > pos + 3
          @last_print_msg << "\e[0m..."
          break
        end

        @last_print_msg << str[pos]
        len += 1 if c
        pos += 1
      end

      print @last_print_msg
    end
  end
end
