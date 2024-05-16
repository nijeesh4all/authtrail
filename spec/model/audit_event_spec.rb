require_relative '../spec_helper'

require_relative '../../app/models/audit_event'

require 'mongoid'
require 'mongoid-rspec'
require 'rspec'

describe AuditEvent do
  describe "scopes" do
    before(:each) do
      AuditEvent.create(id: 1, timestamp: 100, user_id: 1, company_id: 1, event_type: "create", event_data: { country: "US" })
      AuditEvent.create(id: 2, timestamp: 200, user_id: 2, company_id: 2, event_type: "update", event_data: { country: "India" })
    end

    it "should filter by timestamp range" do
      events = AuditEvent.by_timestamp(150, 200)
      events.count.should eq(1)
      events.first.id.should eq(2)
    end

    it "should filter by user_id" do
      events = AuditEvent.by_user_id(1)
      events.count.should eq(1)
      events.first.user_id.should eq(1)
    end

    it "should filter by company_id" do
      events = AuditEvent.by_company_id(2)
      events.count.should eq(1)
      events.first.company_id.should eq(2)
    end

    it "should filter by event_type" do
      events = AuditEvent.by_event_type("update")
      events.count.should eq(1)
      events.first.event_type.should eq("update")
    end
  end
end
