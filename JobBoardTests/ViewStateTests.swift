//
//  ViewStateTests.swift
//  JobBoardTests
//
//  Created by Nikhil Shinde on 11/06/26.

import Testing
@testable import JobBoard

struct ViewStateTests {

    @Test
    func value_returnsPayloadOnlyWhenLoaded() {
        let loaded: ViewState<[Int]> = .loaded([1, 2, 3])
        let loading: ViewState<[Int]> = .loading
        let idle: ViewState<[Int]> = .idle
        let empty: ViewState<[Int]> = .empty
        let failed: ViewState<[Int]> = .failed("nope")

        #expect(loaded.value == [1, 2, 3])
        #expect(loading.value == nil)
        #expect(idle.value == nil)
        #expect(empty.value == nil)
        #expect(failed.value == nil)
    }

    @Test
    func isLoading_isTrueOnlyForLoadingCase() {
        #expect(ViewState<Int>.loading.isLoading)
        #expect(!ViewState<Int>.idle.isLoading)
        #expect(!ViewState<Int>.empty.isLoading)
        #expect(!ViewState<Int>.failed("x").isLoading)
        #expect(!ViewState<Int>.loaded(1).isLoading)
    }
}
