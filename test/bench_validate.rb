require File.expand_path('../test_helper', __FILE__)
require 'minitest/benchmark'

class ValidateBenchmark < Minitest::Benchmark

  def bench_pattern_property_type
    schema = {
      'type' => 'object',
      'patternProperties' => {
        '^b' => {
          'type' => 'boolean'
        },
        '^n' => {
          'type' => 'number'
        },
        '^s' => {
          'type' => 'string'
        }
      }
    }

    test_data = Minitest::Benchmark.bench_range.each_with_object({}) do |properties, hsh|
      data = {}
      properties.times do |i|
        case rand(3)
        when 0 then
          data["b_#{i}"] = i.odd? # boolean
        when 1 then
          data["n_#{i}"] = i # number
        when 2 then
          data["s_#{i}"] = i.to_s # string
        end
      end
      hsh[properties] = data
    end

    assert_performance_constant do |properties|
      assert_valid schema, test_data.fetch(properties)
    end
  end

  def bench_array_type
    schema = {
      'type' => 'object',
      'properties' => {
        'test_array' => {
          'type' => 'array',
          'items' => {
            'type' => 'number'
          }
        }
      }
    }

    test_data = Minitest::Benchmark.bench_range.each_with_object({}) do |length, hsh|
      hsh[length] = { 'test_array' => length.times.map { rand(10e12) } }
    end

    assert_performance_constant do |length|
      assert_valid schema, test_data.fetch(length)
    end
  end

  def bench_schema_any_of_array
    schema = {
      'type' => 'object',
      'properties' => {
        'test_array' => {
          'type' => 'array',
          'items' => {
            'anyOf' => [
              {
                'type' => 'number'
              },
              {
                'type' => 'string'
              }
            ]
          }
        }
      }
    }

    test_data = Minitest::Benchmark.bench_range.each_with_object({}) do |length, hsh|
      hsh[length] = { 'test_array' => length.times.map { |i| rand(2) == 0 ? i : i.to_s } }
    end

    assert_performance_constant do |properties|
      assert_valid schema, test_data.fetch(properties)
    end
  end

  def bench_ref_array
    schema = schema_fixture_path('address_microformat_array.json')

    test_data = Minitest::Benchmark.bench_range.each_with_object({}) do |length, hsh|
      hsh[length] = length.times.map do
        {
          'street-address' => '1600 Pennsylvania Avenue Northwest',
          'locality' => 'Washington',
          'region' => 'DC',
          'postal-code' => '20500',
          'country-name' => 'USA'
        }
      end
    end

    assert_performance_constant do |length|
      assert_valid schema, test_data.fetch(length)
    end
  end
end
