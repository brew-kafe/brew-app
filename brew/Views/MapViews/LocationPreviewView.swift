//
//  LocationPreviewView.swift
//  brew
//
//  Created by AGRM on 10/09/25.
//

import SwiftUI
import MapKit

struct LocationPreviewView: View {
    @EnvironmentObject private var vm: LocationsViewModel
    let location: Location
    let onDismiss: () -> Void
    let onOpenDetail: () -> Void
    
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.title3).bold()
                    Text(location.cityName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                conocerButton
                nextButton
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
    
    private var conocerButton: some View {
        Button {
            withAnimation(.easeInOut) {
                onOpenDetail()
            }
        } label: {
            Label("Conocer", systemImage: "info.circle")
                .frame(maxWidth: .infinity)
                .frame(height: 45)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var nextButton: some View {
        Button {
            withAnimation(.spring) {
                vm.nextButtonPressed()
                onDismiss()
            }
        } label: {
            Label("Siguiente", systemImage: "arrow.right.circle.fill")
                .frame(maxWidth: .infinity)
                .frame(height: 45)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        LocationPreviewView(
            location: LocationsDataService.locations.first!,
            onDismiss: {},
            onOpenDetail: {}
        )
        .environmentObject(LocationsViewModel())
    }
}
