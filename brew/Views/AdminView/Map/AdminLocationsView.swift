//
//  AdminLocationsView.swift
//  brew
//
//  Created for Admin Dashboard
//

import SwiftUI
import MapKit

struct AdminLocationsView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 15.7845, longitude: -92.7611),
            latitudinalMeters: 15000,
            longitudinalMeters: 15000
        )
    )
    
    @State private var searchText = ""
    @State private var showSuggestions = false
    @State private var selectedFilter: pinKind? = nil
    @State private var selectedLocation: Location? = nil
    @State private var mapStyle: MapStyleOption = .hybrid
    @State private var activeSheet: SheetType? = nil
    @State private var showStatistics = false
    
    enum MapStyleOption {
        case standard, hybrid, imagery
        
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
    }
    
    enum SheetType: Identifiable {
        case preview(Location)
        case detail(Location)
        case statistics
        
        var id: String {
            switch self {
            case .preview(let loc): return "preview-\(loc.id)"
            case .detail(let loc): return "detail-\(loc.id)"
            case .statistics: return "statistics"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // MAP
            Map(position: $cameraPosition) {
                ForEach(filteredLocations) { loc in
                    Annotation("", coordinate: loc.coordinates) {
                        marker(for: loc)
                            .scaleEffect(selectedLocation?.id == loc.id ? 1.4 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedLocation)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    selectedLocation = loc
                                    vm.mapLocation = loc
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
                MapPitchToggle()
                    .mapControlVisibility(.visible)
                MapCompass()
                    .mapControlVisibility(.visible)
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 320)
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
                            latitudinalMeters: 15000,
                            longitudinalMeters: 15000
                        )
                    )
                }
            }
            
            // OVERLAYS
            VStack(spacing: 16) {
                adminHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                
                searchBar
                    .padding(.horizontal, 20)
                
                filterBar
                    .padding(.horizontal, 20)
                
                Spacer()
                
                HStack {
                    mapStyleToggle
                    Spacer()
                    statisticsButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            
            // SEARCH SUGGESTIONS
            if showSuggestions && !suggestedLocations.isEmpty {
                suggestionList
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .preview(let location):
                AdminLocationPreviewView(
                    location: selectedLocation ?? location,
                    onDismiss: { activeSheet = nil },
                    onOpenDetail: {
                        if let selected = selectedLocation {
                            activeSheet = .detail(selected)
                        }
                    },
                    onNext: { nextLoc in
                        selectedLocation = nextLoc
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: nextLoc.coordinates,
                                latitudinalMeters: 2000,
                                longitudinalMeters: 2000
                            )
                        )
                    }
                )
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.hidden)
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(20)
                
            case .detail(let location):
                LocationDetailView(location: location)
                    .presentationDetents([.large])
                
            case .statistics:
                AdminStatisticsView(locations: vm.locations)
                    .presentationDetents([.fraction(0.6), .large])
            }
        }
    }
}

// MARK: - Filtering Logic
extension AdminLocationsView {
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
    
    private var stats: (total: Int, safe: Int, risk: Int, danger: Int) {
        let total = vm.locations.count
        let safe = vm.locations.filter { $0.kind == .safe }.count
        let risk = vm.locations.filter { $0.kind == .risk }.count
        let danger = vm.locations.filter { $0.kind == .danger }.count
        return (total, safe, risk, danger)
    }
}

// MARK: - UI Components
extension AdminLocationsView {
    
    private var adminHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Panel Administrativo")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text("\(stats.total) parcelas monitoreadas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                AdminStatBadge(count: stats.safe, color: .green, icon: "checkmark.circle.fill")
                AdminStatBadge(count: stats.risk, color: .yellow, icon: "exclamationmark.triangle.fill")
                AdminStatBadge(count: stats.danger, color: .red, icon: "xmark.octagon.fill")
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.tint)
            
            TextField("Buscar parcela o productor...", text: $searchText)
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
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    showSuggestions = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.tint.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
    
    private var filterBar: some View {
        HStack(spacing: 12) {
            filterButton(kind: nil, icon: "leaf.fill", color: .gray, label: "Todas")
            filterButton(kind: .safe, icon: "checkmark.circle.fill", color: .green, label: "Sanas")
            filterButton(kind: .risk, icon: "exclamationmark.circle.fill", color: .yellow, label: "Riesgo")
            filterButton(kind: .danger, icon: "xmark.octagon.fill", color: .red, label: "Afectadas")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(.regularMaterial))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
    }
    
    private func filterButton(kind: pinKind?, icon: String, color: Color, label: String) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedFilter = selectedFilter == kind ? nil : kind
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 22))
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .frame(width: 76)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedFilter == kind ? color.opacity(0.15) : .clear)
            )
        }
        .buttonStyle(.plain)
    }
    
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
                                selectedLocation = loc
                                activeSheet = .preview(loc)
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
                                    .foregroundStyle(colorForKind(loc.kind))
                                VStack(alignment: .leading) {
                                    Text(loc.name)
                                        .font(.headline)
                                    Text(loc.cityName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(.regularMaterial)
                        }
                        Divider()
                    }
                }
            }
        }
        .frame(maxHeight: 250)
        .background(.regularMaterial)
        .cornerRadius(14)
        .padding(.horizontal, 20)
        .padding(.top, 220)
        .shadow(radius: 5)
    }
    
    private func colorForKind(_ kind: pinKind) -> Color {
        switch kind {
        case .safe: return .green
        case .risk: return .yellow
        case .danger: return .red
        }
    }
    
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
            Image(systemName: mapStyle.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 50, height: 50)
                .background(Circle().fill(.regularMaterial))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
    }
    
    private var statisticsButton: some View {
        Button {
            activeSheet = .statistics
        } label: {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 50, height: 50)
                .background(Circle().fill(.regularMaterial))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
    }
}

// MARK: - Stat Badge
struct AdminStatBadge: View {
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text("\(count)")
                .font(.caption.bold())
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15), in: Capsule())
    }
}

#Preview {
    AdminLocationsView()
        .environmentObject(LocationsViewModel())
}
