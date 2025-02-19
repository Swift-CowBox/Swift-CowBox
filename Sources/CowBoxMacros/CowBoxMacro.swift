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

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

//  https://github.com/apple/swift/blob/swift-5.10-RELEASE/include/swift/AST/Decl.h#L4839-L4857
/*
 enum class KnownDerivableProtocolKind : uint8_t {
   RawRepresentable,
   OptionSet,
   CaseIterable,
   Comparable,
   Equatable,
   Hashable,
   BridgedNSError,
   CodingKey,
   Encodable,
   Decodable,
   AdditiveArithmetic,
   Differentiable,
   Identifiable,
   Actor,
   DistributedActor,
   DistributedActorSystem,
 };
 */

@main struct ModelPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    CowBoxMacro.self,
    CowBoxMutatingMacro.self,
    CowBoxNonMutatingMacro.self,
  ]
}

enum CowBoxAccessControl: String {
  case isPackage
  case isPublic
}

enum CowBoxInit: String {
  case withInternal
  case withPackage
  case withPublic
}

public struct CowBoxMacro {
  static let storageClassName = "_Storage"
  static let storageVariableName = "_storage"
  static let copyFunctionName = "copy"
}

extension CowBoxMacro {
  struct SimpleDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
  }
}

extension CowBoxMacro.SimpleDiagnosticMessage {
  static var notStruct: Self {
    Self(
      message: "Not a Struct.",
      diagnosticID: MessageID(
        domain: "CowBoxMacro",
        id: "NotStruct"
      ),
      severity: .error
    )
  }
}

extension CowBoxMacro.SimpleDiagnosticMessage {
  static var notProperty: Self {
    Self(
      message: "Not a Property.",
      diagnosticID: MessageID(
        domain: "CowBoxMacro",
        id: "NotProperty"
      ),
      severity: .error
    )
  }
}

extension CowBoxMacro.SimpleDiagnosticMessage {
  static var notStoredProperty: Self {
    Self(
      message: "Not a Stored Property.",
      diagnosticID: MessageID(
        domain: "CowBoxMacro",
        id: "NotStoredProperty"
      ),
      severity: .error
    )
  }
}

extension CowBoxMacro.SimpleDiagnosticMessage {
  static var notInstanceProperty: Self {
    Self(
      message: "Not an Instance Property.",
      diagnosticID: MessageID(
        domain: "CowBoxMacro",
        id: "NotInstanceProperty"
      ),
      severity: .error
    )
  }
}

extension CowBoxMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard
      let declaration = declaration.as(StructDeclSyntax.self)
    else {
      context.diagnose(
        Diagnostic(
          node: node,
          message: SimpleDiagnosticMessage.notStruct
        )
      )
      throw SimpleDiagnosticMessage.notStruct
    }
    
    let variables = declaration.instanceStoredVariables
    
    var expansion = [
      DeclSyntax(
        self.storageClass(variables: variables)
      ),
      DeclSyntax(
        self.storageVariable()
      ),
      DeclSyntax(
        self.initializer(
          accessControl: declaration.accessControl,
          initArgument: node.initArgument,
          variables: variables
        )
      ),
    ]
    
    if declaration.isCustomStringConvertible,
       declaration.hasDescriptionVariable == false {
      expansion.append(
        DeclSyntax(
          self.descriptionVariable(
            accessControl: declaration.accessControl,
            type: declaration.name,
            variables: variables
          )
        )
      )
    }
    
    if declaration.isEquatable,
       declaration.hasEqualFunction == false {
      expansion.append(
        DeclSyntax(
          self.equalFunction(
            accessControl: declaration.accessControl,
            type: declaration.name,
            variables: variables
          )
        )
      )
    }
    
    if declaration.isHashable,
       declaration.hasHashFunction == false {
      expansion.append(
        DeclSyntax(
          self.hashFunction(
            accessControl: declaration.accessControl,
            variables: variables
          )
        )
      )
    }
    
    if declaration.isDecodable || declaration.isEncodable,
       declaration.hasCodingKeys == false {
      expansion.append(
        DeclSyntax(
          self.codingKeys(variables: variables)
        )
      )
    }
    
    if declaration.isDecodable,
       declaration.hasDecodeInitializer == false {
      expansion.append(
        DeclSyntax(
          self.decodeInitializer(
            accessControl: declaration.accessControl,
            variables: variables
          )
        )
      )
    }
    
    if declaration.isEncodable,
       declaration.hasEncodeFunction == false {
      expansion.append(
        DeclSyntax(
          self.encodeFunction(
            accessControl: declaration.accessControl,
            variables: variables
          )
        )
      )
    }
    
    return expansion
  }
}

