# coding: utf-8
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
      @thor_shell = Thor::Base.shell.new
      print_msg(in_progress_prefix << str)
    end

    def continue(str = nil)
      @pos += 1
      @last_str = str if str
      print_msg(in_progress_prefix << @last_str)
    end

    def failure(str = nil)
      @last_str = str if str
      print_msg(prefix(FAILURE_SYMBOL) << @last_str)
    end

    def success(str = nil)
      @last_str = str if str
      print_msg(prefix(SUCCESS_SYMBOL) << @last_str)
    end

    # Blank out the current line.
    def blank
      print "\r"
      if @last_print_msg
        print ' ' * @last_print_msg.uncolorize.size
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
      str = terminal_trim(str)
      blank
      @last_print_msg = str
      print str
    end

    # Trim string to current terminal width and break at newline so it can be
    # replaced rather than causing the same line to print multiple times.
    def terminal_trim(str)
      terminal_width = @thor_shell.terminal_width
      if str.length > (terminal_width - 18)
        str = "#{str[0..(terminal_width - 22)]}..."
      end
      str.lines.first.chomp
    end
  end
end
