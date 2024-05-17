# frozen_string_literal: true

require 'mongoid'

# basic class to load configurations
class Konfig
  def self.topic_config
    @topic_config = YAML.load_file('config/topics.yml')
  end
end
