//
//  DetectionStateResponse.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct DetectionStateInfo: Codable, Hashable {
    let label: String
    let color: String
    let description: String
}

struct DetectionStateResponse: Codable {
    let states: [String: DetectionStateInfo]
}

