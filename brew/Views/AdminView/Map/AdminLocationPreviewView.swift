//
//  AdminLocationPreviewView.swift
//  brew
//
//  Created for Admin Dashboard
//

import SwiftUI
import MapKit

struct AdminLocationPreviewView: View {
    @EnvironmentObject private var vm: LocationsViewModel
    let location: Location
    let onDismiss: () -> Void
    let onOpenDetail: () -> Void
    let onNext: (Location) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(.secondary.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            // HEADER
            HStack(spacing: 14) {
                if let imageName = location.imageNames.first {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(location.name)
                            .font(.title3).bold()
                        
                        statusBadge
                    }
                    
                    Text(location.cityName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Quick metrics
                    HStack(spacing: 12) {
                        MetricPill(icon: "drop.fill", value: "\(location.metrics.moisture)%", color: .blue)
                        MetricPill(icon: "sun.max.fill", value: "\(location.metrics.sun)%", color: .orange)
                        MetricPill(icon: "exclamationmark.triangle.fill", value: "\(location.metrics.pestSeverity)%", color: location.metrics.pestSeverity > 50 ? .red : .yellow)
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            // BUTTONS
            HStack(spacing: 12) {
                detailButton
                nextButton
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
    
    private var statusBadge: some View {
        let (color, icon) = statusInfo
        return HStack(spacing: 4) {
            Image(systemName: icon)
            Text(location.status)
        }
        .font(.caption2.bold())
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.15), in: Capsule())
    }
    
    private var statusInfo: (Color, String) {
        switch location.kind {
        case .safe: return (.green, "checkmark.circle.fill")
        case .risk: return (.yellow, "exclamationmark.triangle.fill")
        case .danger: return (.red, "xmark.octagon.fill")
        }
    }
    
    private var detailButton: some View {
        Button {
            withAnimation(.easeInOut) {
                onOpenDetail()
            }
        } label: {
            Label("Ver detalles", systemImage: "doc.text.magnifyingglass")
                .frame(maxWidth: .infinity)
                .frame(height: 45)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var nextButton: some View {
        Button {
            guard let currentIndex = vm.locations.firstIndex(where: { $0.id == location.id }) else { return }
            let nextIndex = (currentIndex + 1) % vm.locations.count
            let nextLocation = vm.locations[nextIndex]
            
            withAnimation(.spring) {
                vm.mapLocation = nextLocation
                onNext(nextLocation)
            }
        } label: {
            Label("Siguiente", systemImage: "arrow.right.circle.fill")
                .frame(maxWidth: .infinity)
                .frame(height: 45)
        }
        .buttonStyle(.bordered)
    }
}

struct MetricPill: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption2.bold())
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.12), in: Capsule())
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        AdminLocationPreviewView(
            location: LocationsDataService.locations.first!,
            onDismiss: {},
            onOpenDetail: {},
            onNext: { _ in }
        )
        .environmentObject(LocationsViewModel())
    }
}
