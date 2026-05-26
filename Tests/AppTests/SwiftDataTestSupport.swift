import Foundation
import SwiftData
@testable import SnapRunCore

@MainActor
final class SwiftDataTestFixture {
    // storeURL is kept for API compatibility but points nowhere when using
    // the in-memory configuration (isStoredInMemoryOnly: true).  The in-memory
    // store avoids the "Unable to determine Bundle Name" fatal error that
    // SwiftData's CoreData backend triggers on CI runners where the test
    // binary has no bundle identifier.
    let storeURL: URL
    let container: ModelContainer

    init() throws {
        // Provide a stable-looking URL even though storage is in-memory.
        self.storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("snaprun-app-test-\(UUID().uuidString)")
            .appendingPathComponent("default.store")

        let schema = Schema([ScheduledTask.self, ExecutionLog.self])
        // isStoredInMemoryOnly = true → no bundle-name look-up, no disk I/O.
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        self.container = try ModelContainer(for: schema, configurations: [configuration])
    }

    deinit {
        // Nothing on disk to remove when using the in-memory store.
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
