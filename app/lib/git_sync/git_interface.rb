class GitSync::GitInterface
  include Singleton

  delegate :logger, to: GitSync

  def command(cmd, return_error: false)
    logger.info "Git: command: #{cmd.inspect}"
    output = `#{cmd} 2>&1`
    if $?.exitstatus != 0
      if return_error
        logger.info "Git: failure: #{cmd.inspect}: #{$?.exitstatus} #{output.inspect}"
        return output
      end
      logger.error "Git: failure: #{cmd.inspect}: #{$?.exitstatus} #{output.inspect}"
      raise "#{cmd.inspect} returned error:\n#{output}"
    end

    logger.debug "Git: result: #{output.inspect}"
    output
  end

  def allow_unrelated_histories
    " --allow-unrelated-histories" if git_version_at_least?(2, 9, 0)
  end

  def git_version
    @git_version ||= command('git --version').scan(/^git version (\d+)\.(\d+)\.(\d+)/)[0].map(&:to_i)
  end

  def git_version_at_least?(*version_components)
    version_components.each_with_index do |item, i|
      return true if git_version[i] > item
      return false if git_version[i] < item
      # equal => next iteration: one level deeper
    end
    true
  end
end
