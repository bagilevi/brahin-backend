require_relative 'operation'

class GitSync::Worker
  attr_reader :repo_actor

  delegate :redis, :logger, to: GitSync

  def initialize
    @repo_actor = GitSync::RepoActor.new
  end

  def run
    @channels_left_to_subscribe = channels.dup
    subscribe
  rescue Redis::BaseConnectionError => error
    logger.error "#{error}, retrying in 1s"
    sleep 1
    retry
  end

  def channels
    [
      GitSync::SAVE_CHANNEL,
      GitSync::PULL_CHANNEL,
    ]
  end

  def subscribe
    redis.subscribe(*channels) do |on|
      on.subscribe(&method(:handle_subscribed))
      on.message(&method(:handle_message))
    end
  end

  def handle_subscribed(channel, message)
    @channels_left_to_subscribe.delete(channel)
    initial_sync if @channels_left_to_subscribe.empty?
  end

  def initial_sync
    repo_actor.initial_sync
  end

  def handle_message(channel, message)
    logger.info "Message received: #{channel} #{message}"
    case channel
    when GitSync::PULL_CHANNEL then repo_actor.pull
    when GitSync::SAVE_CHANNEL then repo_actor.save
    else raise "Invalid channel #{channel.inspect}"
    end
    logger.debug "Message processed."
  end
end
