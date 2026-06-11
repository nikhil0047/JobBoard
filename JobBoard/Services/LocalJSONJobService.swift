//
//  LocalJSONJobService.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import Foundation

final class LocalJSONJobService: JobService {
    private let bundle: Bundle
    private let resourceName: String
    private let simulatedDelay: Duration

    init(
        bundle: Bundle = .main,
        resourceName: String = "jobs",
        simulatedDelay: Duration = .milliseconds(600)
    ) {
        self.bundle = bundle
        self.resourceName = resourceName
        self.simulatedDelay = simulatedDelay
    }

    func fetchJobs() async throws -> [Job] {
        if simulatedDelay > .zero {
            try? await Task.sleep(for: simulatedDelay)
        }

        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw JobServiceError.resourceMissing("\(resourceName).json")
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw JobServiceError.underlying(error.localizedDescription)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode([Job].self, from: data)
        } catch {
            throw JobServiceError.decodingFailed
        }
    }
}
