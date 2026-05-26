import Foundation

final class CommandRuntime: @unchecked Sendable {
    private let lock = NSLock()
    private var observers: [NSObjectProtocol] = []
    private var signalSources: [DispatchSourceSignal] = []
    private var workItems: [DispatchWorkItem] = []
    private var didFinish = false

    func addObserver(_ observer: NSObjectProtocol) {
        lock.lock()
        defer { lock.unlock() }
        observers.append(observer)
    }

    func addSignalSource(_ source: DispatchSourceSignal) {
        lock.lock()
        defer { lock.unlock() }
        signalSources.append(source)
    }

    func addWorkItem(_ workItem: DispatchWorkItem) {
        lock.lock()
        defer { lock.unlock() }
        workItems.append(workItem)
    }

    func finish(center: DistributedNotificationCenter) -> Bool {
        lock.lock()
        guard !didFinish else {
            lock.unlock()
            return false
        }
        didFinish = true
        let localObservers = observers
        let localWorkItems = workItems
        let localSignalSources = signalSources
        observers.removeAll()
        workItems.removeAll()
        signalSources.removeAll()
        lock.unlock()

        for observer in localObservers {
            center.removeObserver(observer)
        }

        for workItem in localWorkItems {
            workItem.cancel()
        }

        for source in localSignalSources {
            source.cancel()
        }

        return true
    }
}
