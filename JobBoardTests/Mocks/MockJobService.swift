//
//  MockJobService.swift
//  JobBoardTests
//
//  Created by Nikhil Shinde on 11/06/26.

import Foundation
@testable import JobBoard

/// Test double for JobService. Either returns a canned list of jobs or
/// throws a supplied error. Tracks how many times fetchJobs() was called.
final class MockJobService: JobService, @unchecked Sendable {
    enum Behavior {
        case success([Job])
        case failure(Error)
    }

    private let lock = NSLock()
    private var _behavior: Behavior
    private var _callCount = 0

    init(behavior: Behavior) {
        self._behavior = behavior
    }

    var callCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _callCount
    }

    func setBehavior(_ behavior: Behavior) {
        lock.lock(); defer { lock.unlock() }
        self._behavior = behavior
    }

    func fetchJobs() async throws -> [Job] {
        let snapshot: Behavior = {
            lock.lock(); defer { lock.unlock() }
            _callCount += 1
            return _behavior
        }()

        switch snapshot {
        case .success(let jobs): return jobs
        case .failure(let error): throw error
        }
    }
}

// MARK: - Sample data

enum JobSamples {
    static func make(
        id: String = UUID().uuidString,
        title: String = "iOS Engineer",
        company: String = "Acme"
    ) -> Job {
        Job(
            id: id,
            title: title,
            company: company,
            companyDescription: "Sample company.",
            location: "Remote",
            employmentType: "Full-time",
            salary: SalaryRange(min: 50_000, max: 80_000, currency: "USD", period: .year),
            description: "Sample description.",
            requirements: ["Swift"],
            postedDate: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    static let defaultList: [Job] = [
        make(id: "1", title: "Senior iOS Engineer", company: "Vela"),
        make(id: "2", title: "Android Engineer", company: "Vela"),
        make(id: "3", title: "iOS Engineer", company: "Northwind"),
        make(id: "4", title: "Backend Engineer", company: "Atlas")
    ]
}
