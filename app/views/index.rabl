child(@audit_events) do
  attributes :id, :external_event_id, :timestamp,:user_id, :company_id, :event_type, :event_data, :event_resource_id, :event_resource_type
end

node(:meta) do
  @meta
end
