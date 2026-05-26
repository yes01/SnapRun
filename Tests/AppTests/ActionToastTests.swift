import XCTest
import SnapRunCore
@testable import SnapRunApp

final class ActionToastTests: XCTestCase {

    func testStartedTitleAndBody() {
        // We only verify structural correctness here: the title must be non-empty
        // and the body must equal the task name passed in.
        // We do NOT assert specific translated strings because the resource bundle
        // is not available on CI runners (no bundle identifier → L10n returns
        // the raw key).  Locale-pinning via L10n.reloadBundle has no effect when
        // the bundle itself cannot be found.
        let (title, body) = ActionToast.previewContent(for: .started(taskName: "Backup"))
        XCTAssertFalse(title.isEmpty)
        XCTAssertEqual(body, "Backup")
    }

    func testStoppedRestartedFailedBodies() {
        XCTAssertFalse(ActionToast.previewContent(for: .stopped(taskName: "X")).title.isEmpty)
        XCTAssertFalse(ActionToast.previewContent(for: .restarted(taskName: "X")).title.isEmpty)
        let failed = ActionToast.previewContent(for: .failed(taskName: "X", reason: "not found"))
        XCTAssertFalse(failed.title.isEmpty)
        XCTAssertTrue(failed.body.contains("X"))
        XCTAssertTrue(failed.body.contains("not found"))
    }

    func testFailedWithoutTaskNameUsesReasonOnly() {
        let (_, body) = ActionToast.previewContent(for: .failed(taskName: nil, reason: "unknown id"))
        XCTAssertEqual(body, "unknown id")
    }
}
