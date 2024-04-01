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

let testMacros: [String: Macro.Type] = [
  "CowBox": CowBoxMacro.self,
  "CowBoxMutating": CowBoxMutatingMacro.self,
  "CowBoxNonMutating": CowBoxNonMutatingMacro.self,
]
#endif

final class CowBoxMacroTests: XCTestCase { }

//  MARK: -
//  MARK: CowBoxNonMutating
//  MARK: -

extension CowBoxMacroTests {
  func testCowBoxNonMutating() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      struct Person {
        @CowBoxNonMutating var id: String
        var name: String
      }
      """,
      expandedSource: #"""
        struct Person {
          var id: String {
            get {
              self._storage.id
            }
          }
          var name: String
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

//  MARK: -
//  MARK: CowBoxMutating
//  MARK: -

extension CowBoxMacroTests {
  func testCowBoxMutating() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      struct Person {
        var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person {
          var id: String
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

//  MARK: -
//  MARK: CowBox
//  MARK: -

extension CowBoxMacroTests {
  func testCowBox() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person {
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

extension CowBoxMacroTests {
  func testCowBoxPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person {
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

//  MARK: -
//  MARK: CowBox CustomStringConvertible
//  MARK: -

extension CowBoxMacroTests {
  func testCowBoxCustomStringConvertible() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: CustomStringConvertible {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: CustomStringConvertible {
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
        
          var description: String {
            var string = "Person("
            string += "id: \(self.id)"
            string += ", "
            string += "name: \(self.name)"
            string += ")"
            return string
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

extension CowBoxMacroTests {
  func testCowBoxCustomStringConvertibleWithDescriptionVariable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: CustomStringConvertible {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        var description: String { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: CustomStringConvertible {
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
        
          var description: String { fatalError() }
        
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

extension CowBoxMacroTests {
  func testCowBoxPublicCustomStringConvertible() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: CustomStringConvertible {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: CustomStringConvertible {
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
        
          public var description: String {
            var string = "Person("
            string += "id: \(self.id)"
            string += ", "
            string += "name: \(self.name)"
            string += ")"
            return string
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

extension CowBoxMacroTests {
  func testCowBoxPublicCustomStringConvertibleWithDescriptionVariable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: CustomStringConvertible {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public var description: String { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: CustomStringConvertible {
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
        
          public var description: String { fatalError() }
        
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
        """#,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

//  MARK: -
//  MARK: CowBox Equatable
//  MARK: -

extension CowBoxMacroTests {
  func testCowBoxEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
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

extension CowBoxMacroTests {
  func testCowBoxEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
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

extension CowBoxMacroTests {
  func testCowBoxPublicEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
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

extension CowBoxMacroTests {
  func testCowBoxPublicEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public static func == (lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
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

//  MARK: -
//  MARK: CowBox Hashable
//  MARK: -

extension CowBoxMacroTests {
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

extension CowBoxMacroTests {
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

extension CowBoxMacroTests {
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

extension CowBoxMacroTests {
  func testCowBoxPublicHashable() throws {
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

extension CowBoxMacroTests {
  func testCowBoxPublicHashableWithEqualFunction() throws {
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

extension CowBoxMacroTests {
  func testCowBoxPublicHashableWithHashFunction() throws {
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

//  MARK: -
//  MARK: CowBox Decodable
//  MARK: -

extension CowBoxMacroTests {
  func testCowBoxDecodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Decodable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: Decodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
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

extension CowBoxMacroTests {
  func testCowBoxDecodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Decodable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        init(from decoder: Decoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Decodable {
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
        
          init(from decoder: Decoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
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

extension CowBoxMacroTests {
  func testCowBoxDecodableWithCodingKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Decodable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        private enum CodingKeys: String, CodingKey {
          case id = "user_id"
          case name
        }
      }
      """,
      expandedSource: #"""
        struct Person: Decodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case name
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicDecodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Decodable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: Decodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicDecodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Decodable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public init(from decoder: Decoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Decodable {
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
        
          public init(from decoder: Decoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
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

extension CowBoxMacroTests {
  func testCowBoxPublicDecodableWithCodingKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Decodable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        private enum CodingKeys: String, CodingKey {
          case id = "user_id"
          case name
        }
      }
      """,
      expandedSource: #"""
        public struct Person: Decodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case name
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
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

//  MARK: -
//  MARK: CowBox Encodable
//  MARK: -

extension CowBoxMacroTests {
  func testCowBoxEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
        
          func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
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

extension CowBoxMacroTests {
  func testCowBoxEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        private enum CodingKeys: String, CodingKey {
          case id = "user_id"
          case name
        }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case name
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
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Encodable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Encodable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
        
          public func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
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

extension CowBoxMacroTests {
  func testCowBoxPublicEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Encodable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        private enum CodingKeys: String, CodingKey {
          case id = "user_id"
          case name
        }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case name
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
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

//  MARK: -
//  MARK: CowBox Codable
//  MARK: -

extension CowBoxMacroTests {
  func testCowBoxCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      }
      """,
      expandedSource: #"""
        struct Person: Codable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        init(from decoder: Decoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Codable {
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
        
          init(from decoder: Decoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Codable {
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
        
          func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
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

extension CowBoxMacroTests {
  func testCowBoxCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
        @CowBoxNonMutating var id: String
        @CowBoxMutating var name: String
      
        private enum CodingKeys: String, CodingKey {
          case id = "user_id"
          case name
        }
      }
      """,
      expandedSource: #"""
        struct Person: Codable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case name
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      }
      """,
      expandedSource: #"""
        public struct Person: Codable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public init(from decoder: Decoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        public func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Codable {
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
        
          public func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case name
          }
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
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

extension CowBoxMacroTests {
  func testCowBoxPublicCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
        @CowBoxNonMutating public var id: String
        @CowBoxMutating public internal(set) var name: String
      
        private enum CodingKeys: String, CodingKey {
          case id = "user_id"
          case name
        }
      }
      """,
      expandedSource: #"""
        public struct Person: Codable {
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
        
          private enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case name
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            self.init(id: id, name: name)
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
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
