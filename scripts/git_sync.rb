$stdout.sync = true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:git_sync_worker)

require 'active_support'
require 'active_support/core_ext'
ActiveSupport::Dependencies.autoload_paths << 'app/lib'

trap(:INT) { puts; exit }

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

GitSync::Worker.new.run
