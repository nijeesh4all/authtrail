
require 'mongoid-rspec'
require 'rspec'

require_relative '../../app/models/audit_event'
require_relative '../spec_helper'
require_relative '../../app/presentor/audit_events_presentor'

RSpec.describe AuditEventPresenter do
  let(:params) { {} }
  let(:presenter) { described_class.new(params) }

  describe '#paginated_events' do
    context 'when no params are provided' do
      it 'returns default paginated events' do
        audit_event1 = AuditEvent.create(
          timestamp: Time.now.to_i,
          user_id: 1,
          company_id: 1,
          event_type: 'login',
          event_data: { message: 'User logged in' }
        )
        audit_event2 = AuditEvent.create(
          timestamp: Time.now.to_i,
          user_id: 2,
          company_id: 2,
          event_type: 'logout',
          event_data: { message: 'User logged out' }
        )

        expect(presenter.paginated_events).to match_array([audit_event1, audit_event2])
      end
    end
  end

  describe '#total_count' do
    context 'when events are present' do
      it 'returns total count of filtered events' do
        AuditEvent.create(
          timestamp: Time.now.to_i,
          user_id: 1,
          company_id: 1,
          event_type: 'login',
          event_data: { message: 'User logged in' }
        )
        AuditEvent.create(
          timestamp: Time.now.to_i,
          user_id: 2,
          company_id: 2,
          event_type: 'logout',
          event_data: { message: 'User logged out' }
        )

        expect(presenter.total_count).to eq(2)
      end
    end
  end

  describe '#meta_data' do
    context 'when no params are provided' do
      it 'returns meta data with default values' do
        expect(presenter.meta_data).to eq({
          current_page: 1,
          total_pages: 0,
          per_page: 10,
          total_count: 0
        })
      end
    end
  end


end
