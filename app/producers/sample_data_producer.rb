# frozen_string_literal: true

require 'securerandom'
require 'concurrent'
require_relative '../../karafka'
require_relative '../../config/konfig'

# this module is used to produce sample data to the audit_events topic
# the data is random and is used to simulate real world data
# pushes to the kafka topic
module SampleDataProducer
  module_function

  MAX_USER_ID = 100_000_000
  COMPANY_COUNT = 1000

  TOPIC_CONFIG = Konfig.topic_config['audit_events']

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

  def event_type_sample
    %w[user_login user_logout user_create user_delete user_update user_captcha_success user_captcha_failed
       user_login_failed].sample
  end

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

  # as this is sample data just a small hack to make sure the users are consistently assigned to the same company
  def sample_user
    user_id = rand(0..MAX_USER_ID)
    { user_id: user_id, company_id: user_id % COMPANY_COUNT }
  end

  def sample_ip
    "192.168.#{(1...255).to_a.sample}.#{(1...255).to_a.sample}"
  end

  def id(user)
    "#{user[:company_id]}-#{user[:user_id]}-#{SecureRandom.uuid}"
  end

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

# run this file if called directly
SampleDataProducer.produce_messages(count: 1000) if __FILE__ == $PROGRAM_NAME
