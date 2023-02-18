module StringValidation
  module ValueTests
    def test_minlength
      schema = {
        'properties' => {
          'a' => { 'minLength' => 1 },
        },
      }

      assert_valid schema, { 'a' => 't' }
      refute_valid schema, { 'a' => '' }

      # other types are disregarded
      assert_valid schema, { 'a' => 5 }
    end

    def test_maxlength
      schema = {
        'properties' => {
          'a' => { 'maxLength' => 2 },
        },
      }

      assert_valid schema, { 'a' => 'tt' }
      assert_valid schema, { 'a' => '' }
      refute_valid schema, { 'a' => 'ttt' }

      # other types are disregarded
      assert_valid schema, { 'a' => 5 }
    end

    def test_pattern
      schema = {
        'properties' => {
          'a' => { 'pattern' => '\\d+ taco' },
        },
      }

      assert_valid schema, { 'a' => '156 taco bell' }
      refute_valid schema, { 'a' => 'x taco' }

      # other types are disregarded
      assert_valid schema, { 'a' => 5 }
    end
  end

  module FormatTests
    # Draft1..3 use the format name `ip-address`; draft4 changed it to `ipv4`.
    def ipv4_format
      'ip-address'
    end

    def test_format_unknown
      schema = {
        'properties' => {
          'a' => { 'format' => 'unknown' },
        },
      }

      assert_valid schema, { 'a' => 'absolutely anything!' }
      assert_valid schema, { 'a' => '' }
    end

    def test_format_union
      schema = {
        'properties' => {
          'a' => {
            'type' => %w[string null],
            'format' => 'date-time',
          },
        },
      }

      assert_valid schema, { 'a' => nil }
      refute_valid schema, { 'a' => 'wrong' }
    end

    def test_format_ipv4
      schema = {
        'properties' => {
          'a' => { 'format' => ipv4_format },
        },
      }

      assert_valid schema, { 'a' => '1.1.1.1' }
      refute_valid schema, { 'a' => '1.1.1' }
      refute_valid schema, { 'a' => '1.1.1.300' }
      refute_valid schema, { 'a' => '1.1.1' }
      refute_valid schema, { 'a' => '1.1.1.1b' }

      # other types are disregarded
      assert_valid schema, { 'a' => 5 }
    end

    def test_format_ipv6
      schema = {
        'properties' => {
          'a' => { 'format' => 'ipv6' },
        },
      }

      assert_valid schema, { 'a' => '1111:2222:8888:9999:aaaa:cccc:eeee:ffff' }
      assert_valid schema, { 'a' => '1111:0:8888:0:0:0:eeee:ffff' }
      assert_valid schema, { 'a' => '1111:2222:8888::eeee:ffff' }
      assert_valid schema, { 'a' => '::1' }

      refute_valid schema, { 'a' => '1111:2222:8888:99999:aaaa:cccc:eeee:ffff' }
      refute_valid schema, { 'a' => '1111:2222:8888:9999:aaaa:cccc:eeee:gggg' }
      refute_valid schema, { 'a' => '1111:2222::9999::cccc:eeee:ffff' }
      refute_valid schema, { 'a' => '1111:2222:8888:9999:aaaa:cccc:eeee:ffff:bbbb' }
      refute_valid schema, { 'a' => '42' }
      refute_valid schema, { 'a' => 'b' }
    end
  end

  # Draft1..3 explicitly support `date`, `time` formats in addition to
  # the `date-time` format.
  module DateAndTimeFormatTests
    def test_format_time
      schema = {
        'properties' => {
          'a' => { 'format' => 'time' },
        },
      }

      assert_valid schema, { 'a' => '12:00:00' }
      refute_valid schema, { 'a' => '12:00' }
      refute_valid schema, { 'a' => '12:00:60' }
      refute_valid schema, { 'a' => '12:60:00' }
      refute_valid schema, { 'a' => '24:00:00' }
      refute_valid schema, { 'a' => '0:00:00' }
      refute_valid schema, { 'a' => '-12:00:00' }
      refute_valid schema, { 'a' => '12:00:00b' }
      assert_valid schema, { 'a' => '12:00:00' }
      refute_valid schema, { 'a' => "12:00:00\nabc" }
    end

    def test_format_date
      schema = {
        'properties' => {
          'a' => { 'format' => 'date' },
        },
      }

      assert_valid schema, { 'a' => '2010-01-01' }
      refute_valid schema, { 'a' => '2010-01-32' }
      refute_valid schema, { 'a' => 'n2010-01-01' }
      refute_valid schema, { 'a' => '2010-1-01' }
      refute_valid schema, { 'a' => '2010-01-1' }
      refute_valid schema, { 'a' => '2010-01-01n' }
      refute_valid schema, { 'a' => "2010-01-01\nabc" }
    end
  end
end
