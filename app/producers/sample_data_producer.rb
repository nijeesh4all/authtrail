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
      event_data: {
        ip: sample_ip,
        country: country_sample
      }
    }
  end

  private
  
  # Returns a random event type from a predefined list of possible event types.
  #
  # @return [String] a random event type.
  def event_type_sample
    %w[user_login user_logout user_create user_delete user_update user_captcha_success user_captcha_failed
       user_login_failed].sample
  end

  # Returns a random country from a predefined list of possible countries.
  #
  # @return [String] a random country.
  def country_sample # rubocop:disable Metrics/MethodLength
    [
      'United States',
      'Canada',
      'Mexico',
      'Brazil',
      'Argentina',
      'United Kingdom',
      'Germany',
      'France',
      'Italy',
      'Spain',
      'Russia',
      'China',
      'Japan',
      'India'
    ].sample
  end

  # Generates a sample user with a random user ID and assigns a company ID based on the user ID.
  #
  # @return [Hash] a hash containing the user_id and company_id.
  def sample_user
    user_id = rand(0..MAX_USER_ID)
    { user_id: user_id, company_id: user_id % COMPANY_COUNT }
  end

  # Generates a random IP address in the range 192.168.x.x.
  #
  # @return [String] a random IP address.
  def sample_ip
    "192.168.#{(1...255).to_a.sample}.#{(1...255).to_a.sample}"
  end

  # Generates a unique event ID using the company ID, user ID, and a random UUID.
  #
  # @param user [Hash] a hash containing the user_id and company_id.
  # @return [String] a unique event ID.
  def id(user)
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
      event_data: {
        ip: sample_ip,
        country: country_sample
      }
    }
  end
end

# Run this file if called directly.
SampleDataProducer.produce_messages(count: 1000) if __FILE__ == $PROGRAM_NAME
