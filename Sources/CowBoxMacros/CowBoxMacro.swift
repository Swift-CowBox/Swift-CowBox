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

enum CowBoxInit: String {
  case withInternal
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
    
    let expansion = [
      Self.cowBoxExtension(
        attachedTo: declaration,
        providingExtensionsOf: type
      ),
    ]
    
    return expansion
  }
}

extension CowBoxMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
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
    
    var expansion = [
      DeclSyntax(declaration.storageClass),
      DeclSyntax(declaration.storageVariable),
      DeclSyntax(
        declaration.initializer(
          with: node.initArgument()
        )
      ),
    ]
    
    if declaration.isCustomStringConvertible,
       declaration.hasDescriptionVariable == false {
      expansion.append(
        DeclSyntax(declaration.descriptionVariable)
      )
    }
    
    if declaration.isEquatable,
       declaration.hasEqualFunction == false {
      expansion.append(
        DeclSyntax(declaration.equalFunction)
      )
    }
    
    if declaration.isHashable,
       declaration.hasHashFunction == false {
      expansion.append(
        DeclSyntax(declaration.hashFunction)
      )
    }
    
    if declaration.isDecodable || declaration.isEncodable,
       declaration.hasCodingKeys == false {
      expansion.append(
        DeclSyntax(declaration.codingKeys)
      )
    }
    
    if declaration.isDecodable,
       declaration.hasDecodeInitializer == false {
      expansion.append(
        DeclSyntax(declaration.decodeInitializer)
      )
    }
    
    if declaration.isEncodable,
       declaration.hasEncodeFunction == false {
      expansion.append(
        DeclSyntax(declaration.encodeFunction)
      )
    }
    
    return expansion
  }
}

extension CowBoxMacro {
  static func cowBoxExtension(
    attachedTo declaration: StructDeclSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol
  ) -> ExtensionDeclSyntax {
    ExtensionDeclSyntax(
      extendedType: type.trimmed,
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(type: TypeSyntax("CowBox"))
      }
    ) {
      self.identicalFunction(
        isPublic: declaration.isPublic,
        with: type
      )
    }
  }
}

extension CowBoxMacro {
  static func identicalFunction(
    isPublic: Bool,
    with type: some TypeSyntaxProtocol
  ) -> FunctionDeclSyntax {
    FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if isPublic {
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

extension CowBoxMacro {
  static func customStringConvertibleExtension(
    attachedTo declaration: StructDeclSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol
  ) -> ExtensionDeclSyntax {
    ExtensionDeclSyntax(
      extendedType: type,
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(type: TypeSyntax("CustomStringConvertible"))
      }
    ) {
      if declaration.hasDescriptionVariable == false {
        self.descriptionVariable(
          isPublic: declaration.isPublic,
          with: type,
          storageClassParameters: declaration.storageClassParameters
        )
      }
    }
  }
}

extension CowBoxMacro {
  static func descriptionVariable(
    isPublic: Bool,
    with type: some TypeSyntaxProtocol,
    storageClassParameters: [FunctionParameterSyntax]
  ) -> VariableDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/stdlib/public/core/OutputStream.swift#L339-L355
    
    //  https://oleb.net/blog/2016/12/optionals-string-interpolation/
    //  FIXME: OPTIONAL VALUE WARNING
    
    let parameters = storageClassParameters.map { parameter in
      CodeBlockItemListSyntax {
        "string += \"\(parameter.firstName): \\(self.\(parameter.firstName))\""
      }
    }.joined(
      separator: CodeBlockItemListSyntax {
        "string += \", \""
      }
    )
    
    return VariableDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if isPublic {
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
                for parameter in parameters {
                  parameter
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
  func initArgument() -> CowBoxInit? {
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
      let initializer = (try? InitializerDeclSyntax("init(from decoder: Decoder) throws") { })
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
    let throwsSpecifier = self.signature.effectSpecifiers?.throwsSpecifier?.text ?? ""
    return SignatureStandin(identifier: self.initKeyword.text, parameters: parameters, throwsSpecifier: throwsSpecifier)
  }
}

//  MARK: -

extension StructDeclSyntax {
  func initializer(with initArgument: CowBoxInit?) -> InitializerDeclSyntax {
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0242-default-values-memberwise.md
    //  TODO: SUPPORT DEFAULT VALUES
    
    let parameters = self.storageClassParameters
    
    return InitializerDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if let initArgument = initArgument {
          if case .withPublic = initArgument {
            DeclModifierSyntax(name: .keyword(.public))
          }
        } else {
          if self.isPublic {
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
            for parameter in parameters {
              LabeledExprSyntax(
                label: parameter.firstName,
                colon: .colonToken(),
                expression: DeclReferenceExprSyntax(
                  baseName: parameter.firstName
                )
              )
            }
          },
          rightParen: .rightParenToken()
        )
      )
    }
  }
}

extension StructDeclSyntax {
  var storageClassInitializer: InitializerDeclSyntax {
    let parameters = self.storageClassParameters
    
    return InitializerDeclSyntax(
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          FunctionParameterListSyntax(parameters)
        }
      )
    ) {
      for parameter in parameters {
        "self.\(parameter.firstName) = \(parameter.firstName)"
      }
    }
  }
}

