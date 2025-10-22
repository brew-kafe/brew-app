//
//  ElementListResponse.swift
//  brew
//
//  Created by toño on 21/10/25.
//

import Foundation

/// Response containing list of supported nutrient elements
struct ElementListResponse: Codable {
    let elements: [String]
}

