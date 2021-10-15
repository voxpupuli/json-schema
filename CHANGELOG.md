# Change Log
All notable changes to this project will be documented in this file.
Please keep to the changelog format described on [keepachangelog.com](http://keepachangelog.com).
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.8.1] - 2018-10-14

### Changed
- All limit classes are now stored in their own files in 'json-schema/attributes/limits'
- All attribute classes are now stored in their own files in 'json-schema/attributes'

### Fixed
- Corrected the draft6 schema id to `http://json-schema.org/draft/schema#`
- Rescue URI error when initializing a data string that contains a colon
- Fragments with an odd number of components no longer raise an `undefined method `validate'`
  error
- Made strict validation report errors for draft1 and draft2 schemas

## [2.8.0] - 2017-02-07

### Added
- Ruby 2.4 support

### Changed
- Made the `:clear_cache` option for `validate` also clear the URI parse cache
- Moved `JSON::Validator.absolutize_ref` and the ref manipulating code in
  `JSON::Schema::RefAttribute` into `JSON::Util::URI`
- Made validation errors refer to json schema types not ruby types

### Deprecated
- `JSON::Validator#validator_for` in favor of `JSON::Validator#validator_for_uri`
- `JSON::Validator.validate2` in favor of `JSON::Validator.validate!`
- `JSON::Schema::Validator#extend_schema_definition` in favour of subclassing

## [2.7.0] - 2016-09-29

### Fixed
- Made sure we really do clear the cache when instructed to
- It's now possible to use reserved words in property names
- Removed support for setting "extends" to a string (it's invalid json-schema - use a "$ref" instead)
- Relaxed 'items' and 'allowedItems' validation to permit arrays to pass even
  when they contain fewer elements than the 'items' array.  To require full tuples,
  use 'minItems'.

### Changed
- Made all `validate*` methods on `JSON::Validator` ultimately call `validate!`
- Updated addressable dependency to 2.4.0
- Attached failed `uri` or `pathname` to read errors for more meaning

## [2.6.2] - 2016-05-13

### Fixed
- Made it possible to include colons in a $ref

### Changed
- Reformatted examples in the readme

## [2.6.1] - 2016-02-26

### Fixed
- Made sure schemas of an unrecognized type raise a SchemaParseError (not Name error)

### Changed
- Readme was converted from textile to markdown

## [2.6.0] - 2016-01-08

### Added
- Added a changelog

### Changed
- Improved performance by caching the parsing and normalization of URIs
- Made validation failures raise a `JSON::Schema::SchemaParseError` and data
  loading failures a `JSON::Schema::JsonLoadError`
