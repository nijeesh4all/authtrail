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
end
