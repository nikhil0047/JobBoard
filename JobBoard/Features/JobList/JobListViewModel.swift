//
//  JobListViewModel.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import Foundation
import Observation

@MainActor
@Observable
final class JobListViewModel {

    private(set) var state: ViewState<[Job]> = .idle
    var searchText: String = "" {
        didSet { applyFilter() }
    }

    private let service: JobService
    private var allJobs: [Job] = []

    init(service: JobService) {
        self.service = service
    }

    func load() async {
        // Only show the spinner on a cold load. A refresh keeps existing
        // rows on screen so the list doesn't flash.
        if allJobs.isEmpty {
            state = .loading
        }

        do {
            let jobs = try await service.fetchJobs()
            allJobs = jobs
            applyFilter()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func refresh() async {
        // Force a reload regardless of current state.
        do {
            let jobs = try await service.fetchJobs()
            allJobs = jobs
            applyFilter()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    // MARK: - Filtering

    private func applyFilter() {
        guard !allJobs.isEmpty else {
            state = .empty
            return
        }

        let results = Self.filter(allJobs, by: searchText)
        state = results.isEmpty ? .empty : .loaded(results)
    }

    /// Pure function so the filtering logic is easy to unit test.
    static func filter(_ jobs: [Job], by query: String) -> [Job] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return jobs }

        return jobs.filter { job in
            job.title.localizedCaseInsensitiveContains(trimmed) ||
            job.company.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