extension CowBoxMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard
      let declaration = declaration.as(StructDeclSyntax.self)
    else {
      let message = SimpleDiagnosticMessage.notStruct
      context.diagnose(
        Diagnostic(
          node: node,
          message: message
        )
      )
      throw message
    }
    
    let isCowBox = declaration.instanceStoredVariables.allSatisfy { $0.isCowBox }
    guard
      isCowBox
    else {
      return []
    }
    
    let expansion = [
      self.cowBoxExtension(
        accessControl: declaration.accessControl,
        with: type
      ),
    ]
    
    return expansion
  }
}

extension CowBoxMacro {
  static func storageClass(variables: [VariableDeclSyntax]) -> ClassDeclSyntax {
    //  https://github.com/swiftlang/swift-evolution/blob/main/proposals/0412-strict-concurrency-for-global-variables.md
    
    let variables = variables.filter { $0.isCowBox }
    let parameters = variables.compactMap { $0.functionParameter }
    
    return ClassDeclSyntax(
      modifiers: DeclModifierListSyntax {
        DeclModifierSyntax(name: TokenSyntax(.keyword(.private), presence: .present))
        DeclModifierSyntax(name: TokenSyntax(.keyword(.final), presence: .present))
      },
      name: TokenSyntax(.identifier(CowBoxMacro.storageClassName), presence: .present),
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(type: TypeSyntax("@unchecked Sendable"))
      }
    ) {
      for variable in variables {
        if variable.isCowBoxNonMutating {
          variable.nonMutating
        }
        if variable.isCowBoxMutating {
          variable.mutating
        }
      }
      self.storageClassInitializer(parameters: parameters)
      self.storageClassCopyFunction(parameters: parameters)
    }
  }
}

extension CowBoxMacro {
  static func storageClassInitializer(parameters: [FunctionParameterSyntax]) -> InitializerDeclSyntax {
    InitializerDeclSyntax(
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          FunctionParameterListSyntax {
            for parameter in parameters {
              FunctionParameterSyntax(
                firstName: parameter.firstName,
                type: parameter.type
              )
            }
          }
        }
      )
    ) {
      for parameter in parameters {
        "self.\(parameter.firstName) = \(parameter.firstName)"
      }
    }
  }
}

extension CowBoxMacro {
  static func storageClassCopyFunction(parameters: [FunctionParameterSyntax]) -> FunctionDeclSyntax {
    FunctionDeclSyntax(
      name: TokenSyntax(.identifier(CowBoxMacro.copyFunctionName), presence: .present),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax { },
        returnClause: ReturnClauseSyntax(
          type: IdentifierTypeSyntax(
            name: TokenSyntax(.identifier(CowBoxMacro.storageClassName), presence: .present)
          )
        )
      )
    ) {
      FunctionCallExprSyntax(
        calledExpression: DeclReferenceExprSyntax(
          baseName: TokenSyntax(.identifier(CowBoxMacro.storageClassName), presence: .present)
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax {
          for parameter in parameters {
            LabeledExprSyntax(
              label: parameter.firstName,
              colon: .colonToken(),
              expression: DeclReferenceExprSyntax(
                baseName: "self.\(parameter.firstName)"
              )
            )
          }
        },
        rightParen: .rightParenToken()
      )
    }
  }
}

extension CowBoxMacro {
  static func storageVariable() -> VariableDeclSyntax {
    //  https://github.com/swiftlang/swift-evolution/blob/main/proposals/0412-strict-concurrency-for-global-variables.md
    
    VariableDeclSyntax(
      modifiers: DeclModifierListSyntax {
//        DeclModifierSyntax(
//          name: .keyword(.nonisolated),
//          detail: DeclModifierDetailSyntax(detail: .keyword(.unsafe))
//        )
        DeclModifierSyntax(name: .keyword(.private))
      },
      bindingSpecifier: TokenSyntax(.keyword(.var), presence: .present),
      bindings: PatternBindingListSyntax {
        PatternBindingSyntax(
          pattern: IdentifierPatternSyntax(
            identifier: TokenSyntax(.identifier(CowBoxMacro.storageVariableName), presence: .present)
          ),
          typeAnnotation: TypeAnnotationSyntax(
            type: IdentifierTypeSyntax(
              name: TokenSyntax(.identifier(CowBoxMacro.storageClassName), presence: .present)
            )
          )
        )
      }
    )
  }
}

