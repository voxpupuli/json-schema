require 'json-schema'

RSpec.describe 'Inner schema efficiency' do
  before do
    allow(JSON::Schema).to receive(:new).and_call_original
  end

  let(:number_or_string) {{
    'type' => 'array',
    'items' => {
      'anyOf' => [{'type' => 'number'}, {'type' => 'string'}]
    }
  }}

  specify 'only instantiate inner schemas once' do
    JSON::Validator.validate(number_or_string, [1])

    # main schema + items + anyOfx2
    expect(JSON::Schema).to have_received(:new).exactly(4).times
  end

  specify 'even across multiple items' do
    JSON::Validator.validate(number_or_string, [1, 'a'])
    expect(JSON::Schema).to have_received(:new).exactly(4).times
  end
end
