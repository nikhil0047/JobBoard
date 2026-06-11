//
//  JobDetailsView.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import SwiftUI

struct JobDetailsView: View {
    let job: Job

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                Divider()
                section(title: "About the role", body: job.description)
                requirementsSection
                Divider()
                section(title: "About \(job.company)", body: job.companyDescription)
            }
            .padding()
        }
        .navigationTitle(job.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(job.title)
                .font(.title2.weight(.semibold))

            Text(job.company)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                Text(job.location)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(job.employmentType, systemImage: "briefcase")
                Label(job.salary.formatted(), systemImage: "indianrupeesign.circle")
                    .labelStyle(SalaryLabelStyle())
            }
            .font(.footnote)
            .foregroundStyle(.tint)
            .padding(.top, 4)

            Text("Posted \(job.postedDate, format: .relative(presentation: .named))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What we're looking for")
                .font(.headline)

            ForEach(job.requirements, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("•").foregroundStyle(.secondary)
                    Text(item)
                }
            }
        }
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(body).font(.body)
        }
    }
}

/// Currency icons are inconsistent across SF Symbols, so just drop the
/// icon for the salary label and show the text only.
private struct SalaryLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.title
    }
}

#Preview {
    NavigationStack {
        JobDetailsView(job: Job(
            id: "preview",
            title: "Senior iOS Engineer",
            company: "Vela Mobility",
            companyDescription: "Vela builds shared transit software used by city operators across South and Southeast Asia.",
            location: "Bengaluru, India · Hybrid",
            employmentType: "Full-time",
            salary: .init(min: 4_500_000, max: 6_500_000, currency: "INR", period: .year),
            description: "We're looking for an iOS engineer to take ownership of our driver and rider apps.",
            requirements: ["Swift", "SwiftUI", "5+ years"],
            postedDate: .now.addingTimeInterval(-86_400 * 3)
        ))
    }
}
