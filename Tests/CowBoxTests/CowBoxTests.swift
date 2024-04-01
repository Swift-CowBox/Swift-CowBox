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
        let dictionary = try XCTUnwrap(json as? Dictionary<String, Any>)
        
        let id = try XCTUnwrap(dictionary["id"] as? String)
        let name = try XCTUnwrap(dictionary["name"] as? String)
        
        XCTAssertEqual(id, "id")
        XCTAssertEqual(name, "name")
      }()
    )
  }
}
