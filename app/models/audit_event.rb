# frozen_string_literal: true

require 'mongoid'


class AuditEvent
  include Mongoid::Document

  field :id, type: String
  field :timestamp, type: Integer
  field :user_id, type: Integer
  field :company_id, type: Integer
  field :event_type, type: String
  field :event_data, type: Hash
  field :external_event_id, type: String

  index({ id: 1 }, unique: true)
  index({ user_id: 1 })
  index({ company_id: 1 })
  index({ event_type: 1 })

  # Define scope methods for filtering
  scope :by_timestamp, -> (from, to) { where(timestamp: from..to) }
  scope :by_user_id, -> (user_id) { where(user_id: user_id) }
  scope :by_company_id, -> (company_id) { where(company_id: company_id) }
  scope :by_event_type, -> (event_type) { where(event_type: event_type) }

  # Filtering by event_data requires additional logic
  # Here's an example for matching a specific key-value pair
  scope :by_event_data_key_value, -> (key, value) { where(event_data: { key => value }) }
end
