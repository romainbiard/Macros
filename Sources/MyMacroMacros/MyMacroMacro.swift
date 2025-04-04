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
          { 
           guard !Task.isCancelled else { return }
           let taskIdentifier = _key()
           print(taskIdentifier)
           _tasks[taskIdentifier]?.cancel()
           _tasks[taskIdentifier] = Task(\(node.arguments)) { \(node.trailingClosure?.signature) \(body)
           }
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
        private var _tasks = [String: Task<Void, Never>]()
        
        private func cancelAllTasks() {
            _tasks.values.forEach { $0.cancel() }
           // _tasks.removeAll()
        }
        
        private func _key(key: String = "\\(#function)\\(#line)") -> String {
            return key
        }
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