extension CowBoxMacro {
  static func initializer(
    accessControl: CowBoxAccessControl?,
    initArgument: CowBoxInit?,
    variables: [VariableDeclSyntax]
  ) -> InitializerDeclSyntax {
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0242-default-values-memberwise.md
    
    let parameters: [FunctionParameterSyntax] = variables.compactMap { variable in
      if variable.initializer != nil {
        if variable.isCowBoxNonMutating {
          return nil
        }
        if variable.bindingSpecifier.tokenKind == .keyword(.let) {
          return nil
        }
      }
      return variable.functionParameter
    }
    
    let arguments: [LabeledExprSyntax] = variables.compactMap { variable in
      guard
        let identifier = variable.identifierPattern?.identifier
      else {
        return nil
      }
      
      if variable.isCowBoxNonMutating {
        if let initializer = variable.initializer  {
          return LabeledExprSyntax(
            label: identifier.trimmed,
            colon: .colonToken(),
            expression: initializer.value.trimmed
          )
        }
        return LabeledExprSyntax(
          label: identifier.trimmed,
          colon: .colonToken(),
          expression: DeclReferenceExprSyntax(
            baseName: identifier.trimmed
          )
        )
      }
      
      if variable.isCowBoxMutating {
        return LabeledExprSyntax(
          label: identifier.trimmed,
          colon: .colonToken(),
          expression: DeclReferenceExprSyntax(
            baseName: identifier.trimmed
          )
        )
      }
      
      return nil
    }
    
    return InitializerDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if let initArgument = initArgument {
          if case .withPackage = initArgument {
            DeclModifierSyntax(name: .keyword(.package))
          }
          if case .withPublic = initArgument {
            DeclModifierSyntax(name: .keyword(.public))
          }
        } else {
          if case .isPackage = accessControl {
            DeclModifierSyntax(name: .keyword(.package))
          }
          if case .isPublic = accessControl {
            DeclModifierSyntax(name: .keyword(.public))
          }
        }
      },
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          FunctionParameterListSyntax(parameters)
        }
      )
    ) {
      for variable in variables {
        if let identifier = variable.identifierPattern?.identifier,
           variable.isCowBox == false {
          if variable.initializer != nil,
             variable.bindingSpecifier.tokenKind == .keyword(.let) {
            
          } else {
            "self.\(identifier.trimmed) = \(identifier.trimmed)"
          }
        }
      }
      InfixOperatorExprSyntax(
        leftOperand: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(
            baseName: TokenSyntax(.keyword(.`self`), presence: .present)
          ),
          declName: DeclReferenceExprSyntax(
            baseName: TokenSyntax(.identifier(CowBoxMacro.storageVariableName), presence: .present)
          )
        ),
        operator: AssignmentExprSyntax(),
        rightOperand: FunctionCallExprSyntax(
          calledExpression: DeclReferenceExprSyntax(
            baseName: TokenSyntax(.identifier(CowBoxMacro.storageClassName), presence: .present)
          ),
          leftParen: .leftParenToken(),
          arguments: LabeledExprListSyntax {
            for argument in arguments {
              argument
            }
          },
          rightParen: .rightParenToken()
        )
      )
    }
  }
}

extension CowBoxMacro {
  static func descriptionVariable(
    accessControl: CowBoxAccessControl?,
    type: TokenSyntax,
    variables: [VariableDeclSyntax]
  ) -> VariableDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/stdlib/public/core/OutputStream.swift#L339-L355
    
    let array: [CodeBlockItemListSyntax] = variables.compactMap { variable in
      guard
        let identifier = variable.identifierPattern?.identifier
      else {
        return nil
      }
      return CodeBlockItemListSyntax {
        "string += \"\(identifier.trimmed): \\(String(describing: self.\(identifier.trimmed)))\""
      }
    }
    
    let items = array.joined(
      separator: CodeBlockItemListSyntax {
        "string += \", \""
      }
    )
    
    return VariableDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if case .isPackage = accessControl {
          DeclModifierSyntax(name: .keyword(.package))
        }
        if case .isPublic = accessControl {
          DeclModifierSyntax(name: .keyword(.public))
        }
      },
      bindingSpecifier: TokenSyntax(.keyword(.var), presence: .present),
      bindings: PatternBindingListSyntax {
        PatternBindingSyntax(
          pattern: IdentifierPatternSyntax(
            identifier: TokenSyntax(.identifier("description"), presence: .present)
          ),
          typeAnnotation: TypeAnnotationSyntax(
            type: IdentifierTypeSyntax(
              name: TokenSyntax(.identifier("String"), presence: .present)
            )
          ),
          accessorBlock: AccessorBlockSyntax(
            accessors: .getter(
              CodeBlockItemListSyntax {
                "var string = \"\(type.trimmed)(\""
                for item in items {
                  item
                }
                "string += \")\""
                "return string"
              }
            )
          )
        )
      }
    )
  }
}

