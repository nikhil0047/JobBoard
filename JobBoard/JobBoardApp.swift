//
//  JobBoardApp.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import SwiftUI

@main
struct JobBoardApp: App {
    private let dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            JobListView(
                viewModel: JobListViewModel(service: dependencies.jobService)
            )
        }
    }
}
