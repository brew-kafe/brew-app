//
//  ElementListResponse.swift
//  brew
//
//  Created by toño on 09/10/25.
//

import Foundation

struct ElementInfo: Codable, Hashable {
    let key: String
    let name: String
    let symbol: String
}

struct ElementListResponse: Codable {
    let elements: [ElementInfo]
}
