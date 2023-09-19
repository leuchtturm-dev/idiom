# Changelog

## [0.6.4](https://github.com/cschmatzler/idiom/compare/v0.6.3...v0.6.4) (2023-09-19)


### Bug Fixes

* fix `Idiom.Locales.get_language_and_script/1` when second part is not a script ([ca9443e](https://github.com/cschmatzler/idiom/commit/ca9443e2b75512609d33326bd60ceb6200ceb740))

## [0.6.3](https://github.com/cschmatzler/idiom/compare/v0.6.2...v0.6.3) (2023-09-13)


### Features

* Add `mix idiom.extract` ([#15](https://github.com/cschmatzler/idiom/issues/15)) ([f59eecb](https://github.com/cschmatzler/idiom/commit/f59eecb324551e3e8ed201033b3bac63ee28ec87))


### Bug Fixes

* don't try resolving a locale multiple times ([c042af1](https://github.com/cschmatzler/idiom/commit/c042af1ba216846971ec2b27b42113af133de968))

## [0.6.2](https://github.com/cschmatzler/idiom/compare/v0.6.1...v0.6.2) (2023-09-06)


### Bug Fixes

* actually support ordinal plurals ([2eda631](https://github.com/cschmatzler/idiom/commit/2eda63191f92872e34cdb2ab7c1c1f3dc913656e))

## [0.6.1](https://github.com/cschmatzler/idiom/compare/v0.6.0...v0.6.1) (2023-09-06)


### Features

* Add Lokalise support ([#30](https://github.com/cschmatzler/idiom/issues/30)) ([92b2211](https://github.com/cschmatzler/idiom/commit/92b2211f3a7239ef4a8bc678d4788a0ecd6c255f))

## [0.6.0](https://github.com/cschmatzler/idiom/compare/v0.5.1...v0.6.0) (2023-09-05)


### ⚠ BREAKING CHANGES

* relicense

### Features

* relicense ([0d36941](https://github.com/cschmatzler/idiom/commit/0d36941b7c37600c5183a433ecbb6c6e385d23f3))

## [0.5.1](https://github.com/cschmatzler/idiom/compare/v0.5.0...v0.5.1) (2023-09-05)


### Features

* add support for ordinal plurals ([#26](https://github.com/cschmatzler/idiom/issues/26)) ([206c766](https://github.com/cschmatzler/idiom/commit/206c766922dce38bf5887f3a330f21950320c533))

## [0.5.0](https://github.com/cschmatzler/idiom/compare/v0.4.1...v0.5.0) (2023-09-04)


### ⚠ BREAKING CHANGES

* internal cleanup
* no longer hardcode defaults for `locale`, `namespace` and

### Features

* `Backend.Phrase` add support for appVersion ([1b4db7a](https://github.com/cschmatzler/idiom/commit/1b4db7a4d785b1e9eb1cc6f592ea107744243ae5))
* `Backend.Phrase`: add `namespace` option ([1b4db7a](https://github.com/cschmatzler/idiom/commit/1b4db7a4d785b1e9eb1cc6f592ea107744243ae5))
* `Backend.Phrase`: Add versioning ([8826094](https://github.com/cschmatzler/idiom/commit/8826094f2b447e135e9b10f292f085eb5a6f70b0))
* add `Idiom.direction/1` ([#23](https://github.com/cschmatzler/idiom/issues/23)) ([7654c03](https://github.com/cschmatzler/idiom/commit/7654c03e33060bb414b78731c20aa4d9925a995b))
* format locales ([#24](https://github.com/cschmatzler/idiom/issues/24)) ([b0d3236](https://github.com/cschmatzler/idiom/commit/b0d3236cbd61ec1a628d75fd985a6b4ab9f42280))
* no longer hardcode defaults for `locale`, `namespace` and ([d760d4d](https://github.com/cschmatzler/idiom/commit/d760d4d88fe8bdc07903dbfb1810b35271e1c05c))


### Bug Fixes

* `Backend.Phrase`: fix `case` order ([f758f81](https://github.com/cschmatzler/idiom/commit/f758f8121b90f527ad969c4d41358eaa034f404f))
* allow locales with more than 3 parts ([10606b5](https://github.com/cschmatzler/idiom/commit/10606b5f52d207b7ce017f3bddd65e23f7c9e2b7))
* correctly mark external resources ([74df0c9](https://github.com/cschmatzler/idiom/commit/74df0c9a4032129ad888e80bb8188222bf9eb79e))
* fix typespecs for Idiom.t/2 and Idiom.t/3 ([aeb2098](https://github.com/cschmatzler/idiom/commit/aeb209883bd98613d0d6c4f7d13ab22a970de0d2))


### Code Refactoring

* internal cleanup ([ae3ec74](https://github.com/cschmatzler/idiom/commit/ae3ec748aef1f9dc69aecd918d67c66c0a801967))

## [0.4.1](https://github.com/cschmatzler/idiom/compare/0.4.0...v0.4.1) (2023-08-24)


### Features

* Add Code of Conduct ([40a6181](https://github.com/cschmatzler/idiom/commit/40a6181b8d87a37a772b1cab0e6f205696586668))