extension StructDeclSyntax {
  var storageClassCopyFunction: FunctionDeclSyntax {
    return FunctionDeclSyntax(
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
          for parameter in self.storageClassParameters {
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

extension StructDeclSyntax {
  var storageVariable: VariableDeclSyntax {
    VariableDeclSyntax(
      modifiers: DeclModifierListSyntax {
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

extension StructDeclSyntax {
  var storageClass: ClassDeclSyntax {
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md
    
    ClassDeclSyntax(
      modifiers: DeclModifierListSyntax {
        DeclModifierSyntax(name: TokenSyntax(.keyword(.private), presence: .present))
        DeclModifierSyntax(name: TokenSyntax(.keyword(.final), presence: .present))
      },
      name: TokenSyntax(.identifier(CowBoxMacro.storageClassName), presence: .present),
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(type: TypeSyntax("@unchecked Sendable"))
      }
    ) {
      for variable in self.storageClassVariables {
        variable
      }
      self.storageClassInitializer
      self.storageClassCopyFunction
    }
  }
}

extension StructDeclSyntax {
  var descriptionVariable: VariableDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/stdlib/public/core/OutputStream.swift#L339-L355
    
    //  https://oleb.net/blog/2016/12/optionals-string-interpolation/
    //  FIXME: OPTIONAL VALUE WARNING
    
    let parameters = self.storageClassParameters.map { parameter in
      CodeBlockItemListSyntax {
        "string += \"\(parameter.firstName): \\(self.\(parameter.firstName))\""
      }
    }.joined(
      separator: CodeBlockItemListSyntax {
        "string += \", \""
      }
    )
    
    return VariableDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if self.isPublic {
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
                "var string = \"\(self.name.trimmed)(\""
                for parameter in parameters {
                  parameter
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

extension StructDeclSyntax {
  var hashFunction: FunctionDeclSyntax {
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0185-synthesize-equatable-hashable.md
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0206-hashable-enhancements.md
    
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceEquatableHashable.cpp#L778-L820
    
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceEquatableHashable.cpp#L574-L595
    //  TODO: SUPPORT LEGACY HASH VALUE
    
    FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if self.isPublic {
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
      for parameter in self.storageClassParameters {
        "hasher.combine(self.\(parameter.firstName))"
      }
    }
  }
}

extension StructDeclSyntax {
  var codingKeys: EnumDeclSyntax {
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
      for parameter in self.storageClassParameters {
        EnumCaseDeclSyntax(
          elements: EnumCaseElementListSyntax {
            EnumCaseElementSyntax(name: parameter.firstName)
          }
        )
      }
    }
  }
}

extension StructDeclSyntax {
  var equalFunction: FunctionDeclSyntax {
    //  https://github.com/apple/swift-evolution/blob/main/proposals/0185-synthesize-equatable-hashable.md
    
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceEquatableHashable.cpp#L292-L341
    
    FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if self.isPublic {
          DeclModifierSyntax(name: .keyword(.public))
        }
        DeclModifierSyntax(name: TokenSyntax(.keyword(.static), presence: .present))
      },
      name: .binaryOperator("=="),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "lhs: \(self.name.trimmed)"
          "rhs: \(self.name.trimmed)"
        },
        returnClause: ReturnClauseSyntax(
          type: IdentifierTypeSyntax(name: "Bool")
        )
      )
    ) {
      "if lhs.isIdentical(to: rhs) { return true }"
      for parameter in self.storageClassParameters {
        "guard lhs.\(parameter.firstName) == rhs.\(parameter.firstName) else { return false }"
      }
      "return true"
    }
  }
}

extension StructDeclSyntax {
  var decodeInitializer: InitializerDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceCodable.cpp#L1304-L1541
    
    let parameters = self.storageClassParameters
    
    return InitializerDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if self.isPublic {
          DeclModifierSyntax(name: .keyword(.public))
        }
      },
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "from decoder: Decoder"
        },
        effectSpecifiers: FunctionEffectSpecifiersSyntax(
          //  throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws))
          throwsSpecifier: .keyword(.throws)
        )
      )
    ) {
      "let values = try decoder.container(keyedBy: CodingKeys.self)"
      for parameter in parameters {
        "let \(parameter.firstName) = try values.decode(\(parameter.type).self, forKey: .\(parameter.firstName))"
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
          for parameter in parameters {
            LabeledExprSyntax(
              label: parameter.firstName,
              colon: .colonToken(),
              expression: DeclReferenceExprSyntax(
                baseName: parameter.firstName
              )
            )
          }
        },
        rightParen: .rightParenToken()
      )
    }
  }
}

