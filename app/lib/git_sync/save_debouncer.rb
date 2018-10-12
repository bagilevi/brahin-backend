class GitSync::SaveDebouncer
  delegate :join, to: :@thread
  delegate :logger, to: GitSync

  INTERVAL = 30

  def initialize(&block)
    @mutex = Mutex.new
    @callback = block
    reset_thread
  end

  def reset_thread
    @thread = Thread.new do
      loop do
        logger.debug "Debouncer: stop"
        Thread.stop # wait for dirty

        logger.debug "Debouncer: wait"
        wait_for_debounce

        logger.debug "Debouncer: callback"
        @callback.()
      end
    end
    @thread.abort_on_exception = true
  end

  def wait_for_debounce
    loop do
      logger.debug "Debouncer loop"
      delay = @mutex.synchronize do
        @dirtied_time + INTERVAL - Time.current
      end

      # It was dirtied INTERVAL or more seconds ago
      # => quit loop and let the callback run
      return if delay <= 0

      logger.debug "Debouncer sleep: #{delay.round(2)}"
      sleep delay
    end
  end

  def make_dirty
    @mutex.synchronize do
      @dirtied_time = Time.current
    end
    @thread.wakeup if @thread.status == 'sleep'
  end
end
