//
//  AppDependencies.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import Foundation

struct AppDependencies {
    let jobService: JobService

    static func live() -> AppDependencies {
        AppDependencies(jobService: LocalJSONJobService())
    }
}
