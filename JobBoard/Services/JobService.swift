//
//  JobService.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.


import Foundation

protocol JobService: Sendable {
    func fetchJobs() async throws -> [Job]
}

enum JobServiceError: Error, LocalizedError, Equatable {
    case resourceMissing(String)
    case decodingFailed
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .resourceMissing(let name):
            return "Couldn't find \(name) in the app bundle."
        case .decodingFailed:
            return "The job feed is in an unexpected format."
        case .underlying(let message):
            return message
        }
    }
}
