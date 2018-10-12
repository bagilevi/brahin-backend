class GitSync::RepoActor < Concurrency::Actor
  delegate :logger, to: GitSync

  attr_reader :git_op

  def initialize
    @git_op = GitSync::Sync.new
    @pull_scheduler = set_up_pull_scheduler if ENV['GIT_POLL']
    @save_debouncer = set_up_save_debouncer
    super(self.class.name)
  end

  def join
    super
    @pull_scheduler.join if @pull_scheduler.present?
  end

  def initial_sync
    self << :initial_sync
  end

  def pull
    self << :pull
  end

  def save
    self << :save
  end

  def on_messages(messages)
    logger.info "RepoActor: incoming messages: #{messages.inspect}"
    messages.uniq.each do |message|
      case message
      when :initial_sync then git_op.initial_sync
      when :pull then pull_and_reschedule
      when :save then debounced_save
      when :scheduled_pull then pull_and_reschedule
      else raise "Unrecognized message: #{message.inspect}"
      end
    end
  end

  private

  def set_up_pull_scheduler
    require_relative './pull_scheduler'
    GitSync::PullScheduler.new do
      self << :scheduled_pull
    end
  end

  def pull_and_reschedule
    result = git_op.pull

    return if @pull_scheduler.blank?
    if result[:already_up_to_date]
      @pull_scheduler.extend_frequency
    else
      @pull_scheduler.reset_frequency
    end
  end

  def set_up_save_debouncer
    require_relative './save_debouncer'
    GitSync::SaveDebouncer.new do
      git_op.save
    end
  end

  def debounced_save
    @save_debouncer.make_dirty
  end
end
