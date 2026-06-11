//
//  ViewRenderingTests.swift
//  JobBoardTests
//
//  Created by Nikhil Shinde on 11/06/26.

#if canImport(UIKit)
import Testing
import SwiftUI
import UIKit
@testable import JobBoard

@MainActor
struct ViewRenderingTests {

    // MARK: - Helpers

    /// ImageRenderer walks the entire view tree synchronously, which
    /// guarantees the view body and inner closures actually execute.
    /// We discard the resulting image — we only care about the side
    /// effect of evaluating the body.
    private func render<V: View>(_ view: V) {
        let renderer = ImageRenderer(
            content: view.frame(width: 390, height: 844)
        )
        _ = renderer.cgImage
    }

    private func viewModel(behavior: MockJobService.Behavior) async -> JobListViewModel {
        let vm = JobListViewModel(service: MockJobService(behavior: behavior))
        await vm.load()
        return vm
    }

    // MARK: - JobRowView

    @Test
    func jobRow_renders() {
        render(JobRowView(job: JobSamples.make(title: "iOS Engineer", company: "TestCo")))
    }

    // MARK: - JobListView state branches

    @Test
    func jobListView_rendersLoadedState() async {
        let vm = await viewModel(behavior: .success(JobSamples.defaultList))
        render(JobListView(viewModel: vm))
    }

    @Test
    func jobListView_rendersEmptyState_noResults() async {
        let vm = await viewModel(behavior: .success([]))
        render(JobListView(viewModel: vm))
    }

    @Test
    func jobListView_rendersEmptyState_searchHasNoMatches() async {
        let vm = await viewModel(behavior: .success(JobSamples.defaultList))
        vm.searchText = "definitely no match"
        render(JobListView(viewModel: vm))
    }

    @Test
    func jobListView_rendersFailedState() async {
        let vm = await viewModel(behavior: .failure(JobServiceError.decodingFailed))
        render(JobListView(viewModel: vm))
    }

    @Test
    func jobListView_rendersIdleLoadingState() {
        // No await load() — view stays in .idle which renders the spinner.
        let vm = JobListViewModel(service: MockJobService(behavior: .success([])))
        render(JobListView(viewModel: vm))
    }

    // MARK: - JobDetailsView

    @Test
    func jobDetailsView_renders() {
        let job = JobSamples.make(title: "Senior iOS Engineer", company: "Vela")
        render(NavigationStack { JobDetailsView(job: job) })
    }
}
#endif
