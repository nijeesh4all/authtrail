class EventTransformer
  def initialize(whitelist: [], renames: {})
    @whitelist = whitelist
    @renames = renames
  end

  def transform(event)
    transformed_event = {}

    event.each do |key, value|
      next unless @whitelist.empty? || @whitelist.include?(key)

      new_key = @renames.fetch(key, key)
      transformed_event[new_key] = value
    end

    transformed_event
  end
end