extension CowBoxMacro {
  static func equalFunction(
    accessControl: CowBoxAccessControl?,
    type: TokenSyntax,
    variables: [VariableDeclSyntax]
  ) -> FunctionDeclSyntax {
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0185-synthesize-equatable-hashable.md
    
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceEquatableHashable.cpp#L292-L341
    
#if canImport(SwiftSyntax600)
    let equal = TokenSyntax.binaryOperator("==")
#else
    //  https://github.com/apple/swift-syntax/issues/2615
    let equal = TokenSyntax.identifier("==")
#endif
    
    return FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if case .isPackage = accessControl {
          DeclModifierSyntax(name: .keyword(.package))
        }
        if case .isPublic = accessControl {
          DeclModifierSyntax(name: .keyword(.public))
        }
        DeclModifierSyntax(name: TokenSyntax(.keyword(.static), presence: .present))
      },
      name: equal,
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "lhs: \(type.trimmed)"
          "rhs: \(type.trimmed)"
        },
        returnClause: ReturnClauseSyntax(
          type: IdentifierTypeSyntax(name: "Bool")
        )
      )
    ) {
      for variable in variables {
        if let identifier = variable.identifierPattern?.identifier,
           variable.isCowBox == false {
          "guard lhs.\(identifier.trimmed) == rhs.\(identifier.trimmed) else { return false }"
        }
      }
      "if lhs._storage === rhs._storage { return true }"
      for variable in variables {
        if let identifier = variable.identifierPattern?.identifier,
           variable.isCowBox {
          "guard lhs.\(identifier.trimmed) == rhs.\(identifier.trimmed) else { return false }"
        }
      }
      "return true"
    }
  }
}

extension CowBoxMacro {
  static func hashFunction(
    accessControl: CowBoxAccessControl?,
    variables: [VariableDeclSyntax]
  ) -> FunctionDeclSyntax {
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0185-synthesize-equatable-hashable.md
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0206-hashable-enhancements.md
    
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceEquatableHashable.cpp#L778-L820
    
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceEquatableHashable.cpp#L574-L595
    //  TODO: SUPPORT LEGACY HASH VALUE
    
    FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if case .isPackage = accessControl {
          DeclModifierSyntax(name: .keyword(.package))
        }
        if case .isPublic = accessControl {
          DeclModifierSyntax(name: .keyword(.public))
        }
      },
      name: TokenSyntax(.identifier("hash"), presence: .present),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "into hasher: inout Hasher"
        }
      )
    ) {
      for variable in variables {
        if let identifier = variable.identifierPattern?.identifier {
          "hasher.combine(self.\(identifier.trimmed))"
        }
      }
    }
  }
}

extension CowBoxMacro {
  static func codingKeys(variables: [VariableDeclSyntax]) -> EnumDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceCodable.cpp#L216-L244
    
    EnumDeclSyntax(
      modifiers: DeclModifierListSyntax {
        DeclModifierSyntax(name: .keyword(.private))
      },
      name: "CodingKeys",
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(type: TypeSyntax("String"))
        InheritedTypeSyntax(type: TypeSyntax("CodingKey"))
      }
    ) {
      for variable in variables {
        if let identifier = variable.identifierPattern?.identifier {
          EnumCaseDeclSyntax(
            elements: EnumCaseElementListSyntax {
              EnumCaseElementSyntax(name: identifier)
            }
          )
        }
      }
    }
  }
}

extension CowBoxMacro {
  static func decodeInitializer(
    accessControl: CowBoxAccessControl?,
    variables: [VariableDeclSyntax]
  ) -> InitializerDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceCodable.cpp#L1304-L1541
    
    let variables: [VariableDeclSyntax] = variables.filter { variable in
      if variable.initializer != nil {
        if variable.isCowBoxNonMutating {
          return false
        }
        if variable.bindingSpecifier.tokenKind == .keyword(.let) {
          return false
        }
      }
      return true
    }
    
    let arguments: [LabeledExprSyntax] = variables.compactMap { variable in
      guard
        let identifier = variable.identifierPattern?.identifier
      else {
        return nil
      }
      return LabeledExprSyntax(
        label: identifier.trimmed,
        colon: .colonToken(),
        expression: DeclReferenceExprSyntax(
          baseName: identifier.trimmed
        )
      )
    }
    
#if canImport(SwiftSyntax600)
    let effectSpecifiers = FunctionEffectSpecifiersSyntax(
      throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws))
    )
