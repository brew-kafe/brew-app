//
//  Location.swift
//  brew
//
//  Created by AGRM  on 09/09/25.
//

import Foundation
import MapKit

enum PinKind: String, Codable, CaseIterable {
    case danger, risk, safe
}

struct Location: Identifiable, Equatable {
    let name: String
    let cityName: String
    //let parcelaRegion???
    let coordinates: CLLocationCoordinate2D
    let description: String
    let imageNames: [String]
    let link: String
    let kind: PinKind
    
    var id: String{
        name + cityName
    }
    
    // equatable in case they have the same id but are different
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
