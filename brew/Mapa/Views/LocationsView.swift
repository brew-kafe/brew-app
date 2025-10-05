//
//  LocationsView.swift
//  brew
//
//  Created by AGRM on 09/09/25.
//

import SwiftUI
import MapKit

struct LocationsView: View {
    
    let locationManager = CLLocationManager() // for onboarding
    @EnvironmentObject private var vm: LocationsViewModel
    
    // Map style state
    @State private var selectedMapStyle: MapStyleOption = .hybrid
    @State private var showPhotoGuidanceControls = false
    
    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                    .padding()
                Spacer()
                locationsPreviewStack
            }
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { location in
            LocationDetailView(location: location)
        }
        // Overlay for Guided Photo Mode
        .overlay(alignment: .bottomLeading) {
            photoGuidanceOverlay
        }
    }
}

struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
            .environmentObject(LocationsViewModel())
    }
}

// MARK: - MapStyleOption Enum
enum MapStyleOption {
    case standard, satellite, hybrid
    
    var style: MapStyle {
        switch self {
        case .standard: return .standard
        case .satellite: return .imagery
        case .hybrid: return .hybrid(elevation: .realistic)
        }
    }
    
    var icon: String {
        switch self {
        case .standard: return "map"
        case .satellite: return "sparkles"
        case .hybrid: return "globe.americas.fill"
        }
    }
}

// MARK: - Main View Extension
extension LocationsView {
    
    // HEADER
    private var header: some View {
        VStack {
            Button(action: vm.toggleLocationsList) {
                Text(vm.mapLocation.name)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .animation(.none, value: vm.mapLocation)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }
            if vm.showLocationsList {
                LocationsListView()
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    
    
    // MAP LAYER
    private var mapLayer: some View {
        Map {
            UserAnnotation()
            
            // Regular parcel annotations
            ForEach(vm.locations) { location in
                Annotation(location.name, coordinate: location.coordinates, anchor: .center) {
                    Group {
                        switch location.kind {
                        case .danger:
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .padding(7)
                                .background(.red.gradient, in: .circle)
                            
                        case .risk:
                            Image(systemName: "asterisk.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .padding(7)
                                .background(.yellow.gradient, in: .circle)
                            
                        case .safe:
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .padding(7)
                                .background(.green.gradient, in: .circle)
                        }
                    }
                    .scaleEffect(vm.mapLocation == location ? 1.2 : 0.8)
                    .shadow(radius: 6)
                    .onTapGesture {
                        vm.showNextLocation(location: location)
                    }
                }
            }
            
            // Photo guidance points
            if let profile = vm.photoGuidanceProfile {
                ForEach(profile.points) { point in
                    Annotation(point.label, coordinate: point.coordinate) {
                        VStack {
                            if point.isCaptured {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "camera.circle")
                                    .foregroundStyle(.blue)
                                    .scaleEffect(1.2)
                                    .shadow(color: .blue.opacity(0.6), radius: 5)
                            }
                            Text(point.label)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(3)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(6)
                        }
                        .onTapGesture {
                            vm.markPhotoCaptured(point: point)
                        }
                    }
                }
            }
            
            // Route line (placed outside annotations)
            if let route = vm.routePolyline {
                MapPolyline(route)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            }
        }
        .mapControls { } // disables built-in ones
        .overlay(alignment: .bottomTrailing) {
            Button {
                cycleMapStyle()
            } label: {
                Image(systemName: selectedMapStyle.icon)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(radius: 3)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
            .padding(.bottom, 550)
        }
        .mapStyle(selectedMapStyle.style)
    }
    
    
    // PREVIEW CARD STACK
    private var locationsPreviewStack: some View {
        ZStack {
            ForEach(vm.locations) { location in
                if vm.mapLocation == location {
                    LocationPreviewView(location: location)
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                        .padding()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
    
    // Overlay Controls for Guided Photo Mode
    private var photoGuidanceOverlay: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                vm.startGuidedPhoto(for: vm.mapLocation)
                showPhotoGuidanceControls = true
            } label: {
                Label("Iniciar Guía Fotográfica", systemImage: "camera.viewfinder")
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
            }
            
            if showPhotoGuidanceControls {
                if let next = vm.getNextPhotoPoint() {
                    Button {
                        withAnimation(.easeInOut) {
                            vm.markPhotoCaptured(point: next)
                            vm.focusOn(point: next)
                        }
                    } label: {
                        Label("Siguiente Punto: \(next.label)", systemImage: "arrow.forward.circle")
                            .padding()
                            .background(.blue.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                    }
                } else if vm.photoGuidanceProfile?.allCaptured == true {
                    Text("Todas las fotos capturadas")
                        .font(.subheadline)
                        .padding(8)
                        .background(.green.opacity(0.8), in: RoundedRectangle(cornerRadius: 10))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showPhotoGuidanceControls = false
                            }
                        }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Helpers
    private func cycleMapStyle() {
        switch selectedMapStyle {
        case .standard: selectedMapStyle = .satellite
        case .satellite: selectedMapStyle = .hybrid
        case .hybrid: selectedMapStyle = .standard
        }
    }
}

