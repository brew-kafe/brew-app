//
//  LocationsViewModel.swift
//  brew
//
//  Created by AGRM on 10/09/25.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation

class LocationsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    @Published var locations: [Location]
    @Published var mapLocation: Location? = nil        // ✅ now optional
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var showLocationsList: Bool = false
    @Published var sheetLocation: Location? = nil
    
    // Photo Guidance
    @Published var photoGuidanceProfile: PhotoGuidanceProfile? = nil
    @Published var routePolyline: MKPolyline? = nil
    @Published var userLocation: CLLocationCoordinate2D? = nil
    
    private let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    private let guidanceService = PhotoGuidanceService()
    private let locationManager = CLLocationManager()
    
    // MARK: - Init
    override init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first
        super.init()
        if let first = mapLocation {
            updateMapRegion(location: first)
        }
        configureLocationManager()
    }
    
    // MARK: - CoreLocation setup
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userLocation = loc.coordinate
        checkProximityToNextPoint()
        updateRouteLine()
    }
    
    // MARK: - Map Logic
    func updateMapRegion(location: Location) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(center: location.coordinates, span: mapSpan)
        }
    }
    
    func toggleLocationsList() {
        withAnimation(.easeInOut) { showLocationsList.toggle() }
    }
    
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationsList = false
            updateMapRegion(location: location)
        }
    }
    
    func nextButtonPressed() {
        guard let current = mapLocation,
              let currentIndex = locations.firstIndex(where: { $0 == current }) else { return }
        
        let nextIndex = (currentIndex + 1) % locations.count
        showNextLocation(location: locations[nextIndex])
    }
    
    func closePreview() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            mapLocation = nil
        }
    }
    
    // MARK: - Photo Guidance Logic
    func startGuidedPhoto(for location: Location) {
        let points = guidanceService.generatePoints(around: location.coordinates)
        photoGuidanceProfile = PhotoGuidanceProfile(parcelID: UUID(), points: points)
        updateRouteLine()
    }
    
    func markPhotoCaptured(point: PhotoPoint) {
        guard var profile = photoGuidanceProfile else { return }
        if let i = profile.points.firstIndex(of: point) {
            profile.points[i].isCaptured = true
            photoGuidanceProfile = profile
        }
        updateRouteLine()
    }
    
    func getNextPhotoPoint() -> PhotoPoint? {
        return photoGuidanceProfile?.nextUncaptured
    }
    
    private func updateRouteLine() {
        guard let userLoc = userLocation,
              let next = getNextPhotoPoint() else {
            routePolyline = nil
            return
        }
        routePolyline = guidanceService.routeLine(from: userLoc, to: next.coordinate)
    }
    
    private func checkProximityToNextPoint() {
        guard let userLoc = userLocation,
              let next = getNextPhotoPoint() else { return }
        
        let distance = guidanceService.distance(from: userLoc, to: next.coordinate)
        if distance < 8 {
            markPhotoCaptured(point: next)
            print("📸 Punto \(next.label) capturado automáticamente (distancia \(Int(distance))m)")
        }
    }
    
    // MARK: - Focus & Route
    func focusOn(point: PhotoPoint) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(
                center: point.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
            )
        }
        
        if let userLoc = userLocation {
            let coords = [userLoc, point.coordinate]
            routePolyline = MKPolyline(coordinates: coords, count: coords.count)
        }
    }
}

