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
          { @MainActor in
           let taskIdentifier = "\\(#function)\\(#line)"
           _tasks.cancel(taskIdentifier)
           let task = Task(\(node.arguments)) { \(node.trailingClosure?.signature) \(body)
           }
           _tasks.add(task, for: "\\(taskIdentifier)")
          }()
          """
  }
}

public struct ManagingTaskMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext) throws -> [DeclSyntax] {
    let taskHolderProperty: DeclSyntax = """
        private var _tasks = TaskHolder()
        """
    return [taskHolderProperty]
  }
}

public struct CancelAllTasksMacro: ExpressionMacro {
  public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
    return """
          _tasks.cancelAllTasks()
          """
  }
}

@main
struct MyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
      AutoCancellableTaskMacro.self, ManagingTaskMacro.self, CancelAllTasksMacro.self
    ]
}
