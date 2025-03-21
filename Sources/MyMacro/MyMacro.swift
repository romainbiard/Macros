// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.

@attached(member)
public macro ManagingTask() = #externalMacro(module: "MyMacroMacros", type: "ManagingTaskMacro")

@freestanding(expression)
public macro AutoCancellableTask(_ body: @escaping () async throws -> Void) = #externalMacro(module: "MyMacroMacros", type: "AutoCancellableTaskMacro")

public struct TaskHolder {
  var tasks: [String: Task<Void, Error>] = [:]

  public init() { }

  public mutating func addTask(_ task: Task<Void, Error>, for key: String) {
    tasks[key] = task
  }

  public mutating func cancelAllTasks() {
    for (_, task) in tasks {
      task.cancel()
    }
    tasks.removeAll()
  }
}
