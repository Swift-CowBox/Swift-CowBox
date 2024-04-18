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

import CowBox

//  MARK: KNOWN ISSUES
//  MARK: -

//  MARK: PROTOCOL IN EXTENSION
//  CowBox fails to synthesize conformance when protocol is adopted in extension.

//  @CowBox struct Person {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String
//  }
//
//  extension Person: CustomStringConvertible {
//
//  }

//  Workaround:
//  Move protocol adoption to main declaration.

//  @CowBox struct Person: CustomStringConvertible {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String
//  }

//  MARK: IMPLICIT PROTOCOL INHERITANCE
//  CowBox will fail to synthesize conformance to `Child` if struct adopts `Parent` and does not explicitly adopt `Child`.

//  @CowBox struct Person: Comparable {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String
//
//    static func < (lhs: Person, rhs: Person) -> Bool {
//      fatalError()
//    }
//  }

//  Workaround:
//  Explicitly adopt `Child` and `Parent`.

//  @CowBox struct Person: Equatable, Comparable {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String
//
//    static func < (lhs: Person, rhs: Person) -> Bool {
//      fatalError()
//    }
//  }

//  MARK: MEMBERWISE INIT WITH OPTIONALS
//  CowBox fails to synthesize memberwise initializer default `nil` parameters.

//  @CowBox struct Person {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String?
//  }
//
//  let _ = Person(id: "id")

//  Workaround:
//  Define a new initializer or explicitly pass `nil` to the default memberwise initializer.

//  @CowBox struct Person {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String?
//  }
//
//  extension Person {
//    init(id: String) {
//      self.init(
//        id: id,
//        name: nil
//      )
//    }
//  }
//
//  let _ = Person(id: "id")
//  let _ = Person(id: "id", name: nil)

//  MARK: STORED PROPERTIES WITH DEFAULT VALUES
//  Not currently supported.

//  @CowBox struct Person {
//    @CowBoxNonMutating var id: String = "id"
//    @CowBoxMutating var name: String = "name"
//  }

//  MARK: STORED PROPERTIES WITH INFERRED TYPES
//  Not currently supported.

//  @CowBox struct Person {
//    @CowBoxNonMutating var id = "id"
//    @CowBoxMutating var name = "name"
//  }

//  MARK: STORED PROPERTIES NOT MANAGED BY COWBOX
//  Not currently supported.

//  @CowBox struct Person {
//    let id: String
//    var name: String
//  }

//  MARK: LEGACY HASHABLE CONFORMANCE
//  CowBox does not synthesize `Hashable` conformance respecting the value of a custom `hashValue` variable.

//  @CowBox struct Person: Hashable {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String
//
//    var hashValue: Int { 1 }
//  }

//  WORKAROUND:
//  Move `Hashable` conformance to extension.

//  @CowBox struct Person: Equatable {
//    @CowBoxNonMutating var id: String
//    @CowBoxMutating var name: String
//  }
//
//  extension Person: Hashable {
//    var hashValue: Int { 1 }
//  }
