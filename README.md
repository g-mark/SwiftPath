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

## Documentation

SwiftPath is a Swift implementation of JSONPath, which allows you to extract a subset of data from a larger chunk of JSON.

### Sipmle usage


### Wildcards
You can add a wildcard to objects to convert the current object to an array of it's values:

```js
// Given:
{
  "books" : {
    "one" : { "title": "one" },
    "two" : { "title": "two" },
    "three" : { "title": "three" }
  }
}

// When using this path:
$.books.*

// Then you'll get this output:
[ { "title": "one" }, { "title": "two" }, { "title": "three" } ]
```

### Mapping properties

This is a difference from the JSONPath 'spec'.  With SwiftPath, you can re-map property names to match your model in code.  When collecting a subset of properties, you can do things like this (renamning the `value` property to `id`):

```js
// Given:
[
  {"name": "one", "value": 1, "extra": true },
  {"name": "one", "value": 2, "extra": true },
  {"name": "one", "value": 3, "extra": true }
]

// When using this path:
$['name', 'value'=>'id']

// Then you'll get this output:
[
  {"name": "one", "id": 1 },
  {"name": "one", "id": 2 },
  {"name": "one", "id": 3 }
]
```

## Publishing

To publish a new version of SwiftPath:
1. Update version number in `SwiftPath.podspec`
1. Create a release/version branch off of `release` with version: e.g., `release/#.#.#`
1. Merge `develop` into release/version branch
1. Create PR into `release` from release/version branch
1. Once CI passess, tag it with `#.#.#`, merge into `release`, and delete the release/version branch
1. Run `pod trunk push SwiftLint.podspec`
