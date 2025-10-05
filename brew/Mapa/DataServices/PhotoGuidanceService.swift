//
//  PhotoGuidanceService.swift
//  brew
//
//  Created by AGRM on 05/10/25.
//

import Foundation
import CoreLocation
import MapKit

final class PhotoGuidanceService {
    
    // Simulates generation of photo points around a parcel
    func generatePoints(around coordinate: CLLocationCoordinate2D) -> [PhotoPoint] {
        return [
            PhotoPoint(label: "Frontal", coordinate: offset(from: coordinate, lat: 0.0005, lon: 0)),
            PhotoPoint(label: "Izquierda", coordinate: offset(from: coordinate, lat: 0, lon: -0.0005)),
            PhotoPoint(label: "Derecha", coordinate: offset(from: coordinate, lat: 0, lon: 0.0005)),
            PhotoPoint(label: "Centro", coordinate: coordinate),
            PhotoPoint(label: "Posterior", coordinate: offset(from: coordinate, lat: -0.0005, lon: 0))
        ]
    }
    
    // Offset helper for positioning
    private func offset(from coord: CLLocationCoordinate2D, lat: Double, lon: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coord.latitude + lat, longitude: coord.longitude + lon)
    }
    
    // Computes distance between two coordinates in meters
    func distance(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
        let locA = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let locB = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return locA.distance(from: locB)
    }
    
    // Creates a polyline for Map rendering
    func routeLine(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> MKPolyline {
        let coords = [start, end]
        return MKPolyline(coordinates: coords, count: coords.count)
    }
}

