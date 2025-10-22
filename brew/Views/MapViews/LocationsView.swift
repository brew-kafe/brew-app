//
//  LocationsView.swift
//  brew
//
//  Created by AGRM on 09/09/25.
//

import SwiftUI
import MapKit

struct LocationsView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )
    )
    
    @State private var searchText = ""
    @State private var showSuggestions = false
    @State private var selectedFilter: pinKind? = nil
    @State private var selectedLocation: Location? = nil
    @State private var mapStyle: MapStyleOption = .hybrid
    
    // MARK: - Nueva sheet unificada
    @State private var activeSheet: SheetType? = nil
    
    enum MapStyleOption {
        case standard
        case hybrid
        case imagery
        
        var style: MapStyle {
            switch self {
            case .standard: return .standard(elevation: .realistic)
            case .hybrid: return .hybrid(elevation: .realistic)
            case .imagery: return .imagery(elevation: .realistic)
            }
        }
        
        var icon: String {
            switch self {
            case .standard: return "map"
            case .hybrid: return "map.fill"
            case .imagery: return "globe.americas.fill"
            }
        }
        
        var label: String {
            switch self {
            case .standard: return "Estándar"
            case .hybrid: return "Híbrido"
            case .imagery: return "Satélite"
            }
        }
    }
    
    enum SheetType: Identifiable {
        case preview(Location)
        case detail(Location)
        
        var id: String {
            switch self {
            case .preview(let loc): return "preview-\(loc.id)"
            case .detail(let loc): return "detail-\(loc.id)"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // MARK: - MAP
            Map(position: $cameraPosition) {
                ForEach(filteredLocations) { loc in
                    Annotation("", coordinate: loc.coordinates) {
                        marker(for: loc)
                            .scaleEffect(selectedLocation?.id == loc.id ? 1.4 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedLocation)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    selectedLocation = loc
                                    vm.showNextLocation(location: loc)
                                    activeSheet = .preview(loc)
                                    cameraPosition = .region(
                                        MKCoordinateRegion(
                                            center: loc.coordinates,
                                            latitudinalMeters: 2000,
                                            longitudinalMeters: 2000
                                        )
                                    )
                                }
                            }
                    }
                }
            }
            .mapControls {
                MapCompass()
                    .mapControlVisibility(.visible)
                MapPitchToggle()
                    .mapControlVisibility(.visible)
                MapUserLocationButton()
                    .mapControlVisibility(.visible)
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 280) // ✅ Updated to 200
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
            .mapStyle(mapStyle.style)
            .ignoresSafeArea()
            .onAppear {
                if let first = vm.locations.first {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: first.coordinates,
                            latitudinalMeters: 6000,
                            longitudinalMeters: 6000
                        )
                    )
                }
            }
            
            // MARK: - OVERLAYS
            VStack(spacing: 10) {
                searchBar
                    .padding(.horizontal, 20)
                    .safeAreaPadding(.top)
                
                filterBar
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // ✅ Map Style Toggle Button
                mapStyleToggle
                    .padding(.trailing, 20)
                    .padding(.bottom, 550)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // MARK: - SEARCH SUGGESTIONS
            if showSuggestions && !suggestedLocations.isEmpty {
                suggestionList
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        // MARK: - SHEET ÚNICA
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .preview(let location):
                LocationPreviewView(
                    location: location,
                    onDismiss: { activeSheet = nil },
                    onOpenDetail: { activeSheet = .detail(location) }
                )
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.hidden)
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(20)
                .interactiveDismissDisabled(false)
                
            case .detail(let location):
                LocationDetailView(location: location)
                .presentationDetents([.large])
            }
        }
    }
}

