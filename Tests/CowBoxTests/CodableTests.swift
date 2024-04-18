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

extension CodableTests {
  func testCowBoxInitWithInternalCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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

extension CodableTests {
  func testCowBoxInitWithPublicCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
        
          public init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxCodable() throws {
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
        
          init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodable() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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

extension CodableTests {
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

extension CodableTests {
  func testCowBoxInitWithInternalCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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

extension CodableTests {
  func testCowBoxInitWithPublicCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
        
          public init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxCodableWithDecodeInitializer() throws {
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
        
          init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodableWithDecodeInitializer() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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

extension CodableTests {
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

extension CodableTests {
  func testCowBoxInitWithInternalCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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

extension CodableTests {
  func testCowBoxInitWithPublicCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
        
          public init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxCodableWithEncodeFunction() throws {
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
        
          init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodableWithEncodeFunction() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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

extension CodableTests {
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

extension CodableTests {
  func testCowBoxInitWithInternalCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person: Codable {
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

extension CodableTests {
  func testCowBoxInitWithPublicCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person: Codable {
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
        
          public init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxCodableWithKeys() throws {
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

extension CodableTests {
  func testPublicCowBoxInitWithInternalCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person: Codable {
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
        
          init(id: String, name: String) {
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

extension CodableTests {
  func testPublicCowBoxInitWithPublicCodableWithKeys() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person: Codable {
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
