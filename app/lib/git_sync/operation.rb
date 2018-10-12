require_relative 'git_interface'

# A single synchronous operation on the Git working directory.
# Only one instance should exist at any one time for a single working directory.
class GitSync::Operation
  extend Memoist

  delegate :logger, to: GitSync
  delegate :command, :allow_unrelated_histories, to: :"GitSync::GitInterface.instance"

  attr_reader :work_dir

  def initialize(work_dir)
    @work_dir = work_dir
  end

  def initial_sync
    logger.info "Git: initial_sync"
    init_repo if not_a_repo?
    set_origin if no_origin?
    command('git config user.email || git config user.email "brahin@example.com"')
    command('git config user.name || git config user.name "Brahin"')
    pull
  end

  def init_repo
    logger.info "Git: init workdir"
    command('git init .')
  end

  def set_origin
    logger.info "Git: set origin"
    remote_url = ENV['GIT_SYNC_REMOTE']
    if remote_url.blank?
      logger.warn "Git: cannot set origin, GIT_SYNC_REMOTE env var missing"
      return
    end
    command("git remote add origin #{remote_url}")
  end

  def save
    return if not_a_repo?
    return if !dirty?

    commit_changes
    push
  end

  def pull
    return if not_a_repo?
    return if no_origin?

    logger.info "Git: pull"
    result = {}

    command('git fetch')
    result.merge! merge_fetch_head_handling_dirty_workdir
    push if result[:dirty]

    result
  end

  def merge_fetch_head_handling_dirty_workdir
    result = {}
    begin
      output = command("git merge origin/master -Xours#{allow_unrelated_histories}")
      result[:already_up_to_date] = output.include?('Already up-to-date.')
      result
    rescue => e
      if e.message.include?('Please commit your changes') || e.message.include?('would be overwritten by merge')
        result[:dirty] = true
        commit_changes
        retry
      end
      if e.message.include?('merge: origin/master - not something we can merge')
        # Empty remote repo => no problem
        result[:empty_remote] = true
        return result
      end
      raise
    end
  end

  private

  def repo?
    File.exist?(Pathname.new(work_dir).join('.git'))
  end

  def not_a_repo?
    !repo?
  end

  def no_origin?
    get_remote_url('origin').blank?
  end

  def dirty?
    command('git status -s').strip.present?
  end
  memoize :dirty?

  def commit_changes
    logger.info "Git: commit"
    command('git add --all -- . && git commit --all --message="Change via Brahin"')
  end

  def push
    logger.info "Git: push"
    command("git push origin master")
  end

  def get_remote_url(remote)
    output = command("git remote get-url #{remote}", return_error: true)
    return nil if output.include?('No such remote')
    return output.strip
  end
end
