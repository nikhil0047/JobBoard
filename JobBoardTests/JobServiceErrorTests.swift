//
//  JobServiceErrorTests.swift
//  JobBoardTests
//
//  Created by Nikhil Shinde on 11/06/26.

import Testing
@testable import JobBoard

struct JobServiceErrorTests {

    @Test
    func resourceMissing_includesResourceNameInDescription() {
        let error = JobServiceError.resourceMissing("jobs.json")
        #expect(error.errorDescription?.contains("jobs.json") == true)
    }

    @Test
    func decodingFailed_returnsFormatMessage() {
        let error = JobServiceError.decodingFailed
        #expect(error.errorDescription == "The job feed is in an unexpected format.")
    }

    @Test
    func underlying_returnsWrappedMessage() {
        let error = JobServiceError.underlying("connection lost")
        #expect(error.errorDescription == "connection lost")
    }
}
