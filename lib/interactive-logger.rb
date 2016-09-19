# coding: utf-8
require 'colorize'
require 'ruby-duration'
require 'thread'

# A logger that shows activity for each step without spamming to stdout.
class InteractiveLogger
  require_relative 'interactive_logger/step'
  require_relative 'interactive_logger/threaded_step_interface'

  def initialize(debug: false)
    @debug = debug
    @current_step = nil
    @draw_mutex = Mutex.new
  end

  def debug?; @debug == true end

  # Start a step.
  def start(str)
    @current_step = Step.new(str)
    yield @current_step
    print "\n"
  rescue => e
    @current_step.failure "Error while performing step: #{str}\n  #{e.class}: #{e.message}"
    print "\n"
    raise
  ensure
    @current_step = nil
  end

  # Use a threaded interface, to keep the UI updated even on a long-running
  # process.
  def start_threaded(str)
    @current_step = Step.new(str)
    queue = Queue.new

    Thread.abort_on_exception = true
    child = Thread.new do
      yield ThreadedStepInterface.new(queue)
    end

    loop do
      if queue.empty?
        @draw_mutex.synchronize do
          @current_step.continue # Keep the UI updating regardless of actual process.
        end
      else
        until queue.empty?
          msg = queue.pop

          @draw_mutex.synchronize do
            @current_step.send(msg.shift, *msg)
          end
        end
      end

      break unless child.alive?
      sleep 0.5
    end

    puts
    child.join

    @current_step.nil?
  rescue => e
    @current_step.failure "Error while performing step: #{str}\n  #{e.class}: #{e.message}"
    print "\n"
    raise
  ensure
    @current_step = nil
  end

  # Post a debug message above the current step output, if debugging is enabled.
  def debug(str)
    return unless debug?

    @draw_mutex.synchronize do
      @current_step.blank if @current_step
      print '--> '.yellow
      puts str
      @current_step.repaint if @current_step
    end
  end

  # Post an informative message above the current step output.
  def info(str)
    @draw_mutex.synchronize do
      @current_step.blank if @current_step
      print '--> '.green
      puts str
      @current_step.repaint if @current_step
    end
  end

  # Post an error message above the current step output.
  def error(str)
    @draw_mutex.synchronize do
      @current_step.blank if @current_step
      print '--> '.red
      puts str
      @current_step.repaint if @current_step
    end
  end

  # Post a single message, without any progress tracking.
  def msg(str)
    c = Step.new(str)
    c.success
    print "\n"
  end
end
