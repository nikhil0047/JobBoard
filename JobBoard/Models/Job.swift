//
//  Job.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import Foundation

struct Job: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let company: String
    let companyDescription: String
    let location: String
    let employmentType: String
    let salary: SalaryRange
    let description: String
    let requirements: [String]
    let postedDate: Date
}

struct SalaryRange: Codable, Hashable {
    let min: Int
    let max: Int
    let currency: String
    let period: Period

    enum Period: String, Codable {
        case year
        case month
        case hour
    }
}

extension SalaryRange {
    /// Human friendly representation, e.g. "$120,000 – $150,000 / year".
    /// Locale is overridable so tests can pin to a known format.
    func formatted(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0

        let low = formatter.string(from: NSNumber(value: min)) ?? "\(min)"
        let high = formatter.string(from: NSNumber(value: max)) ?? "\(max)"
        return "\(low) – \(high) / \(period.rawValue)"
    }
}
