//
//  AssessmentReport.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import Foundation

struct AssessmentReport: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    let images: [String]
}
