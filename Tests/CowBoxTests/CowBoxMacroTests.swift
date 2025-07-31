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

final class CowBoxMacroTests: XCTestCase { }

extension CowBoxMacroTests {
  func testCowBox() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person {
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
        struct Person {
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
  func testCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person {
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
        struct Person {
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
  func testCowBoxInitWithPackage() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person {
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
        struct Person {
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
  func testCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person {
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
        struct Person {
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
  func testPackageCowBox() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person {
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
        package struct Person {
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
  func testPackageCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person {
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
        package struct Person {
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
  func testPackageCowBoxInitWithPackage() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person {
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
        package struct Person {
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
  func testPackageCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) package struct Person {
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
        package struct Person {
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
  func testPublicCowBox() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person {
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
        public struct Person {
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
  func testPublicCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person {
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
        public struct Person {
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
  func testPublicCowBoxInitWithPackage() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person {
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
        public struct Person {
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
  func testPublicCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person {
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
        public struct Person {
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
  func testNestedCowBox() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      struct Parent {
        @CowBox struct Person {
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
      }
      """,
      expandedSource: #"""
        struct Parent {
          struct Person {
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
  func testNestedCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      struct Parent {
        @CowBox(init: .withInternal) struct Person {
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
      }
      """,
      expandedSource: #"""
        struct Parent {
          struct Person {
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
  func testNestedCowBoxInitWithPackage() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      struct Parent {
        @CowBox(init: .withPackage) struct Person {
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
      }
      """,
      expandedSource: #"""
        struct Parent {
          struct Person {
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
  func testNestedCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      struct Parent {
        @CowBox(init: .withPublic) struct Person {
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
      }
      """,
      expandedSource: #"""
        struct Parent {
          struct Person {
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
  func testNestedPackageCowBox() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox package struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          package struct Person {
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
  func testNestedPackageCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox(init: .withInternal) package struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          package struct Person {
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
  func testNestedPackageCowBoxInitWithPackage() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox(init: .withPackage) package struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          package struct Person {
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
  func testNestedPackageCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox(init: .withPublic) package struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          package struct Person {
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
  func testNestedPublicCowBox() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox public struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          public struct Person {
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
  func testNestedPublicCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox(init: .withInternal) public struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          public struct Person {
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
  func testNestedPublicCowBoxInitWithPackage() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox(init: .withPackage) public struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          public struct Person {
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
  func testNestedPublicCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      public struct Parent {
        @CowBox(init: .withPublic) public struct Person {
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
      }
      """,
      expandedSource: #"""
        public struct Parent {
          public struct Person {
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
  func testCowBoxExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        struct Person {
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
        
          init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testCowBoxInitWithInternalExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        struct Person {
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
        
          init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testCowBoxInitWithPackageExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        struct Person {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testCowBoxInitWithPublicExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        struct Person {
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
        
          public init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testPackageCowBoxExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox package struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        package struct Person {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        }
        
        extension Person: CowBox {
          package func isIdentical(to other: Person) -> Bool {
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
  func testPackageCowBoxInitWithInternalExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) package struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        package struct Person {
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
        
          init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        }
        
        extension Person: CowBox {
          package func isIdentical(to other: Person) -> Bool {
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
  func testPackageCowBoxInitWithPackageExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) package struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        package struct Person {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        }
        
        extension Person: CowBox {
          package func isIdentical(to other: Person) -> Bool {
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
  func testPackageCowBoxInitWithPublicExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) package struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        package struct Person {
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
        
          public init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
          }
        }
        
        extension Person: CowBox {
          package func isIdentical(to other: Person) -> Bool {
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
  func testPublicCowBoxExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox public struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        public struct Person {
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
        
          public init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testPublicCowBoxInitWithInternalExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        public struct Person {
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
        
          init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testPublicCowBoxInitWithPackageExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPackage) public struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        public struct Person {
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
        
          package init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testPublicCowBoxInitWithPublicExtension() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person {
        @CowBoxNonMutating var id: String
        @CowBoxNonMutating var idWithDefault: String = "id"
        @CowBoxMutating private(set) var name: String
        @CowBoxMutating private(set) var nameWithDefault: String = "name"
      }
      """,
      expandedSource: #"""
        public struct Person {
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
        
          public init(id: String, name: String, nameWithDefault: String = "name") {
            self._storage = _Storage(id: id, idWithDefault: "id", name: name, nameWithDefault: nameWithDefault)
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
  func testCowBoxClassDiagnostic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
        """
        @CowBox class Person { }
        """,
        expandedSource: #"""
          class Person { }
          """#,
        diagnostics: [
          DiagnosticSpec(
            message: CowBoxMacro.SimpleDiagnosticMessage.notStruct.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros,
        indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension CowBoxMacroTests {
  func testCowBoxEnumDiagnostic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
        """
        @CowBox enum Person { }
        """,
        expandedSource: #"""
          enum Person { }
          """#,
        diagnostics: [
          DiagnosticSpec(
            message: CowBoxMacro.SimpleDiagnosticMessage.notStruct.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros,
        indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}

extension CowBoxMacroTests {
  func testCowBoxActorDiagnostic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
        """
        @CowBox actor Person { }
        """,
        expandedSource: #"""
          actor Person { }
          """#,
        diagnostics: [
          DiagnosticSpec(
            message: CowBoxMacro.SimpleDiagnosticMessage.notStruct.message,
            line: 1,
            column: 1
          )
        ],
        macros: testMacros,
        indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}