#else
    let effectSpecifiers = FunctionEffectSpecifiersSyntax(
      throwsSpecifier: .keyword(.throws)
    )
#endif
    
    return InitializerDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if case .isPackage = accessControl {
          DeclModifierSyntax(name: .keyword(.package))
        }
        if case .isPublic = accessControl {
          DeclModifierSyntax(name: .keyword(.public))
        }
      },
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "from decoder: any Decoder"
        },
        effectSpecifiers: effectSpecifiers
      )
    ) {
      "let values = try decoder.container(keyedBy: CodingKeys.self)"
      for variable in variables {
        if let identifier = variable.identifierPattern?.identifier,
           let type = variable.type {
          "let \(identifier.trimmed) = try values.decode(\(type).self, forKey: .\(identifier.trimmed))"
        }
      }
      FunctionCallExprSyntax(
        calledExpression: MemberAccessExprSyntax(
          base: DeclReferenceExprSyntax(
            baseName: TokenSyntax(.keyword(.self), presence: .present)
          ),
          declName: DeclReferenceExprSyntax(
            baseName: TokenSyntax(.keyword(.`init`), presence: .present)
          )
        ),
        leftParen: .leftParenToken(),
        arguments: LabeledExprListSyntax {
          for argument in arguments {
            argument
          }
        },
        rightParen: .rightParenToken()
      )
    }
  }
}

extension CowBoxMacro {
  static func encodeFunction(
    accessControl: CowBoxAccessControl?,
    variables: [VariableDeclSyntax]
  ) -> FunctionDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceCodable.cpp#L790-L928
    
#if canImport(SwiftSyntax600)
    let effectSpecifiers = FunctionEffectSpecifiersSyntax(
      throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws))
    )
#else
    let effectSpecifiers = FunctionEffectSpecifiersSyntax(
      throwsSpecifier: .keyword(.throws)
    )
#endif
    
    return FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if case .isPackage = accessControl {
          DeclModifierSyntax(name: .keyword(.package))
        }
        if case .isPublic = accessControl {
          DeclModifierSyntax(name: .keyword(.public))
        }
      },
      name: TokenSyntax(.identifier("encode"), presence: .present),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "to encoder: any Encoder"
        },
        effectSpecifiers: effectSpecifiers
      )
    ) {
      "var container = encoder.container(keyedBy: CodingKeys.self)"
      for variable in variables {
        if let identifier = variable.identifierPattern?.identifier {
          "try container.encode(self.\(identifier.trimmed), forKey: .\(identifier.trimmed))"
        }
      }
    }
  }
}

extension CowBoxMacro {
  static func cowBoxExtension(
    accessControl: CowBoxAccessControl?,
    with type: some TypeSyntaxProtocol
  ) -> ExtensionDeclSyntax {
    ExtensionDeclSyntax(
      extendedType: type,
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(type: TypeSyntax("CowBox"))
      }
    ) {
      self.identicalFunction(
        accessControl: accessControl,
        with: type
      )
    }
  }
}

extension CowBoxMacro {
  static func identicalFunction(
    accessControl: CowBoxAccessControl?,
    with type: some TypeSyntaxProtocol
  ) -> FunctionDeclSyntax {
    FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if case .isPackage = accessControl {
          DeclModifierSyntax(name: .keyword(.package))
        }
        if case .isPublic = accessControl {
          DeclModifierSyntax(name: .keyword(.public))
        }
      },
      name: "isIdentical",
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "to other: \(type.trimmed)"
        },
        returnClause: ReturnClauseSyntax(
          type: IdentifierTypeSyntax(name: "Bool")
        )
      )
    ) {
      "self.\(raw: CowBoxMacro.storageVariableName) === other.\(raw: CowBoxMacro.storageVariableName)"
    }
  }
}

//  MARK: -

public struct CowBoxMutatingMacro {
  static let macroName = "CowBoxMutating"
}

extension CowBoxMutatingMacro: AccessorMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {
    guard
      let variableDecl = declaration.as(VariableDeclSyntax.self)
    else {
      let message = CowBoxMacro.SimpleDiagnosticMessage.notProperty
      context.diagnose(
        Diagnostic(
          node: node,
          message: message
        )
      )
      throw message
    }
    
    guard
      variableDecl.isComputed == false
    else {
      let message = CowBoxMacro.SimpleDiagnosticMessage.notStoredProperty
      context.diagnose(
        Diagnostic(
          node: node,
          message: message
        )
      )
      throw message
    }
    
