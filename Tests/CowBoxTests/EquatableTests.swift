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

final class EquatableTests: XCTestCase { }

extension EquatableTests {
  func testCowBoxEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating var name: String
        @CowBoxMutating var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          static let typeStoredNonMutating: Bool = false
          static var typeStoredMutating: Bool = false
          static var typeComputed: Bool { false }
          let instanceStoredNonMutating: Bool
          let instanceStoredNonMutatingWithDefault: Bool = false // comment
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false // comment
          var instanceComputed: Bool { false }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          static func ==(lhs: Person, rhs: Person) -> Bool {
            guard lhs.instanceStoredNonMutating == rhs.instanceStoredNonMutating else {
              return false
            }
            guard lhs.instanceStoredNonMutatingWithDefault == rhs.instanceStoredNonMutatingWithDefault else {
              return false
            }
            guard lhs.instanceStoredMutating == rhs.instanceStoredMutating else {
              return false
            }
            guard lhs.instanceStoredMutatingWithDefault == rhs.instanceStoredMutatingWithDefault else {
              return false
            }
            if lhs._storage === rhs._storage {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.idWithDefault == rhs.idWithDefault else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            guard lhs.nameWithDefault == rhs.nameWithDefault else {
              return false
            }
            return true
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

extension EquatableTests {
  func testCowBoxInitWithInternalEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating var name: String
        @CowBoxMutating var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          static let typeStoredNonMutating: Bool = false
          static var typeStoredMutating: Bool = false
          static var typeComputed: Bool { false }
          let instanceStoredNonMutating: Bool
          let instanceStoredNonMutatingWithDefault: Bool = false // comment
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false // comment
          var instanceComputed: Bool { false }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          static func ==(lhs: Person, rhs: Person) -> Bool {
            guard lhs.instanceStoredNonMutating == rhs.instanceStoredNonMutating else {
              return false
            }
            guard lhs.instanceStoredNonMutatingWithDefault == rhs.instanceStoredNonMutatingWithDefault else {
              return false
            }
            guard lhs.instanceStoredMutating == rhs.instanceStoredMutating else {
              return false
            }
            guard lhs.instanceStoredMutatingWithDefault == rhs.instanceStoredMutatingWithDefault else {
              return false
            }
            if lhs._storage === rhs._storage {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.idWithDefault == rhs.idWithDefault else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            guard lhs.nameWithDefault == rhs.nameWithDefault else {
              return false
            }
            return true
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

extension EquatableTests {
  func testCowBoxInitWithPublicEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating var name: String
        @CowBoxMutating var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          static let typeStoredNonMutating: Bool = false
          static var typeStoredMutating: Bool = false
          static var typeComputed: Bool { false }
          let instanceStoredNonMutating: Bool
          let instanceStoredNonMutatingWithDefault: Bool = false // comment
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false // comment
          var instanceComputed: Bool { false }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          public init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          static func ==(lhs: Person, rhs: Person) -> Bool {
            guard lhs.instanceStoredNonMutating == rhs.instanceStoredNonMutating else {
              return false
            }
            guard lhs.instanceStoredNonMutatingWithDefault == rhs.instanceStoredNonMutatingWithDefault else {
              return false
            }
            guard lhs.instanceStoredMutating == rhs.instanceStoredMutating else {
              return false
            }
            guard lhs.instanceStoredMutatingWithDefault == rhs.instanceStoredMutatingWithDefault else {
              return false
            }
            if lhs._storage === rhs._storage {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.idWithDefault == rhs.idWithDefault else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            guard lhs.nameWithDefault == rhs.nameWithDefault else {
              return false
            }
            return true
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

extension EquatableTests {
  func testPublicCowBoxEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxNonMutating public var idWithDefault: String = "id" // comment
        @CowBoxMutating public internal(set) var name: String
        @CowBoxMutating public internal(set) var nameWithDefault: String = "name" // comment
      
        public static let typeStoredNonMutating: Bool = false
        public static var typeStoredMutating: Bool = false
        public static var typeComputed: Bool { false }
        public let instanceStoredNonMutating: Bool
        public let instanceStoredNonMutatingWithDefault: Bool = false // comment
        public var instanceStoredMutating: Bool
        public var instanceStoredMutatingWithDefault: Bool = false // comment
        public var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          public internal(set) var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          public static let typeStoredNonMutating: Bool = false
          public static var typeStoredMutating: Bool = false
          public static var typeComputed: Bool { false }
          public let instanceStoredNonMutating: Bool
          public let instanceStoredNonMutatingWithDefault: Bool = false // comment
          public var instanceStoredMutating: Bool
          public var instanceStoredMutatingWithDefault: Bool = false // comment
          public var instanceComputed: Bool { false }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          public init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          public static func ==(lhs: Person, rhs: Person) -> Bool {
            guard lhs.instanceStoredNonMutating == rhs.instanceStoredNonMutating else {
              return false
            }
            guard lhs.instanceStoredNonMutatingWithDefault == rhs.instanceStoredNonMutatingWithDefault else {
              return false
            }
            guard lhs.instanceStoredMutating == rhs.instanceStoredMutating else {
              return false
            }
            guard lhs.instanceStoredMutatingWithDefault == rhs.instanceStoredMutatingWithDefault else {
              return false
            }
            if lhs._storage === rhs._storage {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.idWithDefault == rhs.idWithDefault else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            guard lhs.nameWithDefault == rhs.nameWithDefault else {
              return false
            }
            return true
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

extension EquatableTests {
  func testPublicCowBoxInitWithInternalEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxNonMutating public var idWithDefault: String = "id" // comment
        @CowBoxMutating public internal(set) var name: String
        @CowBoxMutating public internal(set) var nameWithDefault: String = "name" // comment
      
        public static let typeStoredNonMutating: Bool = false
        public static var typeStoredMutating: Bool = false
        public static var typeComputed: Bool { false }
        public let instanceStoredNonMutating: Bool
        public let instanceStoredNonMutatingWithDefault: Bool = false // comment
        public var instanceStoredMutating: Bool
        public var instanceStoredMutatingWithDefault: Bool = false // comment
        public var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          public internal(set) var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          public static let typeStoredNonMutating: Bool = false
          public static var typeStoredMutating: Bool = false
          public static var typeComputed: Bool { false }
          public let instanceStoredNonMutating: Bool
          public let instanceStoredNonMutatingWithDefault: Bool = false // comment
          public var instanceStoredMutating: Bool
          public var instanceStoredMutatingWithDefault: Bool = false // comment
          public var instanceComputed: Bool { false }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          public static func ==(lhs: Person, rhs: Person) -> Bool {
            guard lhs.instanceStoredNonMutating == rhs.instanceStoredNonMutating else {
              return false
            }
            guard lhs.instanceStoredNonMutatingWithDefault == rhs.instanceStoredNonMutatingWithDefault else {
              return false
            }
            guard lhs.instanceStoredMutating == rhs.instanceStoredMutating else {
              return false
            }
            guard lhs.instanceStoredMutatingWithDefault == rhs.instanceStoredMutatingWithDefault else {
              return false
            }
            if lhs._storage === rhs._storage {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.idWithDefault == rhs.idWithDefault else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            guard lhs.nameWithDefault == rhs.nameWithDefault else {
              return false
            }
            return true
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

extension EquatableTests {
  func testPublicCowBoxInitWithPublicEquatable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxNonMutating public var idWithDefault: String = "id" // comment
        @CowBoxMutating public internal(set) var name: String
        @CowBoxMutating public internal(set) var nameWithDefault: String = "name" // comment
      
        public static let typeStoredNonMutating: Bool = false
        public static var typeStoredMutating: Bool = false
        public static var typeComputed: Bool { false }
        public let instanceStoredNonMutating: Bool
        public let instanceStoredNonMutatingWithDefault: Bool = false // comment
        public var instanceStoredMutating: Bool
        public var instanceStoredMutatingWithDefault: Bool = false // comment
        public var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          public internal(set) var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          public static let typeStoredNonMutating: Bool = false
          public static var typeStoredMutating: Bool = false
          public static var typeComputed: Bool { false }
          public let instanceStoredNonMutating: Bool
          public let instanceStoredNonMutatingWithDefault: Bool = false // comment
          public var instanceStoredMutating: Bool
          public var instanceStoredMutatingWithDefault: Bool = false // comment
          public var instanceComputed: Bool { false }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          public init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          public static func ==(lhs: Person, rhs: Person) -> Bool {
            guard lhs.instanceStoredNonMutating == rhs.instanceStoredNonMutating else {
              return false
            }
            guard lhs.instanceStoredNonMutatingWithDefault == rhs.instanceStoredNonMutatingWithDefault else {
              return false
            }
            guard lhs.instanceStoredMutating == rhs.instanceStoredMutating else {
              return false
            }
            guard lhs.instanceStoredMutatingWithDefault == rhs.instanceStoredMutatingWithDefault else {
              return false
            }
            if lhs._storage === rhs._storage {
              return true
            }
            guard lhs.id == rhs.id else {
              return false
            }
            guard lhs.idWithDefault == rhs.idWithDefault else {
              return false
            }
            guard lhs.name == rhs.name else {
              return false
            }
            guard lhs.nameWithDefault == rhs.nameWithDefault else {
              return false
            }
            return true
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

extension EquatableTests {
  func testCowBoxEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating var name: String
        @CowBoxMutating var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          static let typeStoredNonMutating: Bool = false
          static var typeStoredMutating: Bool = false
          static var typeComputed: Bool { false }
          let instanceStoredNonMutating: Bool
          let instanceStoredNonMutatingWithDefault: Bool = false // comment
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false // comment
          var instanceComputed: Bool { false }
        
          static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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

extension EquatableTests {
  func testCowBoxInitWithInternalEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating var name: String
        @CowBoxMutating var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          static let typeStoredNonMutating: Bool = false
          static var typeStoredMutating: Bool = false
          static var typeComputed: Bool { false }
          let instanceStoredNonMutating: Bool
          let instanceStoredNonMutatingWithDefault: Bool = false // comment
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false // comment
          var instanceComputed: Bool { false }
        
          static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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

extension EquatableTests {
  func testCowBoxInitWithPublicEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Equatable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating var name: String
        @CowBoxMutating var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        struct Person: Equatable {
          var id: String {
            get {
              self._storage.id
            }
          }
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          static let typeStoredNonMutating: Bool = false
          static var typeStoredMutating: Bool = false
          static var typeComputed: Bool { false }
          let instanceStoredNonMutating: Bool
          let instanceStoredNonMutatingWithDefault: Bool = false // comment
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false // comment
          var instanceComputed: Bool { false }
        
          static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          public init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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

extension EquatableTests {
  func testPublicCowBoxEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxNonMutating public var idWithDefault: String = "id" // comment
        @CowBoxMutating public internal(set) var name: String
        @CowBoxMutating public internal(set) var nameWithDefault: String = "name" // comment
      
        public static let typeStoredNonMutating: Bool = false
        public static var typeStoredMutating: Bool = false
        public static var typeComputed: Bool { false }
        public let instanceStoredNonMutating: Bool
        public let instanceStoredNonMutatingWithDefault: Bool = false // comment
        public var instanceStoredMutating: Bool
        public var instanceStoredMutatingWithDefault: Bool = false // comment
        public var instanceComputed: Bool { false }
      
        public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          public internal(set) var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          public static let typeStoredNonMutating: Bool = false
          public static var typeStoredMutating: Bool = false
          public static var typeComputed: Bool { false }
          public let instanceStoredNonMutating: Bool
          public let instanceStoredNonMutatingWithDefault: Bool = false // comment
          public var instanceStoredMutating: Bool
          public var instanceStoredMutatingWithDefault: Bool = false // comment
          public var instanceComputed: Bool { false }
        
          public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          public init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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

extension EquatableTests {
  func testPublicCowBoxInitWithInternalEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxNonMutating public var idWithDefault: String = "id" // comment
        @CowBoxMutating public internal(set) var name: String
        @CowBoxMutating public internal(set) var nameWithDefault: String = "name" // comment
      
        public static let typeStoredNonMutating: Bool = false
        public static var typeStoredMutating: Bool = false
        public static var typeComputed: Bool { false }
        public let instanceStoredNonMutating: Bool
        public let instanceStoredNonMutatingWithDefault: Bool = false // comment
        public var instanceStoredMutating: Bool
        public var instanceStoredMutatingWithDefault: Bool = false // comment
        public var instanceComputed: Bool { false }
      
        public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          public internal(set) var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          public static let typeStoredNonMutating: Bool = false
          public static var typeStoredMutating: Bool = false
          public static var typeComputed: Bool { false }
          public let instanceStoredNonMutating: Bool
          public let instanceStoredNonMutatingWithDefault: Bool = false // comment
          public var instanceStoredMutating: Bool
          public var instanceStoredMutatingWithDefault: Bool = false // comment
          public var instanceComputed: Bool { false }
        
          public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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

extension EquatableTests {
  func testPublicCowBoxInitWithPublicEquatableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Equatable {
        @CowBoxNonMutating public var id: String
        @CowBoxNonMutating public var idWithDefault: String = "id" // comment
        @CowBoxMutating public internal(set) var name: String
        @CowBoxMutating public internal(set) var nameWithDefault: String = "name" // comment
      
        public static let typeStoredNonMutating: Bool = false
        public static var typeStoredMutating: Bool = false
        public static var typeComputed: Bool { false }
        public let instanceStoredNonMutating: Bool
        public let instanceStoredNonMutatingWithDefault: Bool = false // comment
        public var instanceStoredMutating: Bool
        public var instanceStoredMutatingWithDefault: Bool = false // comment
        public var instanceComputed: Bool { false }
      
        public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Equatable {
          public var id: String {
            get {
              self._storage.id
            }
          }
          public var idWithDefault: String {
            get {
              self._storage.idWithDefault
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
          public internal(set) var nameWithDefault: String {
            get {
              self._storage.nameWithDefault
            }
            set {
              if Swift.isKnownUniquelyReferenced(&self._storage) == false {
                self._storage = self._storage.copy()
              }
              self._storage.nameWithDefault = newValue
            }
          }
        
          public static let typeStoredNonMutating: Bool = false
          public static var typeStoredMutating: Bool = false
          public static var typeComputed: Bool { false }
          public let instanceStoredNonMutating: Bool
          public let instanceStoredNonMutatingWithDefault: Bool = false // comment
          public var instanceStoredMutating: Bool
          public var instanceStoredMutatingWithDefault: Bool = false // comment
          public var instanceComputed: Bool { false }
        
          public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
          private final class _Storage: @unchecked Sendable {
            let id: String
            let idWithDefault: String
            var name: String
            var nameWithDefault: String
            init(id: String, idWithDefault: String, name: String, nameWithDefault: String) {
              self.id = id
              self.idWithDefault = idWithDefault
              self.name = name
              self.nameWithDefault = nameWithDefault
            }
            func copy() -> _Storage {
              _Storage(id: self.id, idWithDefault: self.idWithDefault, name: self.name, nameWithDefault: self.nameWithDefault)
            }
          }
        
          private var _storage: _Storage
        
          public init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
