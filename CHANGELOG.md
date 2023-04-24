# Changelog

## [v4.0.0](https://github.com/voxpupuli/json-schema/tree/v4.0.0) (2023-04-24)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v3.0.0...v4.0.0)

**Breaking changes:**

- Removed `data` ivar from JSON::Validator so that multiple `validate` call become faster [\#465](https://github.com/voxpupuli/json-schema/pull/465) ([ganmacs](https://github.com/ganmacs))

**Implemented enhancements:**

- Fix more rubocop violations [\#484](https://github.com/voxpupuli/json-schema/pull/484) ([bastelfreak](https://github.com/bastelfreak))
- Fix multiple rubocop violations [\#483](https://github.com/voxpupuli/json-schema/pull/483) ([bastelfreak](https://github.com/bastelfreak))
- Add Ruby 3.2 to CI matrix [\#482](https://github.com/voxpupuli/json-schema/pull/482) ([bastelfreak](https://github.com/bastelfreak))
- Enable RuboCop in CI [\#480](https://github.com/voxpupuli/json-schema/pull/480) ([bastelfreak](https://github.com/bastelfreak))
- docs: mention draft 06 support [\#476](https://github.com/voxpupuli/json-schema/pull/476) ([levenleven](https://github.com/levenleven))
- Add const validator to draft6. [\#425](https://github.com/voxpupuli/json-schema/pull/425) ([torce](https://github.com/torce))
- Add propertyNames validator to draft6 [\#407](https://github.com/voxpupuli/json-schema/pull/407) ([torce](https://github.com/torce))

**Fixed bugs:**

- Changed draft-06 url back from /draft/schema\# to /draft-06/schema\# [\#388](https://github.com/voxpupuli/json-schema/pull/388) ([iainbeeston](https://github.com/iainbeeston))

**Merged pull requests:**

- fix more rubocop violations [\#490](https://github.com/voxpupuli/json-schema/pull/490) ([bastelfreak](https://github.com/bastelfreak))
- fix rubocop whitespace violations [\#489](https://github.com/voxpupuli/json-schema/pull/489) ([bastelfreak](https://github.com/bastelfreak))
- Fix more rubocop violations [\#488](https://github.com/voxpupuli/json-schema/pull/488) ([bastelfreak](https://github.com/bastelfreak))
- rubocop: Fix Style/HashSyntax [\#487](https://github.com/voxpupuli/json-schema/pull/487) ([bastelfreak](https://github.com/bastelfreak))
- CI: Run on PRs and merges to master [\#486](https://github.com/voxpupuli/json-schema/pull/486) ([bastelfreak](https://github.com/bastelfreak))
- rubocop: Fix Style/StringLiterals [\#485](https://github.com/voxpupuli/json-schema/pull/485) ([bastelfreak](https://github.com/bastelfreak))
- CI: Only run on pull requests & Use latest GitHub workflows [\#481](https://github.com/voxpupuli/json-schema/pull/481) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/json-schema/tree/v3.0.0) (2022-05-03)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.8.1...v3.0.0)

**Breaking changes:**

- json-schema.gemspec: Raise required ruby version to 2.5  [\#466](https://github.com/voxpupuli/json-schema/pull/466) ([bastelfreak](https://github.com/bastelfreak))
- Call URI.open directly / Drop Ruby 2.4 support [\#462](https://github.com/voxpupuli/json-schema/pull/462) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add const attribute support [\#471](https://github.com/voxpupuli/json-schema/pull/471) ([jeremie-stripe](https://github.com/jeremie-stripe))
- Add truffleruby/jruby to CI [\#469](https://github.com/voxpupuli/json-schema/pull/469) ([bastelfreak](https://github.com/bastelfreak))
- Add Ruby 3.1 to CI matrix [\#468](https://github.com/voxpupuli/json-schema/pull/468) ([bastelfreak](https://github.com/bastelfreak))
- Add Ruby 3.0 to CI matrix [\#467](https://github.com/voxpupuli/json-schema/pull/467) ([bastelfreak](https://github.com/bastelfreak))
- Allow resolution of fragments with escaped parts [\#463](https://github.com/voxpupuli/json-schema/pull/463) ([bastelfreak](https://github.com/bastelfreak))
- Add Ruby 2.6/2.7 support [\#457](https://github.com/voxpupuli/json-schema/pull/457) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Bugfix: Fix fragment when used with extended schema [\#464](https://github.com/voxpupuli/json-schema/pull/464) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- Failure/Error: require 'json-schema-rspec', cannot load such file -- multi\_json [\#448](https://github.com/voxpupuli/json-schema/issues/448)
- Allow type or null? [\#441](https://github.com/voxpupuli/json-schema/issues/441)
- type for NilClass [\#428](https://github.com/voxpupuli/json-schema/issues/428)
- It would be very useful if the required property name was included in the error object [\#417](https://github.com/voxpupuli/json-schema/issues/417)
- Uninitialized constant JSON::Validator::Timeout [\#384](https://github.com/voxpupuli/json-schema/issues/384)

**Merged pull requests:**

- update README.md/gemspec;  migrate to GitHub actions [\#456](https://github.com/voxpupuli/json-schema/pull/456) ([bastelfreak](https://github.com/bastelfreak))
- Update json-schema.gemspec; require addressable 2.8 and newer [\#455](https://github.com/voxpupuli/json-schema/pull/455) ([ahsandar](https://github.com/ahsandar))
- Update README.md [\#444](https://github.com/voxpupuli/json-schema/pull/444) ([cagmz](https://github.com/cagmz))
- Load VERSION.yml from relative path, so that developers can use "bundle config local.json-schema"  [\#419](https://github.com/voxpupuli/json-schema/pull/419) ([ndbroadbent](https://github.com/ndbroadbent))
- Fix typo in Changelog \(2019 =\> 2018\) [\#418](https://github.com/voxpupuli/json-schema/pull/418) ([ndbroadbent](https://github.com/ndbroadbent))
- Made sure we require timeout before using it [\#385](https://github.com/voxpupuli/json-schema/pull/385) ([iainbeeston](https://github.com/iainbeeston))
- webmock 3 drops ruby 1.9 support; specify this in its gemfile [\#383](https://github.com/voxpupuli/json-schema/pull/383) ([notEthan](https://github.com/notEthan))
- Refactor common test suite [\#377](https://github.com/voxpupuli/json-schema/pull/377) ([iainbeeston](https://github.com/iainbeeston))
- Corrected the draf6 schema id [\#376](https://github.com/voxpupuli/json-schema/pull/376) ([iainbeeston](https://github.com/iainbeeston))
- Added a rake task to automatically download the latest metaschemas [\#375](https://github.com/voxpupuli/json-schema/pull/375) ([iainbeeston](https://github.com/iainbeeston))
- Re-enabled test warnings [\#374](https://github.com/voxpupuli/json-schema/pull/374) ([iainbeeston](https://github.com/iainbeeston))
- Fix for string invalid scheme error when string contains colon [\#373](https://github.com/voxpupuli/json-schema/pull/373) ([benSlaughter](https://github.com/benSlaughter))
- Added simplecov [\#343](https://github.com/voxpupuli/json-schema/pull/343) ([iainbeeston](https://github.com/iainbeeston))
- Extracted all limits out to their own file [\#342](https://github.com/voxpupuli/json-schema/pull/342) ([iainbeeston](https://github.com/iainbeeston))

## [v2.8.1](https://github.com/voxpupuli/json-schema/tree/v2.8.1) (2018-10-14)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.8.0...v2.8.1)

**Closed issues:**

- Version 2.8.1 Patch release? [\#415](https://github.com/voxpupuli/json-schema/issues/415)
- possible to enforce schema ? [\#410](https://github.com/voxpupuli/json-schema/issues/410)
- undefined method `each' for "\<property\>":String [\#409](https://github.com/voxpupuli/json-schema/issues/409)
- Documentation Request: How do I validate the schema itself? [\#398](https://github.com/voxpupuli/json-schema/issues/398)
- :errors\_as\_objects can never be false in base\_schema.validate [\#392](https://github.com/voxpupuli/json-schema/issues/392)
- too complex [\#390](https://github.com/voxpupuli/json-schema/issues/390)
- Release 2.8.0 of the gem is missing a tag in the repo [\#389](https://github.com/voxpupuli/json-schema/issues/389)
- Remove trailing whitespaces [\#378](https://github.com/voxpupuli/json-schema/issues/378)
- Failure on 'allOf' validation message output is too generic [\#320](https://github.com/voxpupuli/json-schema/issues/320)

## [v2.8.0](https://github.com/voxpupuli/json-schema/tree/v2.8.0) (2017-02-07)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.7.0...v2.8.0)

**Closed issues:**

- JSON::Validator.fully\_validate\(filename, data\) fails when trying to parse filename as JSON [\#366](https://github.com/voxpupuli/json-schema/issues/366)
- 2.7.0 fails validating not required fields [\#364](https://github.com/voxpupuli/json-schema/issues/364)
- Unable to activate json-schema-2.6.2, because addressable-2.4.0 conflicts with addressable \(~\> 2.3.8\) [\#356](https://github.com/voxpupuli/json-schema/issues/356)
- Missing comma after empty array not detected as invalid [\#352](https://github.com/voxpupuli/json-schema/issues/352)
- JSON::Util::URI.parse memory leak [\#329](https://github.com/voxpupuli/json-schema/issues/329)
- additionalProperties is tested and implemented incorrectly [\#321](https://github.com/voxpupuli/json-schema/issues/321)

**Merged pull requests:**

- Updated ruby versions for travis [\#372](https://github.com/voxpupuli/json-schema/pull/372) ([iainbeeston](https://github.com/iainbeeston))
- Load local copy of draft schemas [\#362](https://github.com/voxpupuli/json-schema/pull/362) ([iainbeeston](https://github.com/iainbeeston))
- Made sure clear\_cache also clears the cache of parsed uris [\#361](https://github.com/voxpupuli/json-schema/pull/361) ([iainbeeston](https://github.com/iainbeeston))
- Simplified `#validator_for` methods [\#346](https://github.com/voxpupuli/json-schema/pull/346) ([iainbeeston](https://github.com/iainbeeston))
- Moved Validator\#absolutized\_uri and RefAttribute's ref parsing into the URI module [\#345](https://github.com/voxpupuli/json-schema/pull/345) ([iainbeeston](https://github.com/iainbeeston))
- Deprecated `JSON::Validator#validate2` [\#336](https://github.com/voxpupuli/json-schema/pull/336) ([iainbeeston](https://github.com/iainbeeston))
- Deprecated \#extend\_schema\_definition [\#335](https://github.com/voxpupuli/json-schema/pull/335) ([iainbeeston](https://github.com/iainbeeston))
- Use self or self.class rather than fully qualified class names [\#333](https://github.com/voxpupuli/json-schema/pull/333) ([iainbeeston](https://github.com/iainbeeston))
- Stopped the additional properties test from using class\_eval [\#332](https://github.com/voxpupuli/json-schema/pull/332) ([iainbeeston](https://github.com/iainbeeston))

## [v2.7.0](https://github.com/voxpupuli/json-schema/tree/v2.7.0) (2016-09-29)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.6.2...v2.7.0)

**Closed issues:**

- Test failure due to update in JSON-Schema-Test-Suite [\#357](https://github.com/voxpupuli/json-schema/issues/357)
- addressable conflict [\#355](https://github.com/voxpupuli/json-schema/issues/355)
- String "uri" format validation doesn't work [\#353](https://github.com/voxpupuli/json-schema/issues/353)
- How I can set string format by uri or email? [\#351](https://github.com/voxpupuli/json-schema/issues/351)
- Whitelisting properties [\#331](https://github.com/voxpupuli/json-schema/issues/331)
- How to build a complex schema when using with Rails [\#328](https://github.com/voxpupuli/json-schema/issues/328)
- Issues validating objects with oneOf [\#327](https://github.com/voxpupuli/json-schema/issues/327)
- Trouble with Oj parser on parse error [\#305](https://github.com/voxpupuli/json-schema/issues/305)
- tests failing with ruby 2.2 uninitialized constant JSONSchemaDraft1Test::ArrayValidation \(NameError\) [\#262](https://github.com/voxpupuli/json-schema/issues/262)

**Merged pull requests:**

- Made it possible to have a property named "$ref" [\#360](https://github.com/voxpupuli/json-schema/pull/360) ([iainbeeston](https://github.com/iainbeeston))
- Use latest json-schema draft in tests by default [\#359](https://github.com/voxpupuli/json-schema/pull/359) ([iainbeeston](https://github.com/iainbeeston))
- Restricted the ruby 1.9 build to json \< 2 [\#350](https://github.com/voxpupuli/json-schema/pull/350) ([iainbeeston](https://github.com/iainbeeston))
- Item partial tuples [\#348](https://github.com/voxpupuli/json-schema/pull/348) ([jlfaber](https://github.com/jlfaber))
- Removed the ruby 1.8 build from travis [\#340](https://github.com/voxpupuli/json-schema/pull/340) ([iainbeeston](https://github.com/iainbeeston))
- Made sure all validate methods go through the same call chain [\#338](https://github.com/voxpupuli/json-schema/pull/338) ([iainbeeston](https://github.com/iainbeeston))
- Fixed issues with caching [\#334](https://github.com/voxpupuli/json-schema/pull/334) ([iainbeeston](https://github.com/iainbeeston))
- Allow addressable 2.4+ to work with json-schema [\#312](https://github.com/voxpupuli/json-schema/pull/312) ([iainbeeston](https://github.com/iainbeeston))
- Tidy up tests [\#290](https://github.com/voxpupuli/json-schema/pull/290) ([iainbeeston](https://github.com/iainbeeston))

## [v2.6.2](https://github.com/voxpupuli/json-schema/tree/v2.6.2) (2016-05-13)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.6.1...v2.6.2)

**Closed issues:**

- "required" array in sub schema not being checked [\#325](https://github.com/voxpupuli/json-schema/issues/325)
- optional attributes are not being parsed as optional [\#324](https://github.com/voxpupuli/json-schema/issues/324)
- JSON pointers are broken when they contain a `:`  [\#319](https://github.com/voxpupuli/json-schema/issues/319)
- MultiJSON receives filepath instead of its content [\#318](https://github.com/voxpupuli/json-schema/issues/318)
- Chef DK installs addressable 2.4.0 which conflicts with the requirement for 2.3.8 for json-schema [\#317](https://github.com/voxpupuli/json-schema/issues/317)
- Empty array \(incorrectly?\) triggering ValidationError [\#311](https://github.com/voxpupuli/json-schema/issues/311)

**Merged pull requests:**

- Made it possible to have refs that include URI-special characters [\#322](https://github.com/voxpupuli/json-schema/pull/322) ([iainbeeston](https://github.com/iainbeeston))
- Reformatted the examples to make them easier to read [\#316](https://github.com/voxpupuli/json-schema/pull/316) ([iainbeeston](https://github.com/iainbeeston))

## [v2.6.1](https://github.com/voxpupuli/json-schema/tree/v2.6.1) (2016-02-26)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.6.0...v2.6.1)

**Closed issues:**

- uninitialized constant JSON::Validator::SchemaParseError [\#307](https://github.com/voxpupuli/json-schema/issues/307)
- How can I perform more complex validations [\#306](https://github.com/voxpupuli/json-schema/issues/306)
- `fully_validate` // `anyOf`, `typeOf`, `allOf` don't raise validation errors when using `record_errors: true` [\#300](https://github.com/voxpupuli/json-schema/issues/300)
- Feature Request: provide ref-like path for allOf/oneOf matches if validation fails. [\#298](https://github.com/voxpupuli/json-schema/issues/298)
- NameError: uninitialized constant JSON::Validator::SchemaParseError [\#292](https://github.com/voxpupuli/json-schema/issues/292)
- oneOf and patternProperties validates incorrectly [\#291](https://github.com/voxpupuli/json-schema/issues/291)
- Validate a schema [\#287](https://github.com/voxpupuli/json-schema/issues/287)

**Merged pull requests:**

- Update README.md [\#308](https://github.com/voxpupuli/json-schema/pull/308) ([cassidycodes](https://github.com/cassidycodes))
- Convert readme to markdown [\#302](https://github.com/voxpupuli/json-schema/pull/302) ([lencioni](https://github.com/lencioni))
- Made sure we include the module name for SchemaParseErrors [\#293](https://github.com/voxpupuli/json-schema/pull/293) ([iainbeeston](https://github.com/iainbeeston))

## [v2.6.0](https://github.com/voxpupuli/json-schema/tree/v2.6.0) (2016-01-08)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.5.2...v2.6.0)

**Closed issues:**

- How to validate data with only part of my schema [\#288](https://github.com/voxpupuli/json-schema/issues/288)
- Addressable::Uri does not raise error on invalid strings [\#282](https://github.com/voxpupuli/json-schema/issues/282)
- typeOf array doesn't validate references [\#281](https://github.com/voxpupuli/json-schema/issues/281)
- register\_format\_validator doesn't add format to @@default\_validator [\#276](https://github.com/voxpupuli/json-schema/issues/276)
- JSON API 1.0 Support [\#272](https://github.com/voxpupuli/json-schema/issues/272)

**Merged pull requests:**

- Remove ruby warnings [\#286](https://github.com/voxpupuli/json-schema/pull/286) ([teoljungberg](https://github.com/teoljungberg))
- Redux: speed up JSON::Validator.validate [\#285](https://github.com/voxpupuli/json-schema/pull/285) ([iainbeeston](https://github.com/iainbeeston))
- Test all versions in test\_custom\_format [\#278](https://github.com/voxpupuli/json-schema/pull/278) ([jpmckinney](https://github.com/jpmckinney))
- Update README.textile to fix schema validation example [\#271](https://github.com/voxpupuli/json-schema/pull/271) ([mkonecny](https://github.com/mkonecny))
- Only rescue errors explicitly [\#239](https://github.com/voxpupuli/json-schema/pull/239) ([iainbeeston](https://github.com/iainbeeston))

## [v2.5.2](https://github.com/voxpupuli/json-schema/tree/v2.5.2) (2015-11-24)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.5.1...v2.5.2)

**Closed issues:**

- Properties as Property not working [\#273](https://github.com/voxpupuli/json-schema/issues/273)
- Schema nesting with id key is not validating as expected [\#270](https://github.com/voxpupuli/json-schema/issues/270)
- Does not validate email correctly... [\#269](https://github.com/voxpupuli/json-schema/issues/269)
- No implicit conversion of integer [\#259](https://github.com/voxpupuli/json-schema/issues/259)
- No implicit conversion of integer to string with links [\#258](https://github.com/voxpupuli/json-schema/issues/258)
- Automatically parse number values [\#257](https://github.com/voxpupuli/json-schema/issues/257)
- Does not fail for type number when the data is string  [\#251](https://github.com/voxpupuli/json-schema/issues/251)
- Prepare release of 2.5.1 [\#228](https://github.com/voxpupuli/json-schema/issues/228)
- Unable to set clear\_cache option [\#225](https://github.com/voxpupuli/json-schema/issues/225)
- Incorrect exception message in 2.5.0 [\#220](https://github.com/voxpupuli/json-schema/issues/220)
- Trouble with forbidden additionalProperties and one/any/allOf? [\#161](https://github.com/voxpupuli/json-schema/issues/161)

**Merged pull requests:**

- register\_format\_validator on default\_validator [\#277](https://github.com/voxpupuli/json-schema/pull/277) ([jpmckinney](https://github.com/jpmckinney))
- Explicitly notes :strict overrides any required properties set in schema [\#252](https://github.com/voxpupuli/json-schema/pull/252) ([KTKate](https://github.com/KTKate))
- Use old hash syntax in tests [\#240](https://github.com/voxpupuli/json-schema/pull/240) ([iainbeeston](https://github.com/iainbeeston))
- Allow boolean false as a default property. [\#238](https://github.com/voxpupuli/json-schema/pull/238) ([chrisandreae](https://github.com/chrisandreae))
- Removed test files from gemspec [\#237](https://github.com/voxpupuli/json-schema/pull/237) ([iainbeeston](https://github.com/iainbeeston))
- Expose clear\_cache option [\#235](https://github.com/voxpupuli/json-schema/pull/235) ([danieldraper](https://github.com/danieldraper))
- Enabled warnings when running tests [\#231](https://github.com/voxpupuli/json-schema/pull/231) ([iainbeeston](https://github.com/iainbeeston))

## [v2.5.1](https://github.com/voxpupuli/json-schema/tree/v2.5.1) (2015-02-23)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/v2.5.0...v2.5.1)

**Closed issues:**

- Passing in a fragment with an even number of tokens can lead to undefined method `validate' for \#\<Hash...\> [\#265](https://github.com/voxpupuli/json-schema/issues/265)
- Absoluteness correction [\#233](https://github.com/voxpupuli/json-schema/issues/233)
- Consider releasing 2.5.1 [\#227](https://github.com/voxpupuli/json-schema/issues/227)

**Merged pull requests:**

- Ignore fragments in schema caching. Fixes \#233 [\#234](https://github.com/voxpupuli/json-schema/pull/234) ([jphastings](https://github.com/jphastings))
- Only add violating properties to error message for strict validation [\#230](https://github.com/voxpupuli/json-schema/pull/230) ([RST-J](https://github.com/RST-J))
- Show sub-errors for oneOf [\#216](https://github.com/voxpupuli/json-schema/pull/216) ([isage](https://github.com/isage))
- Update README - latest version is currently 2.5.0 [\#215](https://github.com/voxpupuli/json-schema/pull/215) ([take](https://github.com/take))
- End single quote in validation error [\#213](https://github.com/voxpupuli/json-schema/pull/213) ([olleolleolle](https://github.com/olleolleolle))
- add description for nested types array and object [\#212](https://github.com/voxpupuli/json-schema/pull/212) ([brancz](https://github.com/brancz))
- Updated to addressable 2.3.7 [\#226](https://github.com/voxpupuli/json-schema/pull/226) ([iainbeeston](https://github.com/iainbeeston))
- Made sure we really do update the common test suite before test runs [\#224](https://github.com/voxpupuli/json-schema/pull/224) ([iainbeeston](https://github.com/iainbeeston))
- Added Ruby 2.2 to the build matrix [\#223](https://github.com/voxpupuli/json-schema/pull/223) ([iainbeeston](https://github.com/iainbeeston))
- Renamed variable in oneOf to avoid name clash [\#221](https://github.com/voxpupuli/json-schema/pull/221) ([iainbeeston](https://github.com/iainbeeston))
- Issue with Fixnum and Float in enum [\#219](https://github.com/voxpupuli/json-schema/pull/219) ([RST-J](https://github.com/RST-J))

## [v2.5.0](https://github.com/voxpupuli/json-schema/tree/v2.5.0) (2014-12-03)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.4.1...v2.5.0)

**Closed issues:**

- additionalProperties and $ref are not working together [\#185](https://github.com/voxpupuli/json-schema/issues/185)
- Dependencies [\#179](https://github.com/voxpupuli/json-schema/issues/179)
- Use Addressable for handling URIs? [\#173](https://github.com/voxpupuli/json-schema/issues/173)
- Full support for the common test suite [\#163](https://github.com/voxpupuli/json-schema/issues/163)
- Remove yajl-Ruby support in favour of multi\_json [\#162](https://github.com/voxpupuli/json-schema/issues/162)
- Drop support for email and hostname formats [\#159](https://github.com/voxpupuli/json-schema/issues/159)
- format: date-time validator isn't leap-second compliant [\#123](https://github.com/voxpupuli/json-schema/issues/123)
- Symbol keys not handled in combination with additionalProperties [\#108](https://github.com/voxpupuli/json-schema/issues/108)
- When extending a schema in folder names with spaces [\#100](https://github.com/voxpupuli/json-schema/issues/100)
- Enhancing schema draft [\#99](https://github.com/voxpupuli/json-schema/issues/99)
- Doesn't work in JRuby \(1.7.10 or 1.7.6\) with --1.8 [\#95](https://github.com/voxpupuli/json-schema/issues/95)
- Support for string "format" attribute [\#79](https://github.com/voxpupuli/json-schema/issues/79)
- Provide secure way of testing [\#77](https://github.com/voxpupuli/json-schema/issues/77)
- Breaks with multi\_json 1.7.9 \(works with 1.7.7\) [\#73](https://github.com/voxpupuli/json-schema/issues/73)
- additionalProperties and extends don't work together [\#31](https://github.com/voxpupuli/json-schema/issues/31)
- Next minor release \(2.5.0\) [\#202](https://github.com/voxpupuli/json-schema/issues/202)

**Merged pull requests:**

- Added bundler gem management rake tasks [\#211](https://github.com/voxpupuli/json-schema/pull/211) ([iainbeeston](https://github.com/iainbeeston))
- Refactored parser error code [\#210](https://github.com/voxpupuli/json-schema/pull/210) ([iainbeeston](https://github.com/iainbeeston))
- WebMock is on globally now; no need to disable it [\#208](https://github.com/voxpupuli/json-schema/pull/208) ([pd](https://github.com/pd))
- Addressable spring clean [\#199](https://github.com/voxpupuli/json-schema/pull/199) ([iainbeeston](https://github.com/iainbeeston))
- Tidied the common test suite tests [\#197](https://github.com/voxpupuli/json-schema/pull/197) ([iainbeeston](https://github.com/iainbeeston))
- Remove "no dependencies" claim from README [\#194](https://github.com/voxpupuli/json-schema/pull/194) ([pd](https://github.com/pd))
- Remove unused Schema\#base\_uri method [\#193](https://github.com/voxpupuli/json-schema/pull/193) ([pd](https://github.com/pd))
- Updated the common test suite [\#191](https://github.com/voxpupuli/json-schema/pull/191) ([iainbeeston](https://github.com/iainbeeston))
- Use unescape for paths before reading files [\#188](https://github.com/voxpupuli/json-schema/pull/188) ([RST-J](https://github.com/RST-J))
- Use the new build env on Travis [\#187](https://github.com/voxpupuli/json-schema/pull/187) ([joshk](https://github.com/joshk))
- `oneOf` and `anyOf` errors where default values are present [\#181](https://github.com/voxpupuli/json-schema/pull/181) ([tonymarklove](https://github.com/tonymarklove))
- Only stringify schema once [\#180](https://github.com/voxpupuli/json-schema/pull/180) ([treppo](https://github.com/treppo))
- Refactor ref schema URI construction. [\#177](https://github.com/voxpupuli/json-schema/pull/177) ([gabrielg](https://github.com/gabrielg))
- Use RFC 2606 reserved invalid DNS name in tests. [\#176](https://github.com/voxpupuli/json-schema/pull/176) ([gabrielg](https://github.com/gabrielg))
- Use Addressable gem to handle URIs [\#174](https://github.com/voxpupuli/json-schema/pull/174) ([RST-J](https://github.com/RST-J))
- General cleanup, mostly focused on attributes/\* [\#172](https://github.com/voxpupuli/json-schema/pull/172) ([pd](https://github.com/pd))
- Extend common-test-suite to ignore individual test cases [\#171](https://github.com/voxpupuli/json-schema/pull/171) ([mpalmer](https://github.com/mpalmer))
- Added some tests around file uris [\#169](https://github.com/voxpupuli/json-schema/pull/169) ([iainbeeston](https://github.com/iainbeeston))
- Add some test helpers for common patterns [\#168](https://github.com/voxpupuli/json-schema/pull/168) ([pd](https://github.com/pd))
- Removed multijson license [\#167](https://github.com/voxpupuli/json-schema/pull/167) ([iainbeeston](https://github.com/iainbeeston))
- Add mailing list and IRC channel [\#166](https://github.com/voxpupuli/json-schema/pull/166) ([hoxworth](https://github.com/hoxworth))
- Fix draft3 `disallow` validation [\#165](https://github.com/voxpupuli/json-schema/pull/165) ([pd](https://github.com/pd))
- Enable refremote specs [\#164](https://github.com/voxpupuli/json-schema/pull/164) ([pd](https://github.com/pd))
- Fix for relative ref with fragment identifier on Windows [\#109](https://github.com/voxpupuli/json-schema/pull/109) ([jlblcc](https://github.com/jlblcc))
- Any ref issue [\#200](https://github.com/voxpupuli/json-schema/pull/200) ([RST-J](https://github.com/RST-J))
- Fix test runs for optional dependencies [\#196](https://github.com/voxpupuli/json-schema/pull/196) ([iainbeeston](https://github.com/iainbeeston))
- JSON::Schema::Reader [\#175](https://github.com/voxpupuli/json-schema/pull/175) ([pd](https://github.com/pd))

## [2.4.1](https://github.com/voxpupuli/json-schema/tree/2.4.1) (2014-10-28)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.4.0...2.4.1)

**Merged pull requests:**

- Replaced \#add\_indifferent\_access with \#stringify [\#142](https://github.com/voxpupuli/json-schema/pull/142) ([iainbeeston](https://github.com/iainbeeston))

## [2.4.0](https://github.com/voxpupuli/json-schema/tree/2.4.0) (2014-10-28)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.3.0...2.4.0)

**Fixed bugs:**

- Bug in IPV6 format validation [\#133](https://github.com/voxpupuli/json-schema/issues/133)

**Closed issues:**

- Path issue when validating draft-04 schema [\#160](https://github.com/voxpupuli/json-schema/issues/160)
- Schema validation is broken in master [\#135](https://github.com/voxpupuli/json-schema/issues/135)
- Dependencies don't seem to work correctly [\#117](https://github.com/voxpupuli/json-schema/issues/117)
- Use common test suite? [\#113](https://github.com/voxpupuli/json-schema/issues/113)
- "Fix symbol keys in data" breaks working implementations [\#96](https://github.com/voxpupuli/json-schema/issues/96)

**Merged pull requests:**

- Add yajl, multi\_json and uuidtools to travis [\#157](https://github.com/voxpupuli/json-schema/pull/157) ([iainbeeston](https://github.com/iainbeeston))
- Store static regexps in constants for re-use [\#156](https://github.com/voxpupuli/json-schema/pull/156) ([pd](https://github.com/pd))
- Fix metaschema access [\#155](https://github.com/voxpupuli/json-schema/pull/155) ([pd](https://github.com/pd))
- Add ruby 1.8 to travis [\#154](https://github.com/voxpupuli/json-schema/pull/154) ([iainbeeston](https://github.com/iainbeeston))
- Enable draft4/dependencies test [\#153](https://github.com/voxpupuli/json-schema/pull/153) ([pd](https://github.com/pd))
- Add 1.8.7 minimum ruby version to the spec [\#149](https://github.com/voxpupuli/json-schema/pull/149) ([hoxworth](https://github.com/hoxworth))
- Validator tidy [\#147](https://github.com/voxpupuli/json-schema/pull/147) ([iainbeeston](https://github.com/iainbeeston))
- Unescape ref fragment pointers [\#146](https://github.com/voxpupuli/json-schema/pull/146) ([pd](https://github.com/pd))
- Fix schema dep v4 [\#145](https://github.com/voxpupuli/json-schema/pull/145) ([RST-J](https://github.com/RST-J))
- Update descr [\#144](https://github.com/voxpupuli/json-schema/pull/144) ([RST-J](https://github.com/RST-J))
- Use IPAddr class to validate ip formats [\#143](https://github.com/voxpupuli/json-schema/pull/143) ([RST-J](https://github.com/RST-J))
- Added codeclimate badge to readme [\#141](https://github.com/voxpupuli/json-schema/pull/141) ([iainbeeston](https://github.com/iainbeeston))
- Make intra-doc refs work when validating with :fragment [\#127](https://github.com/voxpupuli/json-schema/pull/127) ([mpalmer](https://github.com/mpalmer))
- Hyper validation [\#125](https://github.com/voxpupuli/json-schema/pull/125) ([mpalmer](https://github.com/mpalmer))
- Parse dates using ruby's own date parsing - not regular expressions [\#118](https://github.com/voxpupuli/json-schema/pull/118) ([iainbeeston](https://github.com/iainbeeston))

## [2.3.0](https://github.com/voxpupuli/json-schema/tree/2.3.0) (2014-10-26)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.2.4...2.3.0)

**Fixed bugs:**

- Possible bug: nil items in Array properties are stripped before MinItems validation [\#129](https://github.com/voxpupuli/json-schema/issues/129)
- some questions about addtionalproperties [\#112](https://github.com/voxpupuli/json-schema/issues/112)

**Closed issues:**

- Possible bug: wrong expectation of required object property [\#139](https://github.com/voxpupuli/json-schema/issues/139)
- Array Validates Against Schema When It Shouldn't [\#137](https://github.com/voxpupuli/json-schema/issues/137)
- Registration of custom format validators [\#128](https://github.com/voxpupuli/json-schema/issues/128)
- Invalid schema not reported using fully\_validate with a oneOf attribute [\#116](https://github.com/voxpupuli/json-schema/issues/116)
- Errors for required properties do not contain the fragment correctly. [\#115](https://github.com/voxpupuli/json-schema/issues/115)
- Use of String\#each breaks Ruby 1.9 [\#78](https://github.com/voxpupuli/json-schema/issues/78)

**Merged pull requests:**

- Do not compact before checking minItems [\#140](https://github.com/voxpupuli/json-schema/pull/140) ([pd](https://github.com/pd))
- Made validation sub errors indicate where they come from [\#138](https://github.com/voxpupuli/json-schema/pull/138) ([iainbeeston](https://github.com/iainbeeston))
- Add support for `"required": false` while using draft3 with strict mode [\#134](https://github.com/voxpupuli/json-schema/pull/134) ([bkirz](https://github.com/bkirz))
- Custom formats [\#132](https://github.com/voxpupuli/json-schema/pull/132) ([RST-J](https://github.com/RST-J))
- Extract formats into separate classes [\#131](https://github.com/voxpupuli/json-schema/pull/131) ([RST-J](https://github.com/RST-J))
- Refactor classes and validator accessor methods [\#130](https://github.com/voxpupuli/json-schema/pull/130) ([iainbeeston](https://github.com/iainbeeston))
- Another allOf ref test, and rename class [\#126](https://github.com/voxpupuli/json-schema/pull/126) ([mpalmer](https://github.com/mpalmer))
- Fix bad ref test for proxy support [\#124](https://github.com/voxpupuli/json-schema/pull/124) ([mpalmer](https://github.com/mpalmer))
- Run json-schema.org's common test suite [\#122](https://github.com/voxpupuli/json-schema/pull/122) ([mpalmer](https://github.com/mpalmer))
- Stopped draft3 from registering itself as the default validator [\#121](https://github.com/voxpupuli/json-schema/pull/121) ([iainbeeston](https://github.com/iainbeeston))
- Added ruby 2.0, rubinius and jruby to travis build [\#119](https://github.com/voxpupuli/json-schema/pull/119) ([iainbeeston](https://github.com/iainbeeston))
- Handle non-latin uris [\#114](https://github.com/voxpupuli/json-schema/pull/114) ([iainbeeston](https://github.com/iainbeeston))
- Remove deprecated :rubygems source from Gemfile [\#111](https://github.com/voxpupuli/json-schema/pull/111) ([jamiecobbett](https://github.com/jamiecobbett))

## [2.2.4](https://github.com/voxpupuli/json-schema/tree/2.2.4) (2014-07-19)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.2.3...2.2.4)

**Closed issues:**

- Not correctly validating: "The property did not match the following type: string in schema" [\#101](https://github.com/voxpupuli/json-schema/issues/101)
- Validator return error when data is an array  with hash with symbolic keys [\#94](https://github.com/voxpupuli/json-schema/issues/94)

**Merged pull requests:**

- Fix `list:true` when referencing a cached schema [\#107](https://github.com/voxpupuli/json-schema/pull/107) ([pd](https://github.com/pd))
- Setup travis [\#106](https://github.com/voxpupuli/json-schema/pull/106) ([apsoto](https://github.com/apsoto))

## [2.2.3](https://github.com/voxpupuli/json-schema/tree/2.2.3) (2014-07-16)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/1.2.1...2.2.3)

**Closed issues:**

- Symbol keys are not supported in objects within arrays [\#104](https://github.com/voxpupuli/json-schema/issues/104)

**Merged pull requests:**

- Make hashes in arrays indifferent to string/symbol keys [\#105](https://github.com/voxpupuli/json-schema/pull/105) ([jennyd](https://github.com/jennyd))
- Load files from namespaced location to avoid conflicts [\#98](https://github.com/voxpupuli/json-schema/pull/98) ([kjg](https://github.com/kjg))

## [1.2.1](https://github.com/voxpupuli/json-schema/tree/1.2.1) (2014-01-15)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.2.1...1.2.1)

## [2.2.1](https://github.com/voxpupuli/json-schema/tree/2.2.1) (2014-01-15)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.2.0...2.2.1)

## [2.2.0](https://github.com/voxpupuli/json-schema/tree/2.2.0) (2014-01-15)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/1.2.0...2.2.0)

## [1.2.0](https://github.com/voxpupuli/json-schema/tree/1.2.0) (2014-01-15)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.8...1.2.0)

**Closed issues:**

- No error when schema not found [\#87](https://github.com/voxpupuli/json-schema/issues/87)
- Schema validation should not clear cache [\#82](https://github.com/voxpupuli/json-schema/issues/82)

## [2.1.8](https://github.com/voxpupuli/json-schema/tree/2.1.8) (2014-01-04)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.7...2.1.8)

**Closed issues:**

- Enum conversion to a Hash breaks Schema Validation [\#93](https://github.com/voxpupuli/json-schema/issues/93)

**Merged pull requests:**

- Fix logic error in format validation [\#80](https://github.com/voxpupuli/json-schema/pull/80) ([jpmckinney](https://github.com/jpmckinney))

## [2.1.7](https://github.com/voxpupuli/json-schema/tree/2.1.7) (2014-01-03)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.6...2.1.7)

**Closed issues:**

- Validation still requires data hash keys to be strings. Contrary to most recent version's stated purpose. [\#74](https://github.com/voxpupuli/json-schema/issues/74)

## [2.1.6](https://github.com/voxpupuli/json-schema/tree/2.1.6) (2014-01-01)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.5...2.1.6)

**Closed issues:**

- Validator takes too long to validate JSON. [\#89](https://github.com/voxpupuli/json-schema/issues/89)
- JSON::Validator.fully\_validate returns error for valid schema with "not" keyword in it [\#84](https://github.com/voxpupuli/json-schema/issues/84)
- JSON::Validator modifies schema object [\#83](https://github.com/voxpupuli/json-schema/issues/83)
- 2.1.2 broke 1.8.7 compatibility [\#62](https://github.com/voxpupuli/json-schema/issues/62)

## [2.1.5](https://github.com/voxpupuli/json-schema/tree/2.1.5) (2014-01-01)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.4...2.1.5)

**Closed issues:**

- Can you push up the tags? [\#91](https://github.com/voxpupuli/json-schema/issues/91)
- JSON::Validator.default\_validator is being set to draft-03 by default [\#76](https://github.com/voxpupuli/json-schema/issues/76)
- Can't validate with fragment [\#64](https://github.com/voxpupuli/json-schema/issues/64)
- Schema-wide "required" doesn't work [\#61](https://github.com/voxpupuli/json-schema/issues/61)

## [2.1.4](https://github.com/voxpupuli/json-schema/tree/2.1.4) (2013-12-31)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.3...2.1.4)

**Closed issues:**

- Fat arrow vs colon [\#88](https://github.com/voxpupuli/json-schema/issues/88)
- allOf and $ref not working? [\#86](https://github.com/voxpupuli/json-schema/issues/86)
- Returns "valid" when schema is invalid [\#81](https://github.com/voxpupuli/json-schema/issues/81)
- How to validate schema only? [\#71](https://github.com/voxpupuli/json-schema/issues/71)
- $ref in anyOf, allOf, etc don't work [\#66](https://github.com/voxpupuli/json-schema/issues/66)
- Problem with $ref to validate array property [\#63](https://github.com/voxpupuli/json-schema/issues/63)
- License missing from gemspec [\#60](https://github.com/voxpupuli/json-schema/issues/60)

**Merged pull requests:**

- Fix issue 86 [\#92](https://github.com/voxpupuli/json-schema/pull/92) ([sebbacon](https://github.com/sebbacon))
- Updated date-time regex to accept zero or one of : in the timezone designator [\#85](https://github.com/voxpupuli/json-schema/pull/85) ([jwarykowski](https://github.com/jwarykowski))
- Fixed fragment resolution. Issue \#64 [\#75](https://github.com/voxpupuli/json-schema/pull/75) ([arcticlcc](https://github.com/arcticlcc))
- Dont break file scheme with unc on windows [\#72](https://github.com/voxpupuli/json-schema/pull/72) ([kylog](https://github.com/kylog))
- Fix one of logic [\#70](https://github.com/voxpupuli/json-schema/pull/70) ([apsoto](https://github.com/apsoto))
- Add Gemfile and ignore Gemfile.lock. [\#68](https://github.com/voxpupuli/json-schema/pull/68) ([ryotarai](https://github.com/ryotarai))

## [2.1.3](https://github.com/voxpupuli/json-schema/tree/2.1.3) (2013-08-02)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.2...2.1.3)

**Closed issues:**

- Fail on ruby 1.9.3, jruby 1.6.8 --1.9 [\#45](https://github.com/voxpupuli/json-schema/issues/45)

**Merged pull requests:**

- Fix Issue \#66 [\#67](https://github.com/voxpupuli/json-schema/pull/67) ([apsoto](https://github.com/apsoto))

## [2.1.2](https://github.com/voxpupuli/json-schema/tree/2.1.2) (2013-07-19)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.1...2.1.2)

**Closed issues:**

- validate\_schema does not use value of $schema [\#59](https://github.com/voxpupuli/json-schema/issues/59)

## [2.1.1](https://github.com/voxpupuli/json-schema/tree/2.1.1) (2013-07-03)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.1.0...2.1.1)

**Closed issues:**

- Validate against a schema fragment. [\#56](https://github.com/voxpupuli/json-schema/issues/56)
- 1.0.9 has ruby 1.9.x dependency; breaks patch compatibility [\#44](https://github.com/voxpupuli/json-schema/issues/44)

## [2.1.0](https://github.com/voxpupuli/json-schema/tree/2.1.0) (2013-07-03)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.0.4...2.1.0)

**Closed issues:**

- json-schema 2.0.1 broke schema validation [\#58](https://github.com/voxpupuli/json-schema/issues/58)
- maxItems is not working [\#54](https://github.com/voxpupuli/json-schema/issues/54)

**Merged pull requests:**

- Add failing test demonstrating failure of complex union type. [\#52](https://github.com/voxpupuli/json-schema/pull/52) ([myronmarston](https://github.com/myronmarston))

## [2.0.4](https://github.com/voxpupuli/json-schema/tree/2.0.4) (2013-07-01)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.0.3...2.0.4)

**Closed issues:**

- ISO 8601 date-times do not include UTC offset [\#42](https://github.com/voxpupuli/json-schema/issues/42)

**Merged pull requests:**

- Show schema type in error message instead of ruby class [\#50](https://github.com/voxpupuli/json-schema/pull/50) ([jvatic](https://github.com/jvatic))

## [2.0.3](https://github.com/voxpupuli/json-schema/tree/2.0.3) (2013-06-26)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.0.2...2.0.3)

**Merged pull requests:**

- Fix date-time format. [\#43](https://github.com/voxpupuli/json-schema/pull/43) ([chris-baynes](https://github.com/chris-baynes))

## [2.0.2](https://github.com/voxpupuli/json-schema/tree/2.0.2) (2013-06-26)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.0.1...2.0.2)

**Closed issues:**

- Unable to Validate v4 Schema File [\#57](https://github.com/voxpupuli/json-schema/issues/57)

**Merged pull requests:**

- maxitems error message correction [\#55](https://github.com/voxpupuli/json-schema/pull/55) ([lpavan](https://github.com/lpavan))
- Extends support array of objects too [\#53](https://github.com/voxpupuli/json-schema/pull/53) ([rogerleite](https://github.com/rogerleite))

## [2.0.1](https://github.com/voxpupuli/json-schema/tree/2.0.1) (2013-06-25)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/2.0.0...2.0.1)

**Closed issues:**

- Support draft v4 [\#51](https://github.com/voxpupuli/json-schema/issues/51)

## [2.0.0](https://github.com/voxpupuli/json-schema/tree/2.0.0) (2013-06-23)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/1.0.4...2.0.0)

**Closed issues:**

- json\_schema with old multi\_json in Rails context [\#39](https://github.com/voxpupuli/json-schema/issues/39)
- Doesn't work with 1.9 stdlib JSON [\#33](https://github.com/voxpupuli/json-schema/issues/33)
- Validation not working on nested properties [\#30](https://github.com/voxpupuli/json-schema/issues/30)
- Add in a validation error structure [\#29](https://github.com/voxpupuli/json-schema/issues/29)
- union types with schemas don't work with :record\_errors =\> true  [\#27](https://github.com/voxpupuli/json-schema/issues/27)
- Validator is not thread safe [\#24](https://github.com/voxpupuli/json-schema/issues/24)

**Merged pull requests:**

- More descriptive error message for PatternAttribute [\#49](https://github.com/voxpupuli/json-schema/pull/49) ([quoideneuf](https://github.com/quoideneuf))
- Support \(optional\) adding of default values to input data while validating [\#48](https://github.com/voxpupuli/json-schema/pull/48) ([goodsimon](https://github.com/goodsimon))
- Restore 1.8.7 compatibility. [\#46](https://github.com/voxpupuli/json-schema/pull/46) ([myronmarston](https://github.com/myronmarston))
- Extends and additional properties take 2 [\#41](https://github.com/voxpupuli/json-schema/pull/41) ([japgolly](https://github.com/japgolly))
- Fix Issue with MultiJson Feature Detection [\#40](https://github.com/voxpupuli/json-schema/pull/40) ([tylerhunt](https://github.com/tylerhunt))
- Extract type validation into a helper method. [\#38](https://github.com/voxpupuli/json-schema/pull/38) ([myronmarston](https://github.com/myronmarston))
- date-time format and fractional seconds part [\#36](https://github.com/voxpupuli/json-schema/pull/36) ([ILikePies](https://github.com/ILikePies))
- Play nicely with new and old versions of MultiJson [\#35](https://github.com/voxpupuli/json-schema/pull/35) ([japgolly](https://github.com/japgolly))
- Validation fails if root data object is a string  [\#26](https://github.com/voxpupuli/json-schema/pull/26) ([vapir](https://github.com/vapir))

## [1.0.4](https://github.com/voxpupuli/json-schema/tree/1.0.4) (2012-02-14)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/1.0.0...1.0.4)

**Closed issues:**

- Extending a schema doesn't allow overrides [\#22](https://github.com/voxpupuli/json-schema/issues/22)

**Merged pull requests:**

- Multijson and schema validation [\#28](https://github.com/voxpupuli/json-schema/pull/28) ([myronmarston](https://github.com/myronmarston))
- Json::Schema::\*Error classes should inherit from StandardError instead of Exception. [\#25](https://github.com/voxpupuli/json-schema/pull/25) ([tommay](https://github.com/tommay))
- More descriptive error messages [\#23](https://github.com/voxpupuli/json-schema/pull/23) ([zachmargolis](https://github.com/zachmargolis))

## [1.0.0](https://github.com/voxpupuli/json-schema/tree/1.0.0) (2012-01-04)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.9.12...1.0.0)

## [0.9.12](https://github.com/voxpupuli/json-schema/tree/0.9.12) (2011-12-14)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.9.3...0.9.12)

**Closed issues:**

- Validation is slow [\#19](https://github.com/voxpupuli/json-schema/issues/19)
- dependency with string value [\#18](https://github.com/voxpupuli/json-schema/issues/18)
- minLength for non string type [\#17](https://github.com/voxpupuli/json-schema/issues/17)
- Hypermedia schema [\#16](https://github.com/voxpupuli/json-schema/issues/16)
- SimpleUUID::UUID conflicts with simple\_uuid gem [\#11](https://github.com/voxpupuli/json-schema/issues/11)
- UUID class conflict [\#9](https://github.com/voxpupuli/json-schema/issues/9)

**Merged pull requests:**

- Fixed Issue \#19 - replace schema.inspect with Yajl::Encoder.encode or Marshal.dump as a fallback [\#20](https://github.com/voxpupuli/json-schema/pull/20) ([kindkid](https://github.com/kindkid))
- Fixes for validate\_schema [\#15](https://github.com/voxpupuli/json-schema/pull/15) ([dekellum](https://github.com/dekellum))
- Fix require of attributes and validators to work in Rubinius  [\#14](https://github.com/voxpupuli/json-schema/pull/14) ([IPGlider](https://github.com/IPGlider))
- Gem::Specification::find\_by\_name errors [\#12](https://github.com/voxpupuli/json-schema/pull/12) ([oruen](https://github.com/oruen))
- removed new rubygems deprecation warnings [\#10](https://github.com/voxpupuli/json-schema/pull/10) ([Vasfed](https://github.com/Vasfed))

## [0.9.3](https://github.com/voxpupuli/json-schema/tree/0.9.3) (2011-04-21)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.9.2...0.9.3)

**Closed issues:**

- typo in lib/json-schema/validator.rb at line 270 [\#8](https://github.com/voxpupuli/json-schema/issues/8)
- Relative URIs are resolved improperly [\#5](https://github.com/voxpupuli/json-schema/issues/5)
- 'format' constraint should not be validated for null values [\#4](https://github.com/voxpupuli/json-schema/issues/4)

**Merged pull requests:**

- removed deprecated option has\_rdoc from gemspec [\#7](https://github.com/voxpupuli/json-schema/pull/7) ([Vasfed](https://github.com/Vasfed))

## [0.9.2](https://github.com/voxpupuli/json-schema/tree/0.9.2) (2011-03-30)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.9.1...0.9.2)

## [0.9.1](https://github.com/voxpupuli/json-schema/tree/0.9.1) (2011-03-21)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.9.0...0.9.1)

**Closed issues:**

- Previous draft support [\#2](https://github.com/voxpupuli/json-schema/issues/2)

**Merged pull requests:**

- Do not add hash items while iterating over them. [\#3](https://github.com/voxpupuli/json-schema/pull/3) ([oruen](https://github.com/oruen))

## [0.9.0](https://github.com/voxpupuli/json-schema/tree/0.9.0) (2011-03-19)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.2.0...0.9.0)

## [0.2.0](https://github.com/voxpupuli/json-schema/tree/0.2.0) (2011-03-09)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.1.14...0.2.0)

## [0.1.14](https://github.com/voxpupuli/json-schema/tree/0.1.14) (2011-03-09)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.1.10...0.1.14)

## [0.1.10](https://github.com/voxpupuli/json-schema/tree/0.1.10) (2011-01-10)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.1.6...0.1.10)

## [0.1.6](https://github.com/voxpupuli/json-schema/tree/0.1.6) (2010-12-03)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/0.1.2...0.1.6)

## [0.1.2](https://github.com/voxpupuli/json-schema/tree/0.1.2) (2010-11-30)

[Full Changelog](https://github.com/voxpupuli/json-schema/compare/d1c7b421bbb04d00b06c49e6ebb5ba773d756b12...0.1.2)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