    guard
      variableDecl.isInstance
    else {
      let message = CowBoxMacro.SimpleDiagnosticMessage.notInstanceProperty
      context.diagnose(
        Diagnostic(
          node: node,
          message: message
        )
      )
      throw message
    }
    
    guard
      let identifier = variableDecl.identifierPattern?.identifier
    else {
      //  TODO: THROW ERROR
      return []
    }
    
    let expansion = [
      identifier.storageGetter,
      identifier.storageSetter
    ]
    
    return expansion
  }
}

//  MARK: -

public struct CowBoxNonMutatingMacro {
  static let macroName = "CowBoxNonMutating"
}

extension CowBoxNonMutatingMacro: AccessorMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {
    guard
      let variableDecl = declaration.as(VariableDeclSyntax.self)
    else {
      let message = CowBoxMacro.SimpleDiagnosticMessage.notProperty
      context.diagnose(
        Diagnostic(
          node: node,
          message: message
        )
      )
      throw message
    }
    
    guard
      variableDecl.isComputed == false
    else {
      let message = CowBoxMacro.SimpleDiagnosticMessage.notStoredProperty
      context.diagnose(
        Diagnostic(
          node: node,
          message: message
        )
      )
      throw message
    }
    
    guard
      variableDecl.isInstance
    else {
      let message = CowBoxMacro.SimpleDiagnosticMessage.notInstanceProperty
      context.diagnose(
        Diagnostic(
          node: node,
          message: message
        )
      )
      throw message
    }
    
    guard
      let identifier = variableDecl.identifierPattern?.identifier
    else {
      //  TODO: THROW ERROR
      return []
    }
    
    let expansion = [
      identifier.storageGetter
    ]
    
    return expansion
  }
}

//  MARK: -

extension AttributeSyntax {
  var initArgument: CowBoxInit? {
    //  https://forums.swift.org/t/strategies-for-passing-an-enum-value-as-a-macro-parameter-and-reading-during-expansion/71333/
    
    if case let .argumentList(arguments) = self.arguments,
       let argument = arguments.first,
       let expression = argument.expression.as(MemberAccessExprSyntax.self) {
      return CowBoxInit(rawValue: expression.declName.baseName.trimmed.text)
    }
    return nil
  }
}

//  MARK: -

extension FunctionDeclSyntax {
  var isEncodeFunction: Bool {
    guard
      self.isInstance
    else {
      return false
    }
    
    guard
      let function = try? FunctionDeclSyntax("func encode(to encoder: any Encoder) throws")
    else {
      //  TODO: THROW ERROR
      fatalError()
    }
    
    return self.isEquivalent(to: function)
  }
}

extension FunctionDeclSyntax {
  var isEqualFunction: Bool {
    guard
      self.isInstance == false
    else {
      return false
    }
    
    return self.name.tokenKind == .binaryOperator("==")
  }
}

extension FunctionDeclSyntax {
  var isHashFunction: Bool {
    guard
      self.isInstance
    else {
      return false
    }
    
    guard
      let function = try? FunctionDeclSyntax("func hash(into hasher: inout Hasher)")
    else {
      //  TODO: THROW ERROR
      fatalError()
    }
    
    return self.isEquivalent(to: function)
  }
}

//  MARK: -

extension InitializerDeclSyntax {
  struct SignatureStandin: Equatable {
    var identifier: String
    var parameters: [String]
    var throwsSpecifier: String
  }
}

extension InitializerDeclSyntax {
  var isDecodeInitializer: Bool {
    guard
      let initializer = (try? InitializerDeclSyntax("init(from decoder: any Decoder) throws") { })
    else {
      //  TODO: THROW ERROR
      fatalError()
    }
    
    return self.isEquivalent(to: initializer)
  }
}

extension InitializerDeclSyntax {
  func isEquivalent(to other: InitializerDeclSyntax) -> Bool {
    self.signatureStandin == other.signatureStandin
  }
}

extension InitializerDeclSyntax {
  var signatureStandin: SignatureStandin {
    var parameters = [String]()
    for parameter in self.signature.parameterClause.parameters {
      parameters.append(parameter.firstName.text + ":" + (parameter.type.genericSubstitution(genericParameterClause?.parameters) ?? "" ))
    }
#if canImport(SwiftSyntax600)
    let throwsSpecifier = self.signature.effectSpecifiers?.throwsClause?.throwsSpecifier.text ?? ""
#else
    let throwsSpecifier = self.signature.effectSpecifiers?.throwsSpecifier?.text ?? ""
#endif
    return SignatureStandin(identifier: self.initKeyword.text, parameters: parameters, throwsSpecifier: throwsSpecifier)
  }
}

//  MARK: -

