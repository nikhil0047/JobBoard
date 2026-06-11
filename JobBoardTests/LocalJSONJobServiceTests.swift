//
//  LocalJSONJobServiceTests.swift
//  JobBoardTests
//

import Testing
import Foundation
@testable import JobBoard

/// Anchors the test bundle so we can look up our test JSON fixtures.
private final class TestBundleAnchor {}

struct LocalJSONJobServiceTests {

    private var testBundle: Bundle { Bundle(for: TestBundleAnchor.self) }

    @Test
    func fetchJobs_decodesValidJSON() async throws {
        let sut = LocalJSONJobService(
            bundle: testBundle,
            resourceName: "jobs_test",
            simulatedDelay: .zero
        )

        let jobs = try await sut.fetchJobs()

        #expect(jobs.count == 2)
        #expect(jobs.first?.title == "Test iOS Engineer")
        #expect(jobs.first?.salary.period == .year)
        #expect(jobs.last?.salary.period == .hour)
    }

    @Test
    func fetchJobs_missingResource_throwsResourceMissing() async {
        let sut = LocalJSONJobService(
            bundle: testBundle,
            resourceName: "nope_doesnt_exist",
            simulatedDelay: .zero
        )

        await #expect(throws: JobServiceError.resourceMissing("nope_doesnt_exist.json")) {
            _ = try await sut.fetchJobs()
        }
    }

    @Test
    func fetchJobs_invalidJSON_throwsDecodingFailed() async {
        let sut = LocalJSONJobService(
            bundle: testBundle,
            resourceName: "jobs_broken",
            simulatedDelay: .zero
        )

        await #expect(throws: JobServiceError.decodingFailed) {
            _ = try await sut.fetchJobs()
        }
    }

    // MARK: - SalaryRange formatting

    @Test
    func salaryRange_formatsHumanReadableString() {
        let salary = SalaryRange(min: 120_000, max: 150_000, currency: "USD", period: .year)
        let formatted = salary.formatted(locale: Locale(identifier: "en_US"))

        #expect(formatted == "$120,000 – $150,000 / year")
    }

    @Test
    func salaryRange_formatsHourlyRates() {
        let salary = SalaryRange(min: 70, max: 95, currency: "EUR", period: .hour)
        let formatted = salary.formatted(locale: Locale(identifier: "en_IE"))

        #expect(formatted.contains("70"))
        #expect(formatted.contains("95"))
        #expect(formatted.contains("hour"))
    }
}
