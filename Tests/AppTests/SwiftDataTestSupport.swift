import Foundation
import SwiftData
@testable import TaskTickCore

@MainActor
final class SwiftDataTestFixture {
    let storeURL: URL
    let container: ModelContainer

    init() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("tasktick-app-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.storeURL = directory.appendingPathComponent("default.store")

        let schema = Schema([ScheduledTask.self, ExecutionLog.self])
        let configuration = ModelConfiguration(schema: schema, url: storeURL, allowsSave: true)
        self.container = try ModelContainer(for: schema, configurations: [configuration])
    }

    deinit {
        try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
    }

    var context: ModelContext { container.mainContext }

    @discardableResult
    func makeTask(
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
