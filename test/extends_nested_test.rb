require File.expand_path('../support/test_helper', __FILE__)

class ExtendsNestedTest < Minitest::Test
  ADDITIONAL_PROPERTIES = ['extends_and_additionalProperties_false_schema.json']
  PATTERN_PROPERTIES = ['extends_and_patternProperties_schema.json']

  ALL_SCHEMAS = ADDITIONAL_PROPERTIES + PATTERN_PROPERTIES

  def test_valid_outer
    ALL_SCHEMAS.each do |file|
      path = schema_fixture_path(file)
      assert_valid path, { 'outerC' => true }, {}, 'Outer defn is broken, maybe the outer extends overrode it'
    end
  end

  def test_valid_outer_extended
    ALL_SCHEMAS.each do |file|
      path = schema_fixture_path(file)
      assert_valid path, { 'innerA' => true }, {}, "Extends at the root level isn't working"
    end
  end

  def test_valid_inner
    ALL_SCHEMAS.each do |file|
      path = schema_fixture_path(file)
      assert_valid path, { 'outerB' => [{ 'innerA' => true }] }, {}, "Extends isn't working in the array element defn"
    end
  end

  def test_invalid_inner
    ALL_SCHEMAS.each do |file|
      path = schema_fixture_path(file)
      refute_valid path, { 'outerB' => [{ 'whaaaaat' => true }] }, {}, "Array element defn allowing anything when it should only allow what's in inner.schema"
    end
  end

  def test_invalid_outer
    path = schema_fixture_path(ADDITIONAL_PROPERTIES)
    refute_valid path, { 'whaaaaat' => true }, {}, "Outer defn allowing anything when it shouldn't"
  end
end
