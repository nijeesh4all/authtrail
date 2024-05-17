require_relative '../models/audit_event'
require_relative '../transformers/event_transformer'

class AuditEventsConsumer < ApplicationConsumer
  # Flush every 1000 messages
  MAX_BUFFER_SIZE = 20

  def initialize
    super
    @buffer = []
    @transformer = EventTransformer.new(
      whitelist: %w[id timestamp user_id company_id event_type event_data external_event_id],
      renames: { 'id' => 'external_event_id' }
    )
  end

  def consume
    @buffer += messages.payloads.map { |payload| @transformer.transform(payload) }

    return if @buffer.size < MAX_BUFFER_SIZE

    flush
  end

  private

  def flush
    Karafka.logger.info "Flushing buffer with #{MAX_BUFFER_SIZE} messages"

    ::AuditEvent.create!(@buffer)

    mark_as_consumed messages.last

    @buffer.clear
  end
end