// MARK: - Filtering Logic
extension LocationsView {
    private var filteredLocations: [Location] {
        vm.locations.filter { loc in
            let matchesFilter = selectedFilter == nil || loc.kind == selectedFilter
            let matchesSearch = searchText.isEmpty ||
                loc.name.localizedCaseInsensitiveContains(searchText) ||
                loc.cityName.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }
    
    private var suggestedLocations: [Location] {
        guard !searchText.isEmpty else { return [] }
        return vm.locations.filter { loc in
            loc.name.localizedCaseInsensitiveContains(searchText) ||
            loc.cityName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - UI Components
extension LocationsView {
    
    // 🔍 Search bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.tint)
            
            TextField("Buscar parcela...", text: $searchText)
                .font(.subheadline)
                .onChange(of: searchText) { _, newVal in
                    withAnimation(.easeInOut) {
                        showSuggestions = !newVal.isEmpty
                    }
                }
                .onSubmit {
                    withAnimation(.easeOut) {
                        showSuggestions = false
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.tint.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    // 🌿 Filter bar
    private var filterBar: some View {
        HStack(spacing: 16) {
            filterButton(kind: nil, icon: "leaf.fill", color: .gray, label: "Todos")
            filterButton(kind: .safe, icon: "checkmark.circle.fill", color: .green, label: "Sanos")
            filterButton(kind: .risk, icon: "exclamationmark.circle.fill", color: .yellow, label: "En riesgo")
            filterButton(kind: .danger, icon: "xmark.octagon.fill", color: .red, label: "Con roya")
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(.regularMaterial))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private func filterButton(kind: pinKind?, icon: String, color: Color, label: String) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedFilter = selectedFilter == kind ? nil : kind
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            .padding(6)
            .frame(width: 70)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedFilter == kind ? color.opacity(0.15) : .clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    // 📍 Marker
    private func marker(for loc: Location) -> some View {
        let gradient: LinearGradient
        switch loc.kind {
        case .safe:
            gradient = LinearGradient(colors: [.green, .mint],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)
        case .risk:
            gradient = LinearGradient(colors: [.yellow, .orange],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)
        case .danger:
            gradient = LinearGradient(colors: [.red, .pink],
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)
        }
        
        return VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 34, height: 34)
                    .shadow(color: .black.opacity(0.25), radius: 5, y: 2)
                Image(systemName: iconForKind(loc.kind))
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .bold))
            }
            Text(loc.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 6))
        }
    }
    
    private func iconForKind(_ kind: pinKind) -> String {
        switch kind {
        case .safe: return "checkmark"
        case .risk: return "exclamationmark"
        case .danger: return "xmark"
        }
    }
    
    // 📜 Suggestion list
    private var suggestionList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(suggestedLocations) { loc in
                        Button {
                            withAnimation(.easeInOut) {
                                searchText = loc.name
                                showSuggestions = false
                                selectedFilter = nil
                                vm.showNextLocation(location: loc)
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: loc.coordinates,
                                        latitudinalMeters: 3000,
                                        longitudinalMeters: 3000
                                    )
                                )
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: iconForKind(loc.kind))
                                    .foregroundStyle(.primary)
                                VStack(alignment: .leading) {
                                    Text(loc.name)
                                        .font(.headline)
                                    Text(loc.cityName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(.regularMaterial)
                        }
                        Divider()
                    }
                }
            }
        }
        .frame(maxHeight: 200)
        .background(.regularMaterial)
        .cornerRadius(14)
        .padding(.horizontal, 20)
        .padding(.top, 120)
        .shadow(radius: 5)
    }
    
    // 🗺️ Map Style Toggle
    private var mapStyleToggle: some View {
        Menu {
            Button {
                withAnimation {
                    mapStyle = .standard
                }
            } label: {
                Label("Estándar", systemImage: "map")
            }
            
            Button {
                withAnimation {
                    mapStyle = .hybrid
                }
            } label: {
                Label("Híbrido", systemImage: "map.fill")
            }
            
            Button {
                withAnimation {
                    mapStyle = .imagery
                }
            } label: {
                Label("Satélite", systemImage: "globe.americas.fill")
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: mapStyle.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.primary)
                Text(mapStyle.label)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            )
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
    }
}

#Preview {
    LocationsView()
        .environmentObject(LocationsViewModel())
}

