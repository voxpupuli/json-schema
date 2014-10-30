require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../support/type_validation_tests', __FILE__)

class TestTypeValidationDraft1 < MiniTest::Unit::TestCase
  include TypeValidationTests
  include SchemaUnionTypeValidationTests
  include AnyTypeValidationTests

  def schema_version
    :draft1
  end
end

class TestTypeValidationDraft2 < MiniTest::Unit::TestCase
  include TypeValidationTests
  include SchemaUnionTypeValidationTests
  include AnyTypeValidationTests

  def schema_version
    :draft2
  end
end

class TestTypeValidationDraft3 < MiniTest::Unit::TestCase
  include TypeValidationTests
  include SchemaUnionTypeValidationTests
  include AnyTypeValidationTests

  def schema_version
    :draft3
  end
end

class TestTypeValidationDraft4 < MiniTest::Unit::TestCase
  include TypeValidationTests
  # `type` is more constrainted in draft4:
  # neither `any` nor schemas are supported values

  def schema_version
    :draft4
  end
end
