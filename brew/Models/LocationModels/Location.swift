//
//  Location.swift
//  brew
//
//  Created by AGRM  on 09/09/25.
//

import Foundation
import MapKit

enum pinKind: String, Codable, CaseIterable {
    case danger, risk, safe
}

struct plotMetrics: Codable {
    let sun: Int            // % of useful sunlight
    let moisture: Int       // % of soil moisture
    let pestSeverity: Int   // % severity of pest/disease
    let potassium: String?  // Potassium level
    let phosphorus: String? // Phosphorus level
}

struct plotReport: Identifiable, Codable {
    var id = UUID()
    let code: String
    let date: Date
    let manager: String
    let file: String?  // file name or PDF URL
}

struct Location: Identifiable, Equatable {
    let name: String
    let cityName: String
    let coordinates: CLLocationCoordinate2D
    let description: String
    let imageNames: [String]
    let link: String
    let kind: pinKind
    let metrics: plotMetrics
    let reports: [plotReport]
    
    var id: String {
        name + cityName
    }
    
    // equatable in case they have the same id but are different
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

