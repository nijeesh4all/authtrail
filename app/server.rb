require 'sinatra'
require 'rabl'

require_relative '../config/mongoid'
require_relative './models/audit_event.rb'

require_relative './presentor/audit_events_presentor'

set :port, 4000
set :bind, '0.0.0.0'
set :views, Proc.new { File.join(root, "views") }


DEFAULT_PAGE_SIZE = 10

Rabl.register!

get '/audit_events' do

  content_type :json

  presenter = AuditEventPresenter.new(params)

  @audit_events = presenter.paginated_events
  @total_count = presenter.total_count
  @meta = presenter.meta_data

  rabl :index
end
