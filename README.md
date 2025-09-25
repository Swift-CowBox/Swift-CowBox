# Swift-CowBox 1.2.0

[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwift-CowBox%2FSwift-CowBox%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Swift-CowBox/Swift-CowBox)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwift-CowBox%2FSwift-CowBox%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Swift-CowBox/Swift-CowBox)

[![Builds](https://github.com/Swift-CowBox/Swift-CowBox/actions/workflows/builds.yml/badge.svg?branch=main)](https://github.com/Swift-CowBox/Swift-CowBox/actions/workflows/builds.yml)
[![Tests](https://github.com/Swift-CowBox/Swift-CowBox/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/Swift-CowBox/Swift-CowBox/actions/workflows/tests.yml)

`Swift-CowBox` is a simple set of Swift Macros for adding easy copy-on-write semantics to Swift Structs.

## Background

Since the early days of Swift, most engineers have had an important choice to make when modeling the basic building blocks of their state: do we choose structs (value types), or do we choose classes (reference types)?[^1] Suppose we have a Contacts application for storing collections of People. We might have a simple model type to represent one person:

```swift
//  Here is a Person Struct.
struct Person {
  let id: String
  var name: String
}
//  Here is a Person Class.
class Person {
  let id: String
  var name: String
}
```

It's not an arbitrary distinction; structs and classes come with legit tradeoffs. One of the important benefits from modeling data with immutable value types (like structs) is what James Dempsey calls “local reasoning”:

> Assigning a value [type] to a constant or variable, or passing a value into a function or method, always makes a copy of the value. […] Being able to look through code in a single spot and figure out what is going on is called *local reasoning*. […] One advantage of using value types is that you can be certain no other place in your program can affect the value. You can reason about the code in front of you without needing to know what else is happening elsewhere.[^2]

When choosing between structs and classes, Apple recommends choosing structs by default.[^3] In addition to the benefits of local reasoning, we also see performance benefits from using structs in Swift Collections (like `Array`) that can opt-out of expensive bridging needed to support objects.[^4]

One benefit of object-oriented programming we might lose by modeling data with value types is the ability to quickly copy objects by reference. If our data was modeled as a class, passing data from one place to another means copying one pointer (8 bytes on a 64-bit platform). Our `Person` example is simple, but suppose we have a larger model type with (potentially) hundreds (or thousands) of bytes saved in stored properties. Passing a struct from one place to another means we are copying all those bytes. If we have very large data types (or we are copying many times), this memory pressure can lead to the system terminating other apps that might be running in the background, or even terminating our app while running in the foreground.[^5]

If we want to keep the benefits of modeling our data with an immutable value type (like the ability to reason locally about our code), but we want to leverage object-oriented programming for faster copying, a copy-on-write data structure might be the right direction for us.[^6] With a copy-on-write data structure, we preserve value semantics while leveraging object-oriented programming “under the hood”. To put it another way: the “interface” of our type “presents” as an immutable value type, but the private “implementation” of our type is an object reference.

If you've used the Swift Standard Library Collections (like `Array`), then you’ve already seen copy-on-write in action! The `Array` is a value type from the perspective of the public interface, but it’s built on an object reference internally.[^7] When we pass an instance of an `Array` “by-value”, the `Array` instance copies an object reference. We don’t actually copy all `N` objects in the `Array` until a mutation occurs.

Writing our own copy-on-write data structures has always been an option, but meant writing (and maintaining) a lot of repetitive boilerplate code.[^8] Leveraging Swift Macros[^9], we can finally make it easy to add copy-on-write semantics in just a few steps.

## Requirements

`Swift-CowBox` builds from Swift 5.10 (and up) and `Swift-Syntax` 510.0.0 (up to 603.0.0). There are no explicit platform requirements (other than what is required from `Swift-Syntax`). Please file a GitHub issue if you encounter any compatibility issues while building or deploying.

## Usage

Start by importing the `Swift-CowBox` package as a dependency. Here is an example from Swift Package Manager:

```swift
// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "MyPackage",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13),
  ],
  dependencies: [
    .package(
      url: "https://github.com/swift-cowbox/swift-cowbox.git",
      from: "1.0.0"
    )
  ],
  targets: [
    .target(
      name: "MyPackage",
      dependencies: [
        .product(
          name: "CowBox",
          package: "swift-cowbox"
        )
      ]
    ),
  ]
)
```

Let’s see the macro in action. Suppose we define a simple Swift Struct:

```swift
public struct Person {
  public let id: String
  public var name: String
}
```

This struct is a `Person` with two stored variables: a non-mutable `id` and a mutable `name`. Let’s see how we can use the `CowBox` macros to give this struct copy-on-write semantics:

```swift
import CowBox

@CowBox public struct Person {
  @CowBoxNonMutating public var id: String
  @CowBoxMutating public var name: String
}
```

Our `CowBoxNonMutating` macro attaches to a stored property to indicate we synthesize a getter (we must transform the `let` to `var` before attaching an accessor). We use `CowBoxMutating` to indicate we synthesize a getter and a setter. Let’s expand this macro to see the code that is generated for us:

```swift
public struct Person {
  public var id: String {
    get {
      self._storage.id
    }
  }
  public var name: String {
    get {
      self._storage.name
    }
    set {
      if Swift.isKnownUniquelyReferenced(&self._storage) == false {
        self._storage = self._storage.copy()
      }
      self._storage.name = newValue
    }
  }
  
  private final class _Storage: @unchecked Sendable {
    let id: String
    var name: String
    init(id: String, name: String) {
      self.id = id
      self.name = name
    }
    func copy() -> _Storage {
      _Storage(id: self.id, name: self.name)
    }
  }
  
  private var _storage: _Storage
  
  public init(id: String, name: String) {
    self._storage = _Storage(id: id, name: name)
  }
}

extension Person: CowBox {
  public func isIdentical(to other: Person) -> Bool {
    self._storage === other._storage
  }
}
```

All of this boilerplate to manage and access the underlying storage object reference is provided by the macro. The macro also provides a memberwise initializer. An `isIdentical` function is provided for quickly confirming two struct values point to the same storage object reference.

`CowBox` also knows how to provide support for some common Swift Protocols you might choose to adopt:

```swift
@CowBox public struct Person: CustomStringConvertible, Hashable, Codable {
  @CowBoxNonMutating public var id: String
  @CowBoxMutating public var name: String
}
```

If you adopt one of these protocols in your `CowBox`, the macro with synthesize the conformance for you. If you provide your own conformance, `CowBox` will respect the custom implementation you provided.

The following protocols are currently supported with `CowBox`:
* `CustomStringConvertible`
* `Equatable`
* `Hashable`
* `Decodable`
* `Encodable`
* `Codable`

## Benchmarks

How does `CowBox` affect performance? How does `CowBox` improve CPU or memory usage?

Let's start with an experiment inspired by Jared Khan.[^10] We’ll define a simple Swift Struct with ten 64-bit integers stored as properties:

```swift
struct StructElement {
  // A struct with about 80 bytes
  let a: Int64
  let b: Int64
  let c: Int64
  let d: Int64
  let e: Int64
  let f: Int64
  let g: Int64
  let h: Int64
  let i: Int64
  let j: Int64
}
```

A little quick math tells us every instance of this struct should need at least 640 bits (or 80 bytes) of memory.

Suppose we now build a `CowBox` version of this. What would that look like?

```swift
@CowBox struct CowBoxElement {
  @CowBoxNonMutating var a: Int64
  @CowBoxNonMutating var b: Int64
  @CowBoxNonMutating var c: Int64
  @CowBoxNonMutating var d: Int64
  @CowBoxNonMutating var e: Int64
  @CowBoxNonMutating var f: Int64
  @CowBoxNonMutating var g: Int64
  @CowBoxNonMutating var h: Int64
  @CowBoxNonMutating var i: Int64
  @CowBoxNonMutating var j: Int64
}
```

What does the memory usage look like now? We can assume that creating an instance of `CowBoxElement` from scratch should need at least 88 bytes of memory. We need 640 bits (or 80 bytes) to store the original ten properties. We also need (assuming we are running on a 64 bit platform) an additional 64 bits (or 8 bytes) for a pointer. That’s the memory of our *first* instance. What about our *second* instance (assuming we are copying without making any mutations)? The second instance needs a pointer (8 bytes), but the storage object reference *itself* is shared between both instances. Our two `CowBox` struct instances need (in the aggregate) at least 96 bytes, but our two simple Swift struct instances need at least 160 bytes.

Let’s continue with this experiment and see how these two types perform in large arrays. We’ll start by adding ten million instances of our simple Swift struct to a standard `Swift.Array`, and then try making one mutation on a copy of that array (we append one additional element). This mutation will cause `Array` to copy all `N` elements over to a new instance. We’ll use the Ordo One package for benchmarking memory and CPU.[^11]

```
Memory (resident peak)
╒══════════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Test                                         │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Benchmarks:Array<StructElement> (M)          │     665 │     809 │     809 │     809 │     809 │     809 │     809 │     100 │
├──────────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Benchmarks:Array<StructElement> Copy (M)     │    1531 │    1609 │    1609 │    1609 │    1609 │    1609 │    1609 │     100 │
╘══════════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Time (total CPU)
╒══════════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Test                                         │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Benchmarks:Array<StructElement> (μs) *       │   52704 │   55869 │   56132 │   57311 │   57475 │   57770 │   58006 │     100 │
├──────────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Benchmarks:Array<StructElement> Copy (μs) *  │   51749 │   53281 │   53772 │   54067 │   54690 │   58491 │   59300 │     100 │
╘══════════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛
```

As we expected, the first array needs approximately 800MB of memory (ten million elements each needing 80 bytes). When we make a copy of that array and mutate our copy, the two arrays need (collectively) approximately 1600MB of memory.

Let's try this same experiment with a `CowBox` struct to see how this affects performance:

```
Memory (resident peak)
╒══════════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Test                                         │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Benchmarks:Array<CowBoxElement> (M)          │    1054 │    1057 │    1057 │    1057 │    1057 │    1057 │    1057 │     100 │
├──────────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Benchmarks:Array<CowBoxElement> Copy (M)     │    1107 │    1137 │    1137 │    1137 │    1137 │    1137 │    1137 │     100 │
╘══════════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Time (total CPU)
╒══════════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Test                                         │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Benchmarks:Array<CowBoxElement> (μs) *       │  142901 │  145752 │  146670 │  148111 │  148898 │  149946 │  152233 │     100 │
├──────────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Benchmarks:Array<CowBoxElement> Copy (μs) *  │   30470 │   31130 │   31392 │   32145 │   32653 │   35881 │   44306 │     100 │
╘══════════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛
```

What do we see here? Creating one array of our `CowBox` struct elements uses approximately 20 percent more memory (and is over three times slower) than creating one array of our simple Swift struct elements. The savings come when we need to perform our copies.

Creating one array of our simple Swift struct elements and performing a mutation on a copy needs approximately 1600MB of memory. Performing that same operation on an array of our `CowBox` struct elements needs only 1100MB of memory. For speed, we spent approximately 110ms creating (and mutating a copy of) our original struct array. We spent approximately 178ms creating (and mutating a copy of) our `CowBox` array.

Let assume we repeat this pattern many times. How can we expect this to perform after many copies? Here's what the (estimated) cumulative time spent looks like across multiple copy operations (with zero copies implying the time spent to create our first array):

| Copies | Struct Array | CowBox Array |
| --- | --- | --- | 
| 0 | 56.132ms | 146.67ms |
| 1 | 109.904ms | 178.062ms |
| 2 | 163.676ms | 209.454ms |
| 3 | 217.448ms | 240.846ms |
| 4 | 271.22ms | 272.238ms |
| 5 | 324.992ms | 303.63ms |

We spend a lot more time creating `CowBox` elements from scratch, but if those elements are large, and we expect to copy those elements several times, we quickly come out ahead when measuring the cumulative time spent on those operations.

Another side effect of the `CowBox` macro is we get a cheap and easy way to test for equality when two struct values wrap the same storage object reference. Instead of performing an equality comparison against all stored properties, if we know that two `CowBox` struct instances point to the same storage object reference, the instances must be equal by value. Let’s see how much time that can save us.

As discussed earlier, `Swift.Array` implements copy-on-write semantics: if one `Array` instance is copied (without any mutations), both of those instances point to the same storage object reference. This means that an equality check against those two references can return in constant time (without needing to linearly check through all `N` elements).[^12] To opt-out of this behavior (and benchmark the performance of our elements), we create two different two different `Array` instances from scratch (created from the same elements).

When we try this experiment (comparing an `Array` built from simple Swift structs against an `Array` built from `CowBox` structs), we see that the `Array` built from simple Swift structs performs its equality check over five times slower than the `Array` built from `CowBox` structs.

```
Time (total CPU)
╒══════════════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Test                                         │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞══════════════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ Benchmarks:Array<StructElement> Equal (μs) * │   29070 │   29360 │   29426 │   29606 │   29786 │   29966 │   30058 │     100 │
├──────────────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Benchmarks:Array<CowBoxElement> Equal (μs) * │    4834 │    5005 │    5026 │    5075 │    5186 │    5476 │    5528 │     100 │
╘══════════════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛
```

Many more benchmarks are defined in the `Benchmarks` package. If you choose to experiment with `CowBox` in your own project, you can start with trying to benchmark your current simple Swift structs for memory and CPU. Then, try and benchmark those same structs using the `CowBox` macro. You would expect to measure the biggest performance improvements with complex struct elements that need to be copied many times through the course of your app lifecycle.

## SwiftUI Sample App

Please reference the `Swift-CowBox-Sample`[^13] repo to see `CowBox` used in a SwiftUI application. We will also run Benchmarks and Instruments to measure the performance improvements from migrating to copy-on-write semantics.

## Known Issues

Please reference the `CowBoxClient` executable for examples of known issues and limitations of the macro (along with some suggested workarounds).

Please file a GitHub issue for any new issues or limitations you encounter.

Thanks!

## Copyright

Copyright 2024 North Bronson Software

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[^1]: https://developer.apple.com/swift/blog/?id=10
[^2]: https://www.swift.org/documentation/articles/value-and-reference-types.html
[^3]: https://developer.apple.com/documentation/swift/choosing-between-structures-and-classes#Choose-Structures-by-Default
[^4]: https://github.com/apple/swift/blob/swift-5.10-RELEASE/docs/OptimizationTips.rst#advice-use-value-types-in-array
[^5]: https://developer.apple.com/documentation/xcode/reduce-terminations-in-your-app#Understand-termination-reasons
[^6]: https://en.wikipedia.org/wiki/Immutable_object#Copy-on-write
[^7]: https://www.mikeash.com/pyblog/friday-qa-2015-04-17-lets-build-swiftarray.html
[^8]: https://www.youtube.com/watch?v=iLDldae64xE
[^9]: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/
[^10]: https://jaredkhan.com/blog/swift-copy-on-write#many-structs
[^11]: https://github.com/ordo-one/package-benchmark
[^12]: https://github.com/apple/swift/blob/release/5.10/stdlib/public/core/Array.swift#L1774-L1777
[^13]: https://github.com/Swift-CowBox/Swift-CowBox-Sample
