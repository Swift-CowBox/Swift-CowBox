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

public protocol CowBox {
  func isIdentical(to other: Self) -> Bool
}

@attached(member, names: named(_Storage), named(_storage), named(init), named(==), named(hash), named(CodingKeys), named(encode), named(description))
@attached(extension, conformances: CowBox, names: named(isIdentical))
public macro CowBox() = #externalMacro(
  module: "CowBoxMacros",
  type: "CowBoxMacro"
)

@attached(accessor)
public macro CowBoxMutating() = #externalMacro(
  module: "CowBoxMacros",
  type: "CowBoxMutatingMacro"
)

@attached(accessor)
public macro CowBoxNonMutating() = #externalMacro(
  module: "CowBoxMacros",
  type: "CowBoxNonMutatingMacro"
)
