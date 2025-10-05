//
//  Report.swift
//  brew
//
//  Created by toño on 04/10/25.
//

import Foundation

struct Report: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: Date
    let status: String
    let technician: String
}

