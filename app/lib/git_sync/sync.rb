# Synchrinization logic to coordinate individual operations for a git working
# directory.
class GitSync::Sync
  delegate :logger, to: GitSync

  def initialize(work_dir = GitSync.work_dir)
    @work_dir = work_dir
    logger.info "GitSync work_dir: #{work_dir}"
    FileUtils.mkdir_p(work_dir)
    Dir.chdir(work_dir)
  end

  def initial_sync
    GitSync::Operation.new(@work_dir).initial_sync
  end

  def pull
    GitSync::Operation.new(@work_dir).pull
  end

  def save
    GitSync::Operation.new(@work_dir).save
  end

  private

  attr_reader :work_dir
end