extension StructDeclSyntax {
  var encodeFunction: FunctionDeclSyntax {
    //  https://github.com/apple/swift/blob/swift-5.10-RELEASE/lib/Sema/DerivedConformanceCodable.cpp#L790-L928
    
    FunctionDeclSyntax(
      modifiers: DeclModifierListSyntax {
        if self.isPublic {
          DeclModifierSyntax(name: .keyword(.public))
        }
      },
      name: TokenSyntax(.identifier("encode"), presence: .present),
      signature: FunctionSignatureSyntax(
        parameterClause: FunctionParameterClauseSyntax {
          "to encoder: any Encoder"
        },
        effectSpecifiers: FunctionEffectSpecifiersSyntax(
          //  throwsClause: ThrowsClauseSyntax(throwsSpecifier: .keyword(.throws))
          throwsSpecifier: .keyword(.throws)
        )
      )
    ) {
      "var container = encoder.container(keyedBy: CodingKeys.self)"
      for parameter in self.storageClassParameters {
        "try container.encode(self.\(parameter.firstName), forKey: .\(parameter.firstName))"
      }
    }
  }
}

extension StructDeclSyntax {
  var storageClassVariables: [VariableDeclSyntax] {
    self.definedVariables.compactMap { variable in
      variable.storageVariable
    }
  }
}

extension StructDeclSyntax {
  var storageClassParameters: [FunctionParameterSyntax] {
    self.definedVariables.compactMap { variable in
      variable.storageParameter
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
    //  FIXME: SAVE ATTRIBUTES
    //  FIXME: SAVE MODIFIERS
    VariableDeclSyntax(
      bindingSpecifier: TokenSyntax(.keyword(.var), presence: .present),
      bindings: self.bindings
    )
  }
}

extension VariableDeclSyntax {
  var nonMutating: VariableDeclSyntax {
    //  FIXME: SAVE ATTRIBUTES
    //  FIXME: SAVE MODIFIERS
    VariableDeclSyntax(
      bindingSpecifier: TokenSyntax(.keyword(.let), presence: .present),
      bindings: self.bindings
    )
  }
}

extension VariableDeclSyntax {
  var storageParameter: FunctionParameterSyntax? {
    if self.isComputed == false,
       self.isInstance,
       let identifier = self.identifierPattern?.identifier,
       identifier.text != CowBoxMacro.storageVariableName,
       let type = self.type {
      if self.hasMacroApplication(CowBoxNonMutatingMacro.macroName) {
        return FunctionParameterSyntax(
          firstName: identifier.trimmed,
          type: type.trimmed
        )
      }
      if self.hasMacroApplication(CowBoxMutatingMacro.macroName) {
        return FunctionParameterSyntax(
          firstName: identifier.trimmed,
          type: type.trimmed
        )
      }
      return nil
    }
    return nil
  }
}

extension VariableDeclSyntax {
  var storageVariable: VariableDeclSyntax? {
    if self.isComputed == false,
       self.isInstance,
       let identifier = self.identifierPattern?.identifier,
       identifier.text != CowBoxMacro.storageVariableName {
      if self.hasMacroApplication(CowBoxNonMutatingMacro.macroName) {
        return self.nonMutating
      }
      if self.hasMacroApplication(CowBoxMutatingMacro.macroName) {
        return self.mutating
      }
      return nil
    }
    return nil
  }
}
