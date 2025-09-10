//
//  Location.swift
//  brew
//
//  Created by AGRM  on 09/09/25.
//

import Foundation
import MapKit

struct Location: Identifiable, Equatable {
    let name: String
    let cityName: String
    let coordinates: CLLocationCoordinate2D
    let description: String
    let imageNames: [String]
    let link: String
    
    var id: String{
        name + cityName
    }
    
    // equatable in case they have the same id but are different
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
