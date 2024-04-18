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
  func testCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) struct Person {
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
  func testCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) struct Person {
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
        
          public init(id: String, name: String) {
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
  func testPublicCowBox() throws {
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

extension CowBoxMacroTests {
  func testPublicCowBoxInitWithInternal() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withInternal) public struct Person {
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
        
          init(id: String, name: String) {
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

extension CowBoxMacroTests {
  func testPublicCowBoxInitWithPublic() throws {
#if canImport(CowBoxMacros)
    assertMacroExpansion(
      """
      @CowBox(init: .withPublic) public struct Person {
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

//extension CowBoxMacroTests {
//  func testNestedCowBox() throws {
//#if canImport(CowBoxMacros)
//    assertMacroExpansion(
//      """
//      struct Parent {
//        @CowBox struct Person {
//          @CowBoxNonMutating var id: String
//          @CowBoxMutating var name: String
//        }
//      }
//      """,
//      expandedSource: #"""
//        struct Parent {
//          struct Person {
//            var id: String {
//              get {
//                self._storage.id
//              }
//            }
//            var name: String {
//              get {
//                self._storage.name
//              }
//              set {
//                if Swift.isKnownUniquelyReferenced(&self._storage) == false {
//                  self._storage = self._storage.copy()
//                }
//                self._storage.name = newValue
//              }
//            }
//
//            private final class _Storage: @unchecked Sendable {
//              let id: String
//              var name: String
//              init(id: String, name: String) {
//                self.id = id
//                self.name = name
//              }
//              func copy() -> _Storage {
//                _Storage(id: self.id, name: self.name)
//              }
//            }
//
//            private var _storage: _Storage
//
//            init(id: String, name: String) {
//              self._storage = _Storage(id: id, name: name)
//            }
//          }
//        }
//        
//        extension Parent.Person: CowBox {
//          func isIdentical(to other: Parent.Person) -> Bool {
//            self._storage === other._storage
//          }
//        }
//        """#,
//      macros: testMacros,
//      indentationWidth: .spaces(2)
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
//}

//extension CowBoxMacroTests {
//  func testNestedCowBoxInitWithInternal() throws {
//#if canImport(CowBoxMacros)
//    assertMacroExpansion(
//      """
//      struct Parent {
//        @CowBox(init: .withInternal) struct Person {
//          @CowBoxNonMutating var id: String
//          @CowBoxMutating var name: String
//        }
//      }
//      """,
//      expandedSource: #"""
//        struct Parent {
//          struct Person {
//            var id: String {
//              get {
//                self._storage.id
//              }
//            }
//            var name: String {
//              get {
//                self._storage.name
//              }
//              set {
//                if Swift.isKnownUniquelyReferenced(&self._storage) == false {
//                  self._storage = self._storage.copy()
//                }
//                self._storage.name = newValue
//              }
//            }
//
//            private final class _Storage: @unchecked Sendable {
//              let id: String
//              var name: String
//              init(id: String, name: String) {
//                self.id = id
//                self.name = name
//              }
//              func copy() -> _Storage {
//                _Storage(id: self.id, name: self.name)
//              }
//            }
//
//            private var _storage: _Storage
//
//            init(id: String, name: String) {
//              self._storage = _Storage(id: id, name: name)
//            }
//          }
//        }
//        
//        extension Parent.Person: CowBox {
//          func isIdentical(to other: Parent.Person) -> Bool {
//            self._storage === other._storage
//          }
//        }
//        """#,
//      macros: testMacros,
//      indentationWidth: .spaces(2)
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
//}

//extension CowBoxMacroTests {
//  func testNestedCowBoxInitWithPublic() throws {
//#if canImport(CowBoxMacros)
//    assertMacroExpansion(
//      """
//      struct Parent {
//        @CowBox(init: .withPublic) struct Person {
//          @CowBoxNonMutating var id: String
//          @CowBoxMutating var name: String
//        }
//      }
//      """,
//      expandedSource: #"""
//        struct Parent {
//          struct Person {
//            var id: String {
//              get {
//                self._storage.id
//              }
//            }
//            var name: String {
//              get {
//                self._storage.name
//              }
//              set {
//                if Swift.isKnownUniquelyReferenced(&self._storage) == false {
//                  self._storage = self._storage.copy()
//                }
//                self._storage.name = newValue
//              }
//            }
//
//            private final class _Storage: @unchecked Sendable {
//              let id: String
//              var name: String
//              init(id: String, name: String) {
//                self.id = id
//                self.name = name
//              }
//              func copy() -> _Storage {
//                _Storage(id: self.id, name: self.name)
//              }
//            }
//
//            private var _storage: _Storage
//
//            public init(id: String, name: String) {
//              self._storage = _Storage(id: id, name: name)
//            }
//          }
//        }
//        
//        extension Parent.Person: CowBox {
//          func isIdentical(to other: Parent.Person) -> Bool {
//            self._storage === other._storage
//          }
//        }
//        """#,
//      macros: testMacros,
//      indentationWidth: .spaces(2)
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
//}

//extension CowBoxMacroTests {
//  func testNestedPublicCowBox() throws {
//#if canImport(CowBoxMacros)
//    assertMacroExpansion(
//      """
//      public struct Parent {
//        @CowBox public struct Person {
//          @CowBoxNonMutating public var id: String
//          @CowBoxMutating public internal(set) var name: String
//        }
//      }
//      """,
//      expandedSource: #"""
//        public struct Parent {
//          public struct Person {
//            public var id: String {
//              get {
//                self._storage.id
//              }
//            }
//            public internal(set) var name: String {
//              get {
//                self._storage.name
//              }
//              set {
//                if Swift.isKnownUniquelyReferenced(&self._storage) == false {
//                  self._storage = self._storage.copy()
//                }
//                self._storage.name = newValue
//              }
//            }
//
//            private final class _Storage: @unchecked Sendable {
//              let id: String
//              var name: String
//              init(id: String, name: String) {
//                self.id = id
//                self.name = name
//              }
//              func copy() -> _Storage {
//                _Storage(id: self.id, name: self.name)
//              }
//            }
//
//            private var _storage: _Storage
//
//            public init(id: String, name: String) {
//              self._storage = _Storage(id: id, name: name)
//            }
//          }
//        }
//        
//        extension Parent.Person: CowBox {
//          public func isIdentical(to other: Parent.Person) -> Bool {
//            self._storage === other._storage
//          }
//        }
//        """#,
//      macros: testMacros,
//      indentationWidth: .spaces(2)
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
//}

//extension CowBoxMacroTests {
//  func testNestedPublicCowBoxInitWithInternal() throws {
//#if canImport(CowBoxMacros)
//    assertMacroExpansion(
//      """
//      public struct Parent {
//        @CowBox(init: .withInternal) public struct Person {
//          @CowBoxNonMutating public var id: String
//          @CowBoxMutating public internal(set) var name: String
//        }
//      }
//      """,
//      expandedSource: #"""
//        public struct Parent {
//          public struct Person {
//            public var id: String {
//              get {
//                self._storage.id
//              }
//            }
//            public internal(set) var name: String {
//              get {
//                self._storage.name
//              }
//              set {
//                if Swift.isKnownUniquelyReferenced(&self._storage) == false {
//                  self._storage = self._storage.copy()
//                }
//                self._storage.name = newValue
//              }
//            }
//
//            private final class _Storage: @unchecked Sendable {
//              let id: String
//              var name: String
//              init(id: String, name: String) {
//                self.id = id
//                self.name = name
//              }
//              func copy() -> _Storage {
//                _Storage(id: self.id, name: self.name)
//              }
//            }
//
//            private var _storage: _Storage
//
//            init(id: String, name: String) {
//              self._storage = _Storage(id: id, name: name)
//            }
//          }
//        }
//        
//        extension Parent.Person: CowBox {
//          public func isIdentical(to other: Parent.Person) -> Bool {
//            self._storage === other._storage
//          }
//        }
//        """#,
//      macros: testMacros,
//      indentationWidth: .spaces(2)
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
//}

//extension CowBoxMacroTests {
//  func testNestedPublicCowBoxInitWithPublic() throws {
//#if canImport(CowBoxMacros)
//    assertMacroExpansion(
//      """
//      public struct Parent {
//        @CowBox(init: .withPublic) public struct Person {
//          @CowBoxNonMutating public var id: String
//          @CowBoxMutating public internal(set) var name: String
//        }
//      }
//      """,
//      expandedSource: #"""
//        public struct Parent {
//          public struct Person {
//            public var id: String {
//              get {
//                self._storage.id
//              }
//            }
//            public internal(set) var name: String {
//              get {
//                self._storage.name
//              }
//              set {
//                if Swift.isKnownUniquelyReferenced(&self._storage) == false {
//                  self._storage = self._storage.copy()
//                }
//                self._storage.name = newValue
//              }
//            }
//
//            private final class _Storage: @unchecked Sendable {
//              let id: String
//              var name: String
//              init(id: String, name: String) {
//                self.id = id
//                self.name = name
//              }
//              func copy() -> _Storage {
//                _Storage(id: self.id, name: self.name)
//              }
//            }
//
//            private var _storage: _Storage
//
//            public init(id: String, name: String) {
//              self._storage = _Storage(id: id, name: name)
//            }
//          }
//        }
//        
//        extension Parent.Person: CowBox {
//          public func isIdentical(to other: Parent.Person) -> Bool {
//            self._storage === other._storage
//          }
//        }
//        """#,
//      macros: testMacros,
//      indentationWidth: .spaces(2)
//    )
//#else
//    throw XCTSkip("macros are only supported when running tests for the host platform")
//#endif
//  }
//}
