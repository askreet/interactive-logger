# coding: utf-8
require 'colorize'
require 'ruby-duration'

# A logger that shows activity for each step without spamming to stdout.
class InteractiveLogger
  class Step
    PROGRESS_SYMBOLS = %w(- \\ | /)
    FAILURE_SYMBOL = '✗'.red
    SUCCESS_SYMBOL = '✓'.green
    LB = '['.light_black
    RB = ']'.light_black

    def initialize(str, show_time: true)
      @orig_str = str
      @start = Time.now
      @show_time = show_time
      @pos = 0
      print_msg(in_progress_prefix << str)
    end

    def continue(str = nil)
      @pos += 1
      print_msg("\r" << in_progress_prefix << (str || @orig_str))
    end

    def failure(str = nil)
      print_msg("\r" << prefix(FAILURE_SYMBOL) << (str || @orig_str))
    end

    def success(str = nil)
      print_msg("\r" << prefix(SUCCESS_SYMBOL) << (str || @orig_str))
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
      @max_str = [str.uncolorize.size, @max_str || 0].max
      str << ' ' * (@max_str - str.uncolorize.size)
      print str
    end
  end

  # Start a step.
  def start(str)
    yield Step.new(str)
    print "\n"
  end
end
