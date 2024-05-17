# frozen_string_literal: true

require 'securerandom'
require 'concurrent'
require_relative '../../karafka'
require_relative '../../config/konfig'

# SampleDataProducer is a module used to generate and produce sample data to the 'audit_events' Kafka topic.
# The data is random and is intended to simulate real-world scenarios for testing purposes.
# It produces messages asynchronously to the Kafka topic.
#
# Example usage:
#   SampleDataProducer.produce_messages(count: 1000)
#
module SampleDataProducer
  module_function

  MAX_USER_ID = 100_000_000
  COMPANY_COUNT = 1000

  TOPIC_CONFIG = Konfig.topic_config['audit_events']

  # Produces a specified number of random messages to the 'audit_events' Kafka topic.
  #
  # @param count [Integer] the number of messages to produce. Default is 1000.
  def produce_messages(count: 1000)
    count.times do
      message = sample_message
      Karafka::App.producer.produce_async(
        topic: TOPIC_CONFIG['topic_name'],
        payload: message.to_json,
        partition: message[:user_id] % TOPIC_CONFIG['partitions']
      )
    end
  end

  # TODO: make it dynamic so it changes with the resource type
  private def event_type_sample
    %w[create update delete moved assigned].sample
  end

  private def resource_id_sample
    rand(1..1000)
  end

  private def resource_type_sample
    ['bug', 'comment'].sample
  end

  private def random_text
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  end

  private def sample_user
    user_id = rand(0..MAX_USER_ID)
    { user_id: user_id, company_id: user_id % COMPANY_COUNT }
  end

  private def id(user)
    "#{user[:company_id]}-#{user[:user_id]}-#{SecureRandom.uuid}"
  end

  # Generates a sample message containing user information, a random event type, and event data.
  #
  # @return [Hash] a hash representing the sample message.
  def sample_message # rubocop:disable Metrics/MethodLength
    user = sample_user
    {
      id: id(user),
      timestamp: Time.now.to_i,

      user_id: user[:user_id],
      company_id: user[:company_id],

      event_type: event_type_sample,

      resource_id: resource_id_sample,
      resource_type: resource_type_sample,

      event_data: {
        title: random_text,
        body: random_text + random_text
      }
    }
  end

end

# Run this file if called directly.
SampleDataProducer.produce_messages(count: 1000) if __FILE__ == $PROGRAM_NAME
