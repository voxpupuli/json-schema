# Change Log
All notable changes to this project will be documented in this file.
Please keep to the changelog format described on [keepachangelog.com](http://keepachangelog.com).
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- Added a changelog

### Changed
- Made validation failures raise a `JSON::Schema::SchemaParseError` and data
  loading failures a `JSON::Schema::JsonLoadError`
