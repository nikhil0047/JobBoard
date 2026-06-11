//
//  ViewState.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import Foundation

/// Generic state container used by view models to drive the UI.
/// Keeps loading / loaded / empty / failure paths explicit so the views
/// never have to juggle multiple optional flags.
enum ViewState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(String)
}

extension ViewState {
    var value: Value? {
        if case let .loaded(value) = self { return value }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
