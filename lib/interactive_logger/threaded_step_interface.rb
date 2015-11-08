require 'thread'

class InteractiveLogger
  # A interface-match for Step, but used simply to communicate with the main
  # thread, which actually manipulates the Step.
  class ThreadedStepInterface
    def initialize(queue)
      @queue = queue
    end

    def continue(str = nil)
      @queue.push([:continue, str])
    end

    def failure(str = nil)
      @queue.push([:failure, str])
    end

    def success(str = nil)
      @queue.push([:success, str])
    end
  end
end
