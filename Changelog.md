# Changes in json-schema 3.0

* Made travis builds send code coverage data to code climate
* Support for `multi_json` and `yajl-ruby` have been dropped; the standard `json` library,
  available on all common Ruby implementations, is always used.
* Support for Ruby 1.8 has been removed; a Ruby 1.9+ compatible runtime is now required.
