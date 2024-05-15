# frozen_string_literal: true

require 'mongoid'

MONGO_CONFIG = YAML.load_file('/app/config/mongoid.yml')

Mongoid.configure do |config|
  config.clients.default = {
    hosts: MONGO_CONFIG['hosts'],
    database: MONGO_CONFIG['database']
  }
  config.log_level = MONGO_CONFIG['log_level']
end
