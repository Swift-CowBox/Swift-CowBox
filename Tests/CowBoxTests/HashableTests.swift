//
//  Copyright 2024 North Bronson Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CowBoxMacros)
import CowBoxMacros
#endif

final class HashableTests: XCTestCase { }

extension HashableTests {
  func testCowBoxHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxInitWithInternalHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxInitWithPublicHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxInitWithInternalHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          public static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxInitWithPublicHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxInitWithInternalHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxInitWithPublicHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxInitWithInternalHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxInitWithPublicHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.name)
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxInitWithInternalHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testCowBoxInitWithPublicHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Hashable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String {
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
        
          func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        }
        
        extension Person: CowBox {
          func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          public static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxInitWithInternalHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          init(id: String, name: String) {
            self._storage = _Storage(id: id, name: name)
          }
        
          public static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension HashableTests {
  func testPublicCowBoxInitWithPublicHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Hashable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public internal(set) var name: String {
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
        
          public func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          public static func == (lhs: Person, rhs: Person) -> Bool {
            if lhs.isIdentical(to: rhs) {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            return true
          }
        }
        
        extension Person: CowBox {
          public func isIdentical(to other: Person) -> Bool {
            self._storage === other._storage
          }
        }
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}