extension StructDeclSyntax {
  var instanceStoredVariables: [VariableDeclSyntax] {
    self.definedVariables.filter { variable in
      if variable.isComputed == false,
         variable.isInstance,
         let identifier = variable.identifierPattern?.identifier,
         identifier.text != CowBoxMacro.storageVariableName {
        return true
      }
      return false
    }
  }
}

extension StructDeclSyntax {
  var isPublic: Bool {
    self.modifiers.contains { modifier in
      modifier.name.tokenKind == .keyword(.public)
    }
  }
}

extension StructDeclSyntax {
  var isPackage: Bool {
    self.modifiers.contains { modifier in
      modifier.name.tokenKind == .keyword(.package)
    }
  }
}

extension StructDeclSyntax {
  var accessControl: CowBoxAccessControl? {
    if self.isPackage {
      return CowBoxAccessControl.isPackage
    }
    if self.isPublic {
      return CowBoxAccessControl.isPublic
    }
    return nil
  }
}

extension StructDeclSyntax {
  var isEquatable: Bool {
    if self.isHashable {
      return true
    }
    
    guard
      let inheritedTypes = self.inheritanceClause?.inheritedTypes
    else {
      return false
    }
    
    return inheritedTypes.compactMap { type in
      type.type.as(IdentifierTypeSyntax.self)
    }.contains { type in
      type.name.tokenKind == .identifier("Equatable")
    }
  }
}

extension StructDeclSyntax {
  var isHashable: Bool {
    guard
      let inheritedTypes = self.inheritanceClause?.inheritedTypes
    else {
      return false
    }
    
    return inheritedTypes.compactMap { type in
      type.type.as(IdentifierTypeSyntax.self)
    }.contains { type in
      type.name.tokenKind == .identifier("Hashable")
    }
  }
}

extension StructDeclSyntax {
  var hasHashFunction: Bool {
    self.memberBlock.members.compactMap { member in
      member.decl.as(FunctionDeclSyntax.self)
    }.contains { member in
      member.isHashFunction
    }
  }
}

extension StructDeclSyntax {
  var hasDecodeInitializer: Bool {
    self.memberBlock.members.compactMap { member in
      member.decl.as(InitializerDeclSyntax.self)
    }.contains { member in
      member.isDecodeInitializer
    }
  }
}

extension StructDeclSyntax {
  var hasEncodeFunction: Bool {
    self.memberBlock.members.compactMap { member in
      member.decl.as(FunctionDeclSyntax.self)
    }.contains { member in
      member.isEncodeFunction
    }
  }
}

extension StructDeclSyntax {
  var isDecodable: Bool {
    if self.isCodable {
      return true
    }
    
    guard
      let inheritedTypes = self.inheritanceClause?.inheritedTypes
    else {
      return false
    }
    
    return inheritedTypes.compactMap { type in
      type.type.as(IdentifierTypeSyntax.self)
    }.contains { type in
      type.name.tokenKind == .identifier("Decodable")
    }
  }
}

extension StructDeclSyntax {
  var isEncodable: Bool {
    if self.isCodable {
      return true
    }
    
    guard
      let inheritedTypes = self.inheritanceClause?.inheritedTypes
    else {
      return false
    }
    
    return inheritedTypes.compactMap { type in
      type.type.as(IdentifierTypeSyntax.self)
    }.contains { type in
      type.name.tokenKind == .identifier("Encodable")
    }
  }
}

extension StructDeclSyntax {
  var isCodable: Bool {
    guard
      let inheritedTypes = self.inheritanceClause?.inheritedTypes
    else {
      return false
    }
    
    return inheritedTypes.compactMap { type in
      type.type.as(IdentifierTypeSyntax.self)
    }.contains { type in
      type.name.tokenKind == .identifier("Codable")
    }
  }
}

extension StructDeclSyntax {
  var isSendable: Bool {
    guard
      let inheritedTypes = self.inheritanceClause?.inheritedTypes
    else {
      return false
    }
    
    return inheritedTypes.compactMap { type in
      type.type.as(IdentifierTypeSyntax.self)
    }.contains { type in
      type.name.tokenKind == .identifier("Sendable")
    }
  }
}

extension StructDeclSyntax {
  var isCustomStringConvertible: Bool {
    guard
      let inheritedTypes = self.inheritanceClause?.inheritedTypes
    else {
      return false
    }
    
    return inheritedTypes.compactMap { type in
      type.type.as(IdentifierTypeSyntax.self)
    }.contains { type in
      type.name.tokenKind == .identifier("CustomStringConvertible")
    }
  }
}

