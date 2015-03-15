# Changes in json-schema 3.0

* From now on, all data and schemas given are expected to be hashes having string keys.
  Data will not be parsed or read from an URI anymore.
* Support for `multi_json` and `yajl-ruby` have been dropped; the standard `json` library,
  available on all common Ruby implementations, is always used.
* Support for Ruby 1.8 has been removed; a Ruby 1.9+ compatible runtime is now required.
