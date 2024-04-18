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

/// A type that can be compared for identity equality.
///
public protocol CowBox {
  /// Returns a Boolean value indicating whether two instances are equal by identity.
  ///
  /// - Parameters:
  ///   - other: An instance to compare.
  func isIdentical(to other: Self) -> Bool
}

/// If the value is `.withPublic`, the generated member-wise initializer is `public`. If the value is `.withInternal`, the generated member-wise initializer is `internal`.
public enum CowBoxInit {
  /// The generated member-wise initializer is `internal`.
  case withInternal
  /// The generated member-wise initializer is `public`.
  case withPublic
}

/// Generates a CowBox for a struct.
///
/// - Parameters:
///   - init: If the value is `.withPublic`, the generated member-wise initializer is `public`. If the value is `.withInternal`, the generated member-wise initializer is `internal`.
@attached(member, names: named(_Storage), named(_storage), named(init), named(==), named(hash), named(CodingKeys), named(encode), named(description))
@attached(extension, conformances: CowBox, names: named(isIdentical))
public macro CowBox(init: CowBoxInit) = #externalMacro(
  module: "CowBoxMacros",
  type: "CowBoxMacro"
)

/// Generates a CowBox for a struct.
///
/// If the struct is `public`, the generated member-wise initializer is `public`. If the struct is not `public`, the generated member-wise initializer is `internal`.
@attached(member, names: named(_Storage), named(_storage), named(init), named(==), named(hash), named(CodingKeys), named(encode), named(description))
@attached(extension, conformances: CowBox, names: named(isIdentical))
public macro CowBox() = #externalMacro(
  module: "CowBoxMacros",
  type: "CowBoxMacro"
)

/// Generates a CowBox getter and setter for a stored instance property.
///
@attached(accessor)
public macro CowBoxMutating() = #externalMacro(
  module: "CowBoxMacros",
  type: "CowBoxMutatingMacro"
)

/// Generates a CowBox getter for a stored instance property.
///
@attached(accessor)
public macro CowBoxNonMutating() = #externalMacro(
  module: "CowBoxMacros",
  type: "CowBoxNonMutatingMacro"
)
