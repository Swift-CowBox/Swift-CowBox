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
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testCowBoxInitWithPackageHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxInitWithInternalHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxInitWithPackageHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxInitWithPublicHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPublicCowBoxInitWithPackageHashable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testCowBoxInitWithPackageHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
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
        struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxInitWithInternalHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxInitWithPackageHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPackageCowBoxInitWithPublicHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
        
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
        
          package func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
  func testPublicCowBoxInitWithPackageHashableWithEqualFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public static func ==(lhs: Person, rhs: Person) -> Bool { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
            hasher.combine(self.idWithDefault)
            hasher.combine(self.name)
            hasher.combine(self.nameWithDefault)
            hasher.combine(self.instanceStoredNonMutating)
            hasher.combine(self.instanceStoredNonMutatingWithDefault)
            hasher.combine(self.instanceStoredMutating)
            hasher.combine(self.instanceStoredMutatingWithDefault)
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
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
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
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
            }
          }
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) { fatalError() }
        
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

extension HashableTests {
  func testCowBoxInitWithInternalHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
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
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
            }
          }
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) { fatalError() }
        
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

extension HashableTests {
  func testCowBoxInitWithPackageHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
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
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
            }
          }
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
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

extension HashableTests {
  func testCowBoxInitWithPublicHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
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
          var idWithDefault: String {
            get {
              self._storage.idWithDefault
            }
          }
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          func hash(into hasher: inout Hasher) { fatalError() }
        
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

extension HashableTests {
  func testPackageCowBoxHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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

extension HashableTests {
  func testPackageCowBoxInitWithInternalHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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

extension HashableTests {
  func testPackageCowBoxInitWithPackageHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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

extension HashableTests {
  func testPackageCowBoxInitWithPublicHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        package func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          package func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
            self.instanceStoredNonMutating = instanceStoredNonMutating
            self.instanceStoredMutating = instanceStoredMutating
            self.instanceStoredMutatingWithDefault = instanceStoredMutatingWithDefault
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        
          package static func ==(lhs: Person, rhs: Person) -> Bool {
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

extension HashableTests {
  func testPublicCowBoxHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) { fatalError() }
        
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

extension HashableTests {
  func testPublicCowBoxInitWithInternalHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) { fatalError() }
        
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

extension HashableTests {
  func testPublicCowBoxInitWithPackageHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) { fatalError() }
        
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
        
          package init(id: String, name: String, nameWithDefault: String = "name", instanceStoredNonMutating: Bool, instanceStoredMutating: Bool, instanceStoredMutatingWithDefault: Bool = false) {
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

extension HashableTests {
  func testPublicCowBoxInitWithPublicHashableWithHashFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Hashable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id" // comment
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name" // comment
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false // comment
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false // comment
        var instanceComputed: Bool { false }
      
        public func hash(into hasher: inout Hasher) { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Hashable {
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
          private(set) var name: String {
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
          private(set) var nameWithDefault: String {
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
        
          public func hash(into hasher: inout Hasher) { fatalError() }
        
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
