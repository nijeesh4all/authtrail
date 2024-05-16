require_relative '../models/audit_event'

class AuditEventPresenter
  def initialize(params)
    @params = params
  end

  def paginated_events
    events = filtered_events
    events.skip((current_page - 1) * per_page).limit(per_page)
  end

  def total_count
    filtered_events.count
  end

  def meta_data
    {
      current_page: current_page,
      total_pages: (total_count / per_page.to_f).ceil,
      per_page: per_page,
      total_count: total_count
    }
  end

  private

  def filtered_events
    events = AuditEvent.all
    @params.each do |attribute, value|
      case attribute
      when 'timestamp_from'
        events = events.by_timestamp(value.to_i, @params['timestamp_to'].to_i)
      when 'user_id', 'company_id'
        events = events.send("by_#{attribute}", value.to_i) if value.present?
      when 'event_type'
        events = events.by_event_type(value) if value.present?
      end
    end
    events
  end

  def current_page
    @params['page'].to_i || 1  # Default to 1 if missing
    page = [@params['page'].to_i, 1].max
  end

  def per_page
    per_page_value = @params['per_page'].to_i
    per_page_value.positive? ? per_page_value : DEFAULT_PAGE_SIZE
  end
end