extension StructDeclSyntax {
  var hasCodingKeys: Bool {
    self.memberBlock.members.compactMap { member in
      member.decl.as(EnumDeclSyntax.self)
    }.contains { member in
      member.name.tokenKind == .identifier("CodingKeys")
    }
  }
}

extension StructDeclSyntax {
  var hasDescriptionVariable: Bool {
    self.memberBlock.members.compactMap { member in
      member.decl.as(VariableDeclSyntax.self)
    }.contains { member in
      member.isDescriptionVariable
    }
  }
}

extension StructDeclSyntax {
  var hasEqualFunction: Bool {
    self.memberBlock.members.compactMap { member in
      member.decl.as(FunctionDeclSyntax.self)
    }.contains { member in
      member.isEqualFunction
    }
  }
}

//  MARK: -

extension TokenSyntax {
  var storageGetter: AccessorDeclSyntax {
    AccessorDeclSyntax(
      accessorSpecifier: TokenSyntax(.keyword(.get), presence: .present),
      body: CodeBlockSyntax(
        statements: CodeBlockItemListSyntax {
          "self.\(raw: CowBoxMacro.storageVariableName).\(self.trimmed)"
        }
      )
    )
  }
}

extension TokenSyntax {
  var storageSetter: AccessorDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/include/swift/AST/Builtins.def#L408-L437
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/stdlib/public/core/Builtin.swift#L687-L710
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/stdlib/public/core/ManagedBuffer.swift#L500-L565
    
    //  TODO: PASS NEW VALUE TO CUSTOM COPY FUNCTION
    
    AccessorDeclSyntax(
      accessorSpecifier: TokenSyntax(.keyword(.set), presence: .present),
      body: CodeBlockSyntax(
        statements: CodeBlockItemListSyntax {
          "if Swift.isKnownUniquelyReferenced(&self.\(raw: CowBoxMacro.storageVariableName)) == false { self.\(raw: CowBoxMacro.storageVariableName) = self.\(raw: CowBoxMacro.storageVariableName).\(raw: CowBoxMacro.copyFunctionName)() }"
          "self.\(raw: CowBoxMacro.storageVariableName).\(self.trimmed) = newValue"
        }
      )
    )
  }
}

//  MARK: -

extension VariableDeclSyntax {
  var isDescriptionVariable: Bool {
    guard
      self.isInstance,
      let identifier = self.identifierPattern?.identifier
    else {
      return false
    }
    return identifier.tokenKind == .identifier("description")
  }
}

extension VariableDeclSyntax {
  var mutating: VariableDeclSyntax {
    guard
      let binding = self.bindings.first
    else {
      //  TODO: THROW ERROR
      fatalError()
    }
    //  FIXME: SAVE ATTRIBUTES
    //  FIXME: SAVE MODIFIERS
    return VariableDeclSyntax(
      bindingSpecifier: TokenSyntax(.keyword(.var), presence: .present),
      bindings: PatternBindingListSyntax {
        PatternBindingSyntax(
          pattern: binding.pattern.trimmed,
          typeAnnotation: binding.typeAnnotation?.trimmed
        )
      }
    )
  }
}

extension VariableDeclSyntax {
  var nonMutating: VariableDeclSyntax {
    guard
      let binding = self.bindings.first
    else {
      //  TODO: THROW ERROR
      fatalError()
    }
    //  FIXME: SAVE ATTRIBUTES
    //  FIXME: SAVE MODIFIERS
    return VariableDeclSyntax(
      bindingSpecifier: TokenSyntax(.keyword(.let), presence: .present),
      bindings: PatternBindingListSyntax {
        PatternBindingSyntax(
          pattern: binding.pattern.trimmed,
          typeAnnotation: binding.typeAnnotation?.trimmed
        )
      }
    )
  }
}

extension VariableDeclSyntax {
  var isCowBoxNonMutating: Bool {
    self.hasMacroApplication(CowBoxNonMutatingMacro.macroName)
  }
}

extension VariableDeclSyntax {
  var isCowBoxMutating: Bool {
    self.hasMacroApplication(CowBoxMutatingMacro.macroName)
  }
}

extension VariableDeclSyntax {
  var isCowBox: Bool {
    self.isCowBoxNonMutating || self.isCowBoxMutating
  }
}

extension VariableDeclSyntax {
  var functionParameter: FunctionParameterSyntax? {
    if let identifier = self.identifierPattern?.identifier,
       let type = self.type {
      return FunctionParameterSyntax(
        firstName: identifier.trimmed,
        type: type.trimmed,
        defaultValue: self.initializer?.trimmed
      )
    }
    return nil
  }
}
