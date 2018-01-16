# SwiftPath
[![Build Status](https://travis-ci.org/g-mark/SwiftPath.svg?branch=develop)](https://travis-ci.org/g-mark/SwiftPath)
[![Swift 4 compatible](https://img.shields.io/badge/swift4-compatible-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/SwiftPath.svg)](https://cocoapods.org/pods/SwiftPath)
[![License: MIT](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://raw.githubusercontent.com/g-mark/SwiftPath/master/LICENSE)

JSONPath for Swift

### Problem
Somtimes, you don't want to hard-code the mapping from JSON to your model. You may want a generic way to model data from different sources. You may want to be able to update your remote data structure without having to update your app binary.


### Solution
SwiftPath allows you to keep your data source **and** your data mapping dynamic.


## Installation

SwiftPath is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

### CocoaPods

```ruby
pod "SwiftPath"
```

### Carthage

```
github "g-mark/SwiftPath" "master"
```
