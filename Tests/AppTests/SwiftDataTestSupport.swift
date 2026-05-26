import Foundation
import SwiftData
@testable import SnapRunCore

@MainActor
final class SwiftDataTestFixture {
    let storeURL: URL
    let container: ModelContainer

    init() throws {
        Bundle.injectTestBundleIdentifier()
        // Provide a direct, concrete URL in the temporary directory.
        // Specifying a custom URL directly prevents SwiftData from looking up default bundle paths.
        self.storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("snaprun-app-test-\(UUID().uuidString).store")

        let schema = Schema([ScheduledTask.self, ExecutionLog.self])
        let configuration = ModelConfiguration(
            schema: schema,
            url: self.storeURL,
            allowsSave: true
        )
        self.container = try ModelContainer(for: schema, configurations: [configuration])
    }

    deinit {
        // Clean up the temporary store file on disk.
        try? FileManager.default.removeItem(at: storeURL)
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

// MARK: - Bundle Swizzling for CI Support
extension Bundle {
    private static let swizzleBundleIdentifiersAndNames: Void = {
        // 1. Swizzle bundleIdentifier
        if let originalMethod = class_getInstanceMethod(Bundle.self, #selector(getter: Bundle.bundleIdentifier)),
           let swizzledMethod = class_getInstanceMethod(Bundle.self, #selector(getter: Bundle.swizzled_bundleIdentifier)) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        // 2. Swizzle infoDictionary
        if let originalMethod = class_getInstanceMethod(Bundle.self, #selector(getter: Bundle.infoDictionary)),
           let swizzledMethod = class_getInstanceMethod(Bundle.self, #selector(getter: Bundle.swizzled_infoDictionary)) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        // 3. Swizzle object(forInfoDictionaryKey:)
        if let originalMethod = class_getInstanceMethod(Bundle.self, #selector(Bundle.object(forInfoDictionaryKey:))),
           let swizzledMethod = class_getInstanceMethod(Bundle.self, #selector(Bundle.swizzled_object(forInfoDictionaryKey:))) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()
    
    @objc var swizzled_bundleIdentifier: String? {
        if self == Bundle.main {
            return "com.lifedever.SnapRun"
        }
        return self.swizzled_bundleIdentifier // Original method
    }
    
    @objc var swizzled_infoDictionary: [String: Any]? {
        var dict = self.swizzled_infoDictionary ?? [:]
        if self == Bundle.main {
            dict["CFBundleIdentifier"] = "com.lifedever.SnapRun"
            dict["CFBundleName"] = "SnapRun"
            dict["CFBundleDisplayName"] = "SnapRun"
            dict["CFBundleExecutable"] = "SnapRun"
        }
        return dict.isEmpty ? nil : dict
    }
    
    @objc func swizzled_object(forInfoDictionaryKey key: String) -> Any? {
        if self == Bundle.main {
            switch key {
            case "CFBundleIdentifier": return "com.lifedever.SnapRun"
            case "CFBundleName", "CFBundleDisplayName": return "SnapRun"
            case "CFBundleExecutable": return "SnapRun"
            default: break
            }
        }
        return self.swizzled_object(forInfoDictionaryKey: key) // Original method
    }
    
    static func injectTestBundleIdentifier() {
        _ = swizzleBundleIdentifiersAndNames
    }
}
