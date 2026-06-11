//
//  JobRowView.swift
//  JobBoard
//
//  Created by Nikhil Shinde on 11/06/26.

import SwiftUI

struct JobRowView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(job.company)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                Text(job.location)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(job.salary.formatted())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sample = Job(
        id: "preview",
        title: "Senior iOS Engineer",
        company: "Vela Mobility",
        companyDescription: "Preview",
        location: "Bengaluru, India · Hybrid",
        employmentType: "Full-time",
        salary: .init(min: 4_500_000, max: 6_500_000, currency: "INR", period: .year),
        description: "Preview description",
        requirements: ["Swift", "SwiftUI"],
        postedDate: .now
    )

    return List {
        JobRowView(job: sample)
    }
}
