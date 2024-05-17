# EventTransformer is responsible for transforming event data before it is saved to the database.
# It allows whitelisting of specific columns and renaming of columns according to the provided mappings.
#
# Example:
#   transformer = EventTransformer.new(
#     whitelist: %w[id timestamp user_id],
#     renames: { 'id' => 'external_event_id' }
#   )
#
#   event = { 'id' => '123', 'timestamp' => 1609459200, 'user_id' => 42, 'extra_field' => 'value' }
#   transformed_event = transformer.transform(event)
#   # => { 'external_event_id' => '123', 'timestamp' => 1609459200, 'user_id' => 42 }
#
class EventTransformer
  # Initializes a new EventTransformer.
  #
  # @param whitelist [Array<String>] the list of column names to include in the transformation.
  #   If empty, all columns are included.
  # @param renames [Hash<String, String>] a hash where keys are original column names and values
  #   are the new column names.
  def initialize(whitelist: [], renames: {})
    @whitelist = whitelist
    @renames = renames
  end

  # Transforms the given event according to the whitelist and rename mappings.
  #
  # @param event [Hash<String, Object>] the event data to transform.
  # @return [Hash<String, Object>] the transformed event data.
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
