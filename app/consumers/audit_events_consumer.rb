require_relative '../models/audit_event'

class AuditEventsConsumer < ApplicationConsumer
  # Flush every 1000 messages
  MAX_BUFFER_SIZE = 20

  def initialize
    super
    @buffer = []
  end

  def consume
    @buffer += messages.payloads

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
