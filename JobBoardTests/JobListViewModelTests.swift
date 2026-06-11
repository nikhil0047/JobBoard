//
//  JobListViewModelTests.swift
//  JobBoardTests
//
//  Created by Nikhil Shinde on 11/06/26.

import Testing
import Foundation
@testable import JobBoard

@MainActor
struct JobListViewModelTests {

    // MARK: - Loading

    @Test
    func loadingSucceeds_publishesLoadedState() async throws {
        let service = MockJobService(behavior: .success(JobSamples.defaultList))
        let sut = JobListViewModel(service: service)

        await sut.load()

        let jobs = try #require(sut.state.value)
        #expect(jobs.count == JobSamples.defaultList.count)
        #expect(service.callCount == 1)
    }

    @Test
    func loadingFails_publishesFailedState() async {
        let service = MockJobService(behavior: .failure(JobServiceError.decodingFailed))
        let sut = JobListViewModel(service: service)

        await sut.load()

        guard case .failed(let message) = sut.state else {
            Issue.record("Expected failed state, got \(sut.state)")
            return
        }
        #expect(message == JobServiceError.decodingFailed.errorDescription)
    }

    @Test
    func loadingEmptyResult_publishesEmptyState() async {
        let service = MockJobService(behavior: .success([]))
        let sut = JobListViewModel(service: service)

        await sut.load()

        if case .empty = sut.state {
            // expected
        } else {
            Issue.record("Expected empty state, got \(sut.state)")
        }
    }

    // MARK: - Search

    @Test
    func searchingByTitle_filtersResults() async throws {
        let sut = JobListViewModel(
            service: MockJobService(behavior: .success(JobSamples.defaultList))
        )
        await sut.load()

        sut.searchText = "ios"

        let jobs = try #require(sut.state.value)
        #expect(jobs.count == 2)
        #expect(jobs.allSatisfy { $0.title.localizedCaseInsensitiveContains("ios") })
    }

    @Test
    func searchingByCompany_filtersResults() async throws {
        let sut = JobListViewModel(
            service: MockJobService(behavior: .success(JobSamples.defaultList))
        )
        await sut.load()

        sut.searchText = "Vela"

        let jobs = try #require(sut.state.value)
        #expect(jobs.count == 2)
        #expect(jobs.allSatisfy { $0.company == "Vela" })
    }

    @Test
    func searchIsCaseInsensitive() async throws {
        let sut = JobListViewModel(
            service: MockJobService(behavior: .success(JobSamples.defaultList))
        )
        await sut.load()

        sut.searchText = "NORTHWIND"

        let jobs = try #require(sut.state.value)
        #expect(jobs.count == 1)
        #expect(jobs.first?.company == "Northwind")
    }

    @Test
    func searchWithNoMatches_publishesEmptyState() async {
        let sut = JobListViewModel(
            service: MockJobService(behavior: .success(JobSamples.defaultList))
        )
        await sut.load()

        sut.searchText = "nothing matches this"

        if case .empty = sut.state {
            // expected
        } else {
            Issue.record("Expected empty state, got \(sut.state)")
        }
    }

    @Test
    func clearingSearch_restoresFullList() async throws {
        let sut = JobListViewModel(
            service: MockJobService(behavior: .success(JobSamples.defaultList))
        )
        await sut.load()

        sut.searchText = "Vela"
        sut.searchText = ""

        let jobs = try #require(sut.state.value)
        #expect(jobs.count == JobSamples.defaultList.count)
    }

    @Test
    func whitespaceOnlySearch_isTreatedAsEmpty() async throws {
        let sut = JobListViewModel(
            service: MockJobService(behavior: .success(JobSamples.defaultList))
        )
        await sut.load()

        sut.searchText = "   "

        let jobs = try #require(sut.state.value)
        #expect(jobs.count == JobSamples.defaultList.count)
    }

    // MARK: - Refresh

    @Test
    func refresh_callsServiceAgain() async {
        let service = MockJobService(behavior: .success(JobSamples.defaultList))
        let sut = JobListViewModel(service: service)

        await sut.load()
        await sut.refresh()

        #expect(service.callCount == 2)
    }

    @Test
    func refresh_picksUpNewlyAvailableJobs() async throws {
        let service = MockJobService(behavior: .success([]))
        let sut = JobListViewModel(service: service)

        await sut.load()
        if case .empty = sut.state { /* good */ } else {
            Issue.record("Precondition: expected empty state")
        }

        service.setBehavior(.success(JobSamples.defaultList))
        await sut.refresh()

        let jobs = try #require(sut.state.value)
        #expect(jobs.count == JobSamples.defaultList.count)
    }

    // MARK: - Pure filter function

    @Test
    func filter_emptyQueryReturnsAll() {
        let jobs = JobSamples.defaultList
        let result = JobListViewModel.filter(jobs, by: "")
        #expect(result.count == jobs.count)
    }

    @Test
    func filter_matchesEitherTitleOrCompany() {
        let jobs = JobSamples.defaultList
        let result = JobListViewModel.filter(jobs, by: "Engineer")
        // All sample jobs have "Engineer" in the title.
        #expect(result.count == jobs.count)
    }
}
