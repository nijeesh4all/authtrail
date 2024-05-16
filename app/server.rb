require 'sinatra'
require 'rabl'
require 'pry'

require_relative '../config/mongoid'
require_relative './models/audit_event.rb'

set :port, 4000
set :bind, '0.0.0.0'
set :views, Proc.new { File.join(root, "views") }


DEFAULT_PAGE_SIZE = 10

Rabl.register!

get '/' do
  content_type :json
  page = params[:page].to_i || 1
  page = 1 if page <= 0  # Ensure page is always positive

  skip = (page - 1) * DEFAULT_PAGE_SIZE

  @audit_events = AuditEvent.all.skip(skip).limit(DEFAULT_PAGE_SIZE)
  total_count = AuditEvent.count

  @meta = {
    current_page: page,
    total_pages: (total_count / DEFAULT_PAGE_SIZE.to_f).ceil,
    per_page: DEFAULT_PAGE_SIZE,
    total_count: total_count
  }

  rabl :index
end
