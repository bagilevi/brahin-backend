class GitSync::PullScheduler
  delegate :logger, to: GitSync
  delegate :join, to: :@thread

  def initialize(&block)
    @mutex = Mutex.new
    @interval = minimum_interval
    @callback = block
    reset_thread
  end

  def state!(new_state)
    @mutex.synchronize { @state = new_state }
  end

  def state
    @mutex.synchronize { @state }
  end

  def reset_thread
    state! :stopped
    @thread.kill if @thread
    @thread = Thread.new do
      loop do
        Thread.stop # wait for reschedule call

        state! :scheduled
        interval = @mutex.synchronize { @interval.round }
        logger.debug "PullScheduler: sleep for #{interval} seconds"
        sleep interval

        state! :yielded
        @callback.()
      end
    end
    @thread.abort_on_exception = true
  end

  # Interval used when there was a recent change
  def minimum_interval
    10
  end

  def reset_frequency
    reschedule { minimum_interval * (1 + rand) }
  end

  def extend_frequency
    reschedule { |previous_interval| previous_interval * (1 + rand) }
  end

  def reschedule
    @mutex.synchronize do
      @interval = yield(@interval)
      logger.debug  "Reschedule #{@interval}"
      reset_thread if @state == :scheduled
    end
    @thread.wakeup if @thread.status == 'sleep'
  end
end
