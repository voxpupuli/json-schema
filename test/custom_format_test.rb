require File.expand_path('support/test_helper', __dir__)

class CustomFormatTest < Minitest::Test
  def setup
    @all_versions = ['draft1', 'draft2', 'draft3', 'draft4', 'draft6', nil]
    @format_proc = lambda { |value| raise JSON::Schema::CustomFormatError, 'must be 42' unless value == '42' }
    @schema_6 = {
      '$schema' => 'http://json-schema.org/draft-06/schema#',
      'properties' => {
        'a' => {
          'type' => 'string',
          'format' => 'custom',
        },
      },
    }
    @schema_4 = @schema_6.clone
    @schema_4['$schema'] = 'http://json-schema.org/draft-04/schema#'
    @schema_3 = @schema_6.clone
    @schema_3['$schema'] = 'http://json-schema.org/draft-03/schema#'
    @schema_2 = @schema_6.clone
    @schema_2['$schema'] = 'http://json-schema.org/draft-02/schema#'
    @schema_1 = @schema_6.clone
    @schema_1['$schema'] = 'http://json-schema.org/draft-01/schema#'
    @default = @schema_6.clone
    @default.delete('$schema')
    @schemas = {
      'draft1' => @schema_1,
      'draft2' => @schema_2,
      'draft3' => @schema_3,
      'draft4' => @schema_4,
      'draft6' => @schema_6,
      nil => @default,
    }
    JSON::Validator.restore_default_formats
  end

  def test_single_registration
    @all_versions.each do |version|
      assert_nil(JSON::Validator.validator_for_name(version).formats['custom'], "Format 'custom' for #{version || 'default'} should be nil")
      JSON::Validator.register_format_validator('custom', @format_proc, [version])

      assert_kind_of(JSON::Schema::CustomFormat, JSON::Validator.validator_for_name(version).formats['custom'], "Format 'custom' should be registered for #{version || 'default'}")
      (@all_versions - [version]).each do |other_version|
        assert_nil(JSON::Validator.validator_for_name(other_version).formats['custom'], "Format 'custom' should still be nil for #{other_version || 'default'}")
      end
      JSON::Validator.deregister_format_validator('custom', [version])

      assert_nil(JSON::Validator.validator_for_name(version).formats['custom'], "Format 'custom' should be deregistered for #{version || 'default'}")
    end
  end

  def test_register_for_all_by_default
    JSON::Validator.register_format_validator('custom', @format_proc)

    @all_versions.each do |version|
      assert_kind_of(JSON::Schema::CustomFormat, JSON::Validator.validator_for_name(version).formats['custom'], "Format 'custom' should be registered for #{version || 'default'}")
    end
    JSON::Validator.restore_default_formats

    @all_versions.each do |version|
      assert_nil(JSON::Validator.validator_for_name(version).formats['custom'], "Format 'custom' should still be nil for #{version || 'default'}")
    end
  end

  def test_multi_registration
    unregistered_version = @all_versions.delete('draft1')
    JSON::Validator.register_format_validator('custom', @format_proc, @all_versions)

    @all_versions.each do |version|
      assert_kind_of(JSON::Schema::CustomFormat, JSON::Validator.validator_for_name(version).formats['custom'], "Format 'custom' should be registered for #{version || 'default'}")
    end
    assert_nil(JSON::Validator.validator_for_name(unregistered_version).formats['custom'], "Format 'custom' should still be nil for #{unregistered_version}")
  end

  def test_format_validation
    @all_versions.each do |version|
      data = {
        'a' => '23',
      }
      schema = @schemas[version]
      prefix = "Validation for '#{version || 'default'}'"

      assert(JSON::Validator.validate(schema, data), "#{prefix} succeeds with no 'custom' format validator registered")

      JSON::Validator.register_format_validator('custom', @format_proc, [version])
      data['a'] = '42'

      assert(JSON::Validator.validate(schema, data), "#{prefix} succeeds with 'custom' format validator and correct data")

      data['a'] = '23'

      assert(!JSON::Validator.validate(schema, data), "#{prefix} fails with 'custom' format validator and wrong data")

      errors = JSON::Validator.fully_validate(schema, data)

      assert_equal(1, errors.count)
      assert_match(%r{The property '#/a' must be 42 in schema}, errors.first, "#{prefix} records format error")

      data['a'] = 23
      errors = JSON::Validator.fully_validate(schema, data)

      assert_equal(1, errors.count)
      assert_match(%r{The property '#/a' of type integer did not match the following type: string}i, errors.first, "#{prefix} records no format error on type mismatch")
    end
  end

  def test_override_default_format
    @all_versions.each do |version|
      data = {
        'a' => '2001:db8:85a3:0:0:8a2e:370:7334',
      }
      schema = @schemas[version]
      schema['properties']['a']['format'] = 'ipv6'
      prefix = "Validation for '#{version || 'default'}'"

      assert(JSON::Validator.validate(schema, data), "#{prefix} succeeds for default format with correct data")

      data['a'] = 'no_ip6_address'

      assert(!JSON::Validator.validate(schema, data), "#{prefix} fails for default format and wrong data")

      data['a'] = '42'
      JSON::Validator.register_format_validator('ipv6', @format_proc, [version])

      assert(JSON::Validator.validate(schema, data), "#{prefix} succeeds with overridden default format and correct data")

      JSON::Validator.deregister_format_validator('ipv6', [version])
      data['a'] = '2001:db8:85a3:0:0:8a2e:370:7334'

      assert(JSON::Validator.validate(schema, data), "#{prefix} restores the default format on deregistration")
    end
  end
end
