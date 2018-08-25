if config_value = ENV['HTTP_BASIC_AUTHENTICATION']
  $auth_config = HttpBasicAuthConfig.new(config_value)
end
