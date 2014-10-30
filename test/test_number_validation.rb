require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../support/number_property_validation_tests', __FILE__)

class TestNumberValidationDraft1 < MiniTest::Unit::TestCase
  include NumberPropertyValidationTests

  def schema_version
    :draft1
  end

  def exclusive_minimum
    { 'minimumCanEqual' => false }
  end

  def exclusive_maximum
    { 'maximumCanEqual' => false }
  end
end

class TestNumberValidationDraft2 < MiniTest::Unit::TestCase
  include NumberPropertyValidationTests

  def schema_version
    :draft2
  end

  def exclusive_minimum
    { 'minimumCanEqual' => false }
  end

  def exclusive_maximum
    { 'maximumCanEqual' => false }
  end
end

class TestNumberValidationDraft3 < MiniTest::Unit::TestCase
  include NumberPropertyValidationTests

  def schema_version
    :draft3
  end

  def exclusive_minimum
    { 'exclusiveMinimum' => true }
  end

  def exclusive_maximum
    { 'exclusiveMaximum' => true }
  end
end

class TestNumberValidationDraft4 < MiniTest::Unit::TestCase
  include NumberPropertyValidationTests

  def schema_version
    :draft4
  end

  def exclusive_minimum
    { 'exclusiveMinimum' => true }
  end

  def exclusive_maximum
    { 'exclusiveMaximum' => true }
  end
end
