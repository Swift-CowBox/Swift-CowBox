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

final class CodableTests: XCTestCase { }

extension CodableTests {
  func testCowBoxCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
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
        struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxInitWithInternalCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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
        struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxInitWithPublicCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
        struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
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
        public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
        public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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
        public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
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
        
          init(from decoder: Decoder) throws { fatalError() }
        
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

extension CodableTests {
  func testCowBoxInitWithInternalCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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
        
          init(from decoder: Decoder) throws { fatalError() }
        
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

extension CodableTests {
  func testCowBoxInitWithPublicCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
        
          init(from decoder: Decoder) throws { fatalError() }
        
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

extension CodableTests {
  func testPublicCowBoxCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws { fatalError() }
        
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws { fatalError() }
        
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws { fatalError() }
        
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

extension CodableTests {
  func testCowBoxCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxInitWithInternalCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxInitWithPublicCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person: Codable {
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
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxInitWithInternalCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testCowBoxInitWithPublicCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        struct Person: Codable {
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
        
          init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person: Codable {
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
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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
      
        private enum CodingKeys: String, CodingKey { }
      }
      """,
      expandedSource: #"""
        public struct Person: Codable {
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
        
          public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let id = try values.decode(String.self, forKey: .id)
            let name = try values.decode(String.self, forKey: .name)
            let nameWithDefault = try values.decode(String .self, forKey: .nameWithDefault)
            let instanceStoredNonMutating = try values.decode(Bool.self, forKey: .instanceStoredNonMutating)
            let instanceStoredMutating = try values.decode(Bool.self, forKey: .instanceStoredMutating)
            let instanceStoredMutatingWithDefault = try values.decode(Bool .self, forKey: .instanceStoredMutatingWithDefault)
            self.init(id: id, name: name, nameWithDefault: nameWithDefault, instanceStoredNonMutating: instanceStoredNonMutating, instanceStoredMutating: instanceStoredMutating, instanceStoredMutatingWithDefault: instanceStoredMutatingWithDefault)
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
