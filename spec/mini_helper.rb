# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require 'active_support'
require 'active_support/core_ext'
require 'active_support/dependencies'
require 'virtus'

ActiveSupport::Dependencies.autoload_paths += %w(
  app/models
  app/lib
)

ROOT_PATH = Pathname.new(File.dirname(__FILE__)).join('..')
