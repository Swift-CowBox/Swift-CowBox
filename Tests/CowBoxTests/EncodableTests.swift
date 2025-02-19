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

final class EncodableTests: XCTestCase { }

extension EncodableTests {
  func testCowBoxEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testCowBoxInitWithInternalEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testCowBoxInitWithPackageEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testCowBoxInitWithPublicEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxInitWithInternalEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxInitWithPackageEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxInitWithPublicEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxInitWithInternalEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxInitWithPackageEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxInitWithPublicEncodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
          }
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testCowBoxEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testCowBoxInitWithInternalEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testCowBoxInitWithPackageEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testCowBoxInitWithPublicEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPackageCowBoxEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        package func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          package func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPackageCowBoxInitWithInternalEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        package func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          package func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPackageCowBoxInitWithPackageEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        package func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          package func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPackageCowBoxInitWithPublicEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        package func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          package func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPublicCowBoxEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        public func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          public func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPublicCowBoxInitWithInternalEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        public func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          public func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPublicCowBoxInitWithPackageEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        public func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          public func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testPublicCowBoxInitWithPublicEncodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        public func encode(to encoder: any Encoder) throws { fatalError() }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          public func encode(to encoder: any Encoder) throws { fatalError() }
        
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
        
          private enum CodingKeys: String, CodingKey {
            case id
            case idWithDefault
            case name
            case nameWithDefault
            case instanceStoredNonMutating
            case instanceStoredNonMutatingWithDefault
            case instanceStoredMutating
            case instanceStoredMutatingWithDefault
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

extension EncodableTests {
  func testCowBoxEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testCowBoxInitWithInternalEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testCowBoxInitWithPackageEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testCowBoxInitWithPublicEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxInitWithInternalEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxInitWithPackageEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPackageCowBoxInitWithPublicEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) package struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        package struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxInitWithInternalEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxInitWithPackageEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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

extension EncodableTests {
  func testPublicCowBoxInitWithPublicEncodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Encodable {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      
        static let typeStoredNonMutating: Bool = false
        static var typeStoredMutating: Bool = false
        static var typeComputed: Bool { false }
        let instanceStoredNonMutating: Bool
        let instanceStoredNonMutatingWithDefault: Bool = false
        var instanceStoredMutating: Bool
        var instanceStoredMutatingWithDefault: Bool = false
        var instanceComputed: Bool { false }
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        public struct Person: Encodable {
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
          let instanceStoredNonMutatingWithDefault: Bool = false
          var instanceStoredMutating: Bool
          var instanceStoredMutatingWithDefault: Bool = false
          var instanceComputed: Bool { false }
        
          private enum CodingKeys: String, CodingKey { }
        
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
        
          public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.idWithDefault, forKey: .idWithDefault)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.nameWithDefault, forKey: .nameWithDefault)
            try container.encode(self.instanceStoredNonMutating, forKey: .instanceStoredNonMutating)
            try container.encode(self.instanceStoredNonMutatingWithDefault, forKey: .instanceStoredNonMutatingWithDefault)
            try container.encode(self.instanceStoredMutating, forKey: .instanceStoredMutating)
            try container.encode(self.instanceStoredMutatingWithDefault, forKey: .instanceStoredMutatingWithDefault)
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
