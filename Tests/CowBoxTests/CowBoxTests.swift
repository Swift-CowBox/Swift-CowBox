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

import XCTest

@testable import CowBox

@CowBox struct Person: CustomStringConvertible, Hashable, Codable {
  @CowBoxNonMutating var id: String
  @CowBoxMutating var name: String
}

@CowBox struct ComplexPerson: CustomStringConvertible, Hashable, Codable {
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

final class CowBoxTests: XCTestCase { }

extension CowBoxTests {
  func testPerson() {
    let p1 = Person(id: "id", name: "name")
    var p2 = p1
    XCTAssertTrue(p1.isIdentical(to: p2))
    
    XCTAssertEqual(p1.id, "id")
    XCTAssertEqual(p1.name, "name")
    XCTAssertEqual(p2.id, "id")
    XCTAssertEqual(p2.name, "name")
    
    p2.name = "new name"
    XCTAssertFalse(p1.isIdentical(to: p2))
    
    XCTAssertEqual(p1.id, "id")
    XCTAssertEqual(p1.name, "name")
    XCTAssertEqual(p2.id, "id")
    XCTAssertEqual(p2.name, "new name")
    
    p2.name = "name"
    XCTAssertFalse(p1.isIdentical(to: p2))
    
    XCTAssertEqual(p1.id, "id")
    XCTAssertEqual(p1.name, "name")
    XCTAssertEqual(p2.id, "id")
    XCTAssertEqual(p2.name, "name")
  }
}

extension CowBoxTests {
  func testPersonCustomStringConvertible() {
    let p1 = Person(id: "id", name: "name")
    XCTAssertEqual(p1.description, "Person(id: id, name: name)")
    
    var p2 = p1
    p2.name = "new name"
    XCTAssertEqual(p2.description, "Person(id: id, name: new name)")
  }
}

extension CowBoxTests {
  func testPersonEquatable() {
    let p1 = Person(id: "id", name: "name")
    var p2 = p1
    XCTAssertEqual(p1, p2)
    
    p2.name = "new name"
    XCTAssertNotEqual(p1, p2)
    
    p2.name = "name"
    XCTAssertEqual(p1, p2)
  }
}

extension CowBoxTests {
  func testPersonHashable() {
    let person = Person(id: "id", name: "name")
    var h1 = Hasher()
    person.hash(into: &h1)
    var h2 = Hasher()
    h2.combine("id")
    h2.combine("name")
    XCTAssertEqual(h1.finalize(), h2.finalize())
  }
}

extension CowBoxTests {
  func testPersonDecodable() {
    XCTAssertNoThrow(
      try {
        let dictionary = [
          "id" : "id",
          "name" : "name",
        ]
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        let person = try JSONDecoder().decode(Person.self, from: data)
        
        XCTAssertEqual(person.id, "id")
        XCTAssertEqual(person.name, "name")
      }()
    )
  }
}

extension CowBoxTests {
  func testPersonEncodable() {
    XCTAssertNoThrow(
      try {
        let person = Person(id: "id", name: "name")
        let data = try JSONEncoder().encode(person)
        let json = try JSONSerialization.jsonObject(with: data)
        let dictionary = try XCTUnwrap(json as? NSDictionary)
        XCTAssertTrue(
          dictionary.isEqual(
            to: [
              "id" : "id",
              "name" : "name",
            ]
          )
        )
      }()
    )
  }
}

extension CowBoxTests {
  func testComplexPerson() {
    let p1 = ComplexPerson(id: "id", name: "name", instanceStoredNonMutating: true, instanceStoredMutating: true, instanceStoredMutatingWithDefault: true)
    
    XCTAssertEqual(p1.id, "id")
    XCTAssertEqual(p1.idWithDefault, "id")
    XCTAssertEqual(p1.name, "name")
    XCTAssertEqual(p1.nameWithDefault, "name")
    XCTAssertEqual(p1.instanceStoredNonMutating, true)
    XCTAssertEqual(p1.instanceStoredNonMutatingWithDefault, false)
    XCTAssertEqual(p1.instanceStoredMutating, true)
    XCTAssertEqual(p1.instanceStoredMutatingWithDefault, true)
    
    var p2 = p1
    
    XCTAssertEqual(p2.id, "id")
    XCTAssertEqual(p2.idWithDefault, "id")
    XCTAssertEqual(p2.name, "name")
    XCTAssertEqual(p2.nameWithDefault, "name")
    XCTAssertEqual(p2.instanceStoredNonMutating, true)
    XCTAssertEqual(p2.instanceStoredNonMutatingWithDefault, false)
    XCTAssertEqual(p2.instanceStoredMutating, true)
    XCTAssertEqual(p2.instanceStoredMutatingWithDefault, true)
    
    p2.name = "new name"
    
    XCTAssertEqual(p1.id, "id")
    XCTAssertEqual(p1.idWithDefault, "id")
    XCTAssertEqual(p1.name, "name")
    XCTAssertEqual(p1.nameWithDefault, "name")
    XCTAssertEqual(p1.instanceStoredNonMutating, true)
    XCTAssertEqual(p1.instanceStoredNonMutatingWithDefault, false)
    XCTAssertEqual(p1.instanceStoredMutating, true)
    XCTAssertEqual(p1.instanceStoredMutatingWithDefault, true)
    
    XCTAssertEqual(p2.id, "id")
    XCTAssertEqual(p2.idWithDefault, "id")
    XCTAssertEqual(p2.name, "new name")
    XCTAssertEqual(p2.nameWithDefault, "name")
    XCTAssertEqual(p2.instanceStoredNonMutating, true)
    XCTAssertEqual(p2.instanceStoredNonMutatingWithDefault, false)
    XCTAssertEqual(p2.instanceStoredMutating, true)
    XCTAssertEqual(p2.instanceStoredMutatingWithDefault, true)
    
    p2.name = "name"
    
    XCTAssertEqual(p1.id, "id")
    XCTAssertEqual(p1.idWithDefault, "id")
    XCTAssertEqual(p1.name, "name")
    XCTAssertEqual(p1.nameWithDefault, "name")
    XCTAssertEqual(p1.instanceStoredNonMutating, true)
    XCTAssertEqual(p1.instanceStoredNonMutatingWithDefault, false)
    XCTAssertEqual(p1.instanceStoredMutating, true)
    XCTAssertEqual(p1.instanceStoredMutatingWithDefault, true)
    
    XCTAssertEqual(p2.id, "id")
    XCTAssertEqual(p2.idWithDefault, "id")
    XCTAssertEqual(p2.name, "name")
    XCTAssertEqual(p2.nameWithDefault, "name")
    XCTAssertEqual(p2.instanceStoredNonMutating, true)
    XCTAssertEqual(p2.instanceStoredNonMutatingWithDefault, false)
    XCTAssertEqual(p2.instanceStoredMutating, true)
    XCTAssertEqual(p2.instanceStoredMutatingWithDefault, true)
  }
}

extension CowBoxTests {
  func testComplexPersonCustomStringConvertible() {
    let p1 = ComplexPerson(id: "id", name: "name", instanceStoredNonMutating: true, instanceStoredMutating: true, instanceStoredMutatingWithDefault: true)
    XCTAssertEqual(p1.description, "ComplexPerson(id: id, idWithDefault: id, name: name, nameWithDefault: name, instanceStoredNonMutating: true, instanceStoredNonMutatingWithDefault: false, instanceStoredMutating: true, instanceStoredMutatingWithDefault: true)")
    
    var p2 = p1
    p2.name = "new name"
    XCTAssertEqual(p2.description, "ComplexPerson(id: id, idWithDefault: id, name: new name, nameWithDefault: name, instanceStoredNonMutating: true, instanceStoredNonMutatingWithDefault: false, instanceStoredMutating: true, instanceStoredMutatingWithDefault: true)")
  }
}

extension CowBoxTests {
  func testComplexPersonEquatable() {
    let p1 = ComplexPerson(id: "id", name: "name", instanceStoredNonMutating: true, instanceStoredMutating: true, instanceStoredMutatingWithDefault: true)
    var p2 = p1
    XCTAssertEqual(p1, p2)
    
    p2.name = "new name"
    XCTAssertNotEqual(p1, p2)
    
    p2.name = "name"
    XCTAssertEqual(p1, p2)
  }
}

extension CowBoxTests {
  func testComplexPersonHashable() {
    let person = ComplexPerson(id: "id", name: "name", instanceStoredNonMutating: true, instanceStoredMutating: true, instanceStoredMutatingWithDefault: true)
    var h1 = Hasher()
    person.hash(into: &h1)
    var h2 = Hasher()
    h2.combine("id")
    h2.combine("id")
    h2.combine("name")
    h2.combine("name")
    h2.combine(true)
    h2.combine(false)
    h2.combine(true)
    h2.combine(true)
    XCTAssertEqual(h1.finalize(), h2.finalize())
  }
}

extension CowBoxTests {
  func testComplexPersonDecodable() {
    XCTAssertNoThrow(
      try {
        let dictionary = [
          "id" : "id",
          "idWithDefault" : "id",
          "name" : "name",
          "nameWithDefault" : "name",
          "instanceStoredNonMutating" : true,
          "instanceStoredNonMutatingWithDefault" : false,
          "instanceStoredMutating" : true,
          "instanceStoredMutatingWithDefault" : true,
        ]
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        let person = try JSONDecoder().decode(ComplexPerson.self, from: data)
        
        XCTAssertEqual(person.id, "id")
        XCTAssertEqual(person.idWithDefault, "id")
        XCTAssertEqual(person.name, "name")
        XCTAssertEqual(person.nameWithDefault, "name")
        XCTAssertEqual(person.instanceStoredNonMutating, true)
        XCTAssertEqual(person.instanceStoredNonMutatingWithDefault, false)
        XCTAssertEqual(person.instanceStoredMutating, true)
        XCTAssertEqual(person.instanceStoredMutatingWithDefault, true)
      }()
    )
  }
}

extension CowBoxTests {
  func testComplexPersonEncodable() {
    XCTAssertNoThrow(
      try {
        let person = ComplexPerson(id: "id", name: "name", instanceStoredNonMutating: true, instanceStoredMutating: true, instanceStoredMutatingWithDefault: true)
        let data = try JSONEncoder().encode(person)
        let json = try JSONSerialization.jsonObject(with: data)
        let dictionary = try XCTUnwrap(json as? NSDictionary)
        XCTAssertTrue(
          dictionary.isEqual(
            to: [
              "id" : "id",
              "idWithDefault" : "id",
              "name" : "name",
              "nameWithDefault" : "name",
              "instanceStoredNonMutating" : true,
              "instanceStoredNonMutatingWithDefault" : false,
              "instanceStoredMutating" : true,
              "instanceStoredMutatingWithDefault" : true,
            ]
          )
        )
      }()
    )
  }
}
