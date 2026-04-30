# SwiftPath

[JSONPath](https://www.rfc-editor.org/rfc/rfc9535.html) for Swift

### Problem
Sometimes, you don't want to hard-code the mapping from JSON to your model. You may want a generic way to model data from different sources. You may want to be able to update your remote data structure without having to update your app binary.


### Solution
SwiftPath allows you to keep your data source **and** your data mapping dynamic.


## Installation

SwiftPath is available through Swift Package Manager.

```swift
.package(url: "https://github.com/g-mark/SwiftPath.git", from: "1.0.0")
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

## RFC 9535 Compatibility

This section summarizes SwiftPath's public string parser against [RFC 9535](https://www.rfc-editor.org/rfc/rfc9535.html), Section 2.

> [!NOTE]
> SwiftPath does _not_ use or return Nodelist types. It returns only the value results of the path query.

### Supported RFC functionality

| RFC section | What's supported | Example | Notes |
| --- | --- | --- | --- |
| 2.2. Root Identifier | Root query identifier. | `$` | Returns the full input value. |
| 2.3.1. Name Selector | Dot names and quoted bracket names. | `$.store`, `$['store']` | Quoted names support RFC escape decoding, including `\n`, `\"`, `\'`, `\\`, `\/`, `\uXXXX`, and surrogate pairs. |
| 2.3.2. Wildcard Selector | Object member values and array elements. | `$.*`, `$[*]` | Both wildcard forms work on objects and arrays. Primitive inputs select nothing. |
| 2.3.3. Index Selector | Positive and negative array indexes. | `$[0]`, `$[-1]` | Leading-zero forms are rejected. Out-of-range indexes and non-array inputs select nothing. |
| 2.3.4. Array Slice Selector | Start, end, step, omitted bounds, reverse slices, clamping, and empty-result semantics. | `$[1:5:2]`, `$[::-1]`, `$[::]` | Leading-zero forms and integers outside the RFC I-JSON exact range are rejected. |
| 2.3.5. Filter Selector | Array filters with existence tests, literal comparisons, `!`, `&&`, `||`, and parentheses. | `$.books[?(@.price < 10)]` | Filter paths can use root/current identifiers, dot properties, and escaped quoted properties. |
| 2.5.1. Child Segment | Dot child segments and bracket child segments. | `$.store['book'][0]` | Comma-separated selectors are supported for repeated names and repeated indexes. |

### Unsupported RFC functionality

| RFC section | What's unsupported | Example | Notes |
| --- | --- | --- | --- |
| 2.1. JSONPath nodelist model | Full nodelist API with node locations or normalized paths. | `$.store.book[0].title` | SwiftPath returns `JsonValue?`, using arrays for multi-value results. |
| 2.3.5. Filter Selector | Object filters, path-to-path comparisons, function expressions, and the full RFC filter type system. | `$[?(@.price < $.limit)]` | Current filter support is intentionally a subset. |
| 2.4.1-2.4.3. Function expression model | RFC function typing, conversions, and well-typedness rules. | `$[?(length(@.tags) > 0)]` | No public RFC function-expression parser. |
| 2.4.4. `length()` | RFC `length()` function extension. | `length(@.name)` | Not parsed from JSONPath strings. |
| 2.4.5. `count()` | RFC `count()` function extension. | `count(@.*)` | Not supported. |
| 2.4.6. `match()` | RFC full-string regular-expression match. | `match(@.name, 'A.*')` | Not supported. |
| 2.4.7. `search()` | RFC substring regular-expression search. | `search(@.name, 'foo')` | Not supported. |
| 2.4.8. `value()` | RFC single-node value conversion. | `value(@.price)` | Not supported. |
| 2.5.1. Child Segment | General mixed selector lists. | `$[0,'name',*]` | Homogeneous name lists and index lists are supported; arbitrary mixed selector lists are not. |
| 2.5.2. Descendant Segment | Recursive descendant selection. | `$..author`, `$..[?(@.isbn)]` | Not supported. |

### Extended functionality

SwiftPath also includes non-RFC conveniences:

| Feature | Example | Notes |
| --- | --- | --- |
| Property projection | `$['name', 'price']` | Selects several object properties at once. |
| Property renaming | `$['value'=>'id']` | Projects a property under a different output name. |
| Collated property lookup on arrays | `$.books.price` | Applies a property lookup to each object in an array and returns the collected values. |

Property projection:

```js
// Given:
{ "name": "Dune", "price": 10, "extra": true }

// Path:
$['name', 'price']

// Result:
{ "name": "Dune", "price": 10 }
```

Property renaming:

```js
// Given:
{ "name": "Dune", "value": 42 }

// Path:
$['name', 'value'=>'id']

// Result:
{ "name": "Dune", "id": 42 }
```

Collated property lookup on arrays:

```js
// Given:
{
  "books": [
    { "title": "Dune", "price": 10 },
    { "title": "Snow Crash", "price": 14 }
  ]
}

// Path:
$.books.price

// Result:
[10, 14]
```

