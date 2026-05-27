import Testing
import Foundation
@testable import SnapRunApp
import SnapRunCore

@Suite("CronExpression Tests")
struct CronExpressionTests {

    @Test("Parse every minute")
    func parseEveryMinute() throws {
        let cron = try CronExpression(parsing: "* * * * *")
        #expect(cron.minute == .any)
        #expect(cron.hour == .any)
        #expect(cron.dayOfMonth == .any)
        #expect(cron.month == .any)
        #expect(cron.dayOfWeek == .any)
    }

    @Test("Parse step expression")
    func parseStep() throws {
        let cron = try CronExpression(parsing: "*/5 * * * *")
        #expect(cron.minute == .step(5))
    }

    @Test("Parse specific value")
    func parseValue() throws {
        let cron = try CronExpression(parsing: "30 8 * * *")
        #expect(cron.minute == .value(30))
        #expect(cron.hour == .value(8))
    }

    @Test("Parse range")
    func parseRange() throws {
        let cron = try CronExpression(parsing: "0 9-17 * * *")
        #expect(cron.hour == .range(9, 17))
    }

    @Test("Invalid format throws")
    func invalidFormat() {
        #expect(throws: CronExpression.ParseError.self) {
            try CronExpression(parsing: "* * *")
        }
    }

    @Test("Value out of range throws")
    func valueOutOfRange() {
        #expect(throws: CronExpression.ParseError.self) {
            try CronExpression(parsing: "60 * * * *")
        }
    }

    @Test("Next fire date calculation")
    func nextFireDate() throws {
        let cron = try CronExpression(parsing: "* * * * *")
        let next = cron.nextFireDate()
        #expect(next != nil)
    }

    @Test("Human readable presets")
    func humanReadable() throws {
        let cron = try CronExpression(parsing: "* * * * *")
        // humanReadable must return a non-empty, localised description.
        // We do NOT assert a specific language here because the CI runner's
        // locale may differ from a developer's local machine (e.g. "Every minute"
        // on an English runner vs "每分钟" on a Chinese one).
        #expect(!cron.humanReadable.isEmpty)

        let hourly = try CronExpression(parsing: "0 * * * *")
        #expect(!hourly.humanReadable.isEmpty)
    }

    @Test("Multi-line cron picks earliest next fire date")
    func multiLineNextFireDate() throws {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 2026, month: 5, day: 29, hour: 8, minute: 5))!
        let expressions = """
        10,40 8-11,14-21 * * 1-5
        15 8-11,14-21 * * 6,0
        """

        let next = CronExpression.nextFireDate(for: expressions, after: start)
        let expected = calendar.date(from: DateComponents(year: 2026, month: 5, day: 29, hour: 8, minute: 10))!

        #expect(next == expected)
    }

    @Test("Multi-line cron surfaces parse errors with line number")
    func multiLineParseError() {
        let error = CronExpression.firstParseError(in: """
        */30 * * * *
        bad cron
        """)

        #expect(error?.contains("Line 2") == true)
    }
}
