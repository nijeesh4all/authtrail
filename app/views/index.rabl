child(@audit_events) do
  attributes :id, :external_event_id, :timestamp,:user_id, :company_id, :event_type, :event_data
end

node(:meta) do
  @meta
end
