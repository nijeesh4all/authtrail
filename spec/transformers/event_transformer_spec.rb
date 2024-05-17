# spec/event_transformer_spec.rb
require 'rspec'
require_relative '../../app/transformers/event_transformer'

RSpec.describe EventTransformer do
  describe '#transform' do
    let(:event) do
      {
        'id' => '123',
        'timestamp' => 1609459200,
        'user_id' => 42,
        'extra_field' => 'value'
      }
    end

    context 'without whitelist or renames' do
      it 'returns the original event' do
        transformer = EventTransformer.new
        expect(transformer.transform(event)).to eq(event)
      end
    end

    context 'with whitelist' do
      it 'includes only whitelisted columns' do
        transformer = EventTransformer.new(whitelist: %w[id timestamp])
        transformed_event = transformer.transform(event)
        expect(transformed_event).to eq({ 'id' => '123', 'timestamp' => 1609459200 })
      end
    end

    context 'with renames' do
      it 'renames the specified columns' do
        transformer = EventTransformer.new(renames: { 'id' => 'external_event_id' })
        transformed_event = transformer.transform(event)
        expect(transformed_event).to eq(
          'external_event_id' => '123',
          'timestamp' => 1609459200,
          'user_id' => 42,
          'extra_field' => 'value'
        )
      end
    end

    context 'with whitelist and renames' do
      it 'includes only whitelisted columns and renames specified columns' do
        transformer = EventTransformer.new(
          whitelist: %w[id timestamp user_id],
          renames: { 'id' => 'external_event_id' }
        )
        transformed_event = transformer.transform(event)
        expect(transformed_event).to eq(
          'external_event_id' => '123',
          'timestamp' => 1609459200,
          'user_id' => 42
        )
      end
    end

    context 'with empty whitelist' do
      it 'returns all columns when whitelist is empty' do
        transformer = EventTransformer.new(whitelist: [])
        transformed_event = transformer.transform(event)
        expect(transformed_event).to eq(event)
      end
    end

    context 'with non-whitelisted columns' do
      it 'excludes non-whitelisted columns' do
        transformer = EventTransformer.new(whitelist: %w[timestamp user_id])
        transformed_event = transformer.transform(event)
        expect(transformed_event).to eq('timestamp' => 1609459200, 'user_id' => 42)
      end
    end

    context 'with non-existing rename keys' do
      it 'keeps the original key if it is not in the renames hash' do
        transformer = EventTransformer.new(renames: { 'non_existing_key' => 'new_key' })
        transformed_event = transformer.transform(event)
        expect(transformed_event).to eq(event)
      end
    end
  end
end
