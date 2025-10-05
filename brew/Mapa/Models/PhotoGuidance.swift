//
//  PhotoGuidance.swift
//  brew
//
//  Created by AGRM on 05/10/25.
//

import Foundation
import CoreLocation

// MARK: - PhotoPoint
struct PhotoPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let coordinate: CLLocationCoordinate2D
    var isCaptured: Bool = false

    // (CLLocationCoordinate2D is not Equatable)
    static func == (lhs: PhotoPoint, rhs: PhotoPoint) -> Bool {
        lhs.id == rhs.id &&
        lhs.label == rhs.label &&
        abs(lhs.coordinate.latitude - rhs.coordinate.latitude) < 0.000001 &&
        abs(lhs.coordinate.longitude - rhs.coordinate.longitude) < 0.000001
    }
}

// MARK: - PhotoGuidanceProfile
struct PhotoGuidanceProfile {
    let parcelID: UUID
    var points: [PhotoPoint]
    
    var nextUncaptured: PhotoPoint? {
        points.first(where: { !$0.isCaptured })
    }
    
    var allCaptured: Bool {
        points.allSatisfy { $0.isCaptured }
    }
}

