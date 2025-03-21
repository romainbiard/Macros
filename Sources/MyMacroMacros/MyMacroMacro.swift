import SwiftCompilerPlugin
import SwiftSyntax
import SwiftParser
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoCancellableTaskMacro: ExpressionMacro {

  public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
    guard let body = node.trailingClosure?.statements else {
      fatalError("compiler bug: the macro does not have any arguments")
    }
    return """
           let task = Task { \(body)
           }
           taskHolder.add(task, forKey: "\\(#function)\\(#line)")
          """
  }
}

public struct ManagingTaskMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext) throws -> [DeclSyntax] {
    let taskHolderProperty: DeclSyntax = """
        private var tasks = TaskHolder()
        """
    return [taskHolderProperty]
  }
}

@main
struct MyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
      AutoCancellableTaskMacro.self, ManagingTaskMacro.self
    ]
}
