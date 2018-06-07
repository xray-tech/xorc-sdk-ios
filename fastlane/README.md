fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all unit the tests and generates reports in `fastlane/reports`

You can optionnaly specify the xcode version

e.g 'fastlane test xc_version:8.2'
### ios sdk_build
```
fastlane ios sdk_build
```

### ios sdk_compile
```
fastlane ios sdk_compile
```
Compiles the SDK project

e.g: fastlane sdk_compile xc_version:7.3.1

To list all versions: xcenv versions

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
