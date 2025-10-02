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
    
    // 👇 Map style state
    @State private var selectedMapStyle: MapStyleOption = .hybrid

    
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
            // Ask for permission when view appears
            locationManager.requestWhenInUseAuthorization()
        }
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { location in
            LocationDetailView(location: location)
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

extension LocationsView {
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
    
    private var mapLayer: some View {
        Map {
            UserAnnotation()
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
        }
        .mapControls { } // disable Apple’s default placement
        .overlay(alignment: .bottomTrailing) {
            VStack(spacing: 8) {
                // Built-in controls
                MapUserLocationButton()
                    .mapControlVisibility(.visible)
                MapCompass()
                    .mapControlVisibility(.visible)
                MapPitchToggle()
                    .mapControlVisibility(.visible)
                MapScaleView()
                    .mapControlVisibility(.visible)
                
                // Custom map style button
                Button {
                    cycleMapStyle()
                } label: {
                    Image(systemName: selectedMapStyle.icon)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(radius: 3)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, 12)
            .padding(.bottom, 550)
        }
        .mapStyle(selectedMapStyle.style) // apply chosen style
    }
    
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
    
    // MARK: - Helpers
    private func cycleMapStyle() {
        switch selectedMapStyle {
        case .standard: selectedMapStyle = .satellite
        case .satellite: selectedMapStyle = .hybrid
        case .hybrid: selectedMapStyle = .standard
        }
    }
}

