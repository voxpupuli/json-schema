require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../support/string_property_validation_tests', __FILE__)

class TestStringValidationDraft1 < MiniTest::Unit::TestCase
  include StringPropertyValidationTests

  def schema_version
    :draft1
  end
end

class TestStringValidationDraft2 < MiniTest::Unit::TestCase
  include StringPropertyValidationTests

  def schema_version
    :draft2
  end
end

class TestStringValidationDraft3 < MiniTest::Unit::TestCase
  include StringPropertyValidationTests

  def schema_version
    :draft3
  end
end

class TestStringValidationDraft4 < MiniTest::Unit::TestCase
  include StringPropertyValidationTests

  def schema_version
    :draft4
  end
end
