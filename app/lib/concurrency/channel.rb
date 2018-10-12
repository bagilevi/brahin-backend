module Concurrency
  class Channel
    def initialize
      @queue = []
      @mutex = Mutex.new
    end

    def <<(*messages)
      @mutex.synchronize do
        @queue.concat(messages)
      end
    end

    def receive
      @mutex.synchronize do
        @queue.shift
      end
    end

    def receive_all
      @mutex.synchronize do
        messages = @queue
        @queue = []
        messages
      end
    end

    def info
      @mutex.synchronize do
        @queue.size
      end
    end
  end
end
