//
//  PlantHealth.swift
//  brew
//
//  Created by toño on 14/10/25.
//

import Foundation

enum PlantHealth: String, Codable, CaseIterable {
    case healthy = "Saludable"
    case fair = "Regular"
    case poor = "Deficiente"
}
