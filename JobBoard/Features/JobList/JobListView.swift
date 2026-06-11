//
//  JobListView.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import SwiftUI

struct JobListView: View {
    @State private var viewModel: JobListViewModel

    init(viewModel: JobListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Jobs")
                #if os(iOS)
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search title or company"
                )
                #else
                .searchable(
                    text: $viewModel.searchText,
                    prompt: "Search title or company"
                )
                #endif
                .refreshable {
                    await viewModel.refresh()
                }
                .task {
                    await viewModel.load()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading jobs…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            emptyView

        case .failed(let message):
            errorView(message: message)

        case .loaded(let jobs):
            List {
                ForEach(jobs) { job in
                    NavigationLink(value: job) {
                        JobRowView(job: job)
                    }
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: Job.self) { job in
                JobDetailsView(job: job)
            }
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            viewModel.searchText.isEmpty ? "No jobs yet" : "No matches",
            systemImage: "tray",
            description: Text(
                viewModel.searchText.isEmpty
                    ? "Pull to refresh once new openings are posted."
                    : "Try a different title or company name."
            )
        )
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Button("Try again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    JobListView(viewModel: JobListViewModel(service: LocalJSONJobService(simulatedDelay: .zero)))
}
