# Change Log
All notable changes to this project will be documented in this file.
Please keep to the changelog format described on [keepachangelog.com](http://keepachangelog.com).
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Fixed
- Made sure we really do clear the cache when instructed to
- It's now possible to use reserved words in property names
- Removed support for setting "extends" to a string (it's invalid json-schema - use a "$ref" instead)

### Changed
- Made all `validate*` methods on `JSON::Validator` ultimately call `validate!`

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
