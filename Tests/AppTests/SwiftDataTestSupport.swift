import Foundation
import SwiftData
@testable import TaskTickCore

@MainActor
enum SwiftDataTestSupport {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([ScheduledTask.self, ExecutionLog.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    @discardableResult
    static func makeTask(
        in context: ModelContext,
        name: String = "",
        scriptBody: String = "",
        shell: String = "/bin/zsh",
        scheduledDate: Date? = nil,
        repeatType: RepeatType = .daily,
        endRepeatType: EndRepeatType = .never,
        endRepeatDate: Date? = nil,
        endRepeatCount: Int? = nil,
        isEnabled: Bool = true,
        workingDirectory: String? = nil,
        environmentVariablesJSON: String? = nil,
        timeoutSeconds: Int = 300,
        notifyOnSuccess: Bool = true,
        notifyOnFailure: Bool = true
    ) -> ScheduledTask {
        let task = ScheduledTask(
            name: name,
            scriptBody: scriptBody,
            shell: shell,
            scheduledDate: scheduledDate,
            repeatType: repeatType,
            endRepeatType: endRepeatType,
            endRepeatDate: endRepeatDate,
            endRepeatCount: endRepeatCount,
            isEnabled: isEnabled,
            workingDirectory: workingDirectory,
            environmentVariablesJSON: environmentVariablesJSON,
            timeoutSeconds: timeoutSeconds,
            notifyOnSuccess: notifyOnSuccess,
            notifyOnFailure: notifyOnFailure
        )
        context.insert(task)
        return task
    }
}
