//
//  LocationDetailView.swift
//  brew
//
//  Created by AGRM  on 11/09/25.
//

import SwiftUI

struct LocationDetailView: View {
    @EnvironmentObject private var vm: LocationsViewModel
    let location: Location

    // color segun el pin
    private var estadoColor: Color {
        switch location.kind {
        case .safe:   return .green
        case .risk:   return .yellow
        case .danger: return .red
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                imageSection
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)

                VStack(alignment: .leading, spacing: 16) {
                    titleSection
                    Divider()

                    // coordenadas + link opcional
                    HStack(spacing: 12) {
                        Circle().fill(estadoColor).frame(width: 10, height: 10)
                        Text(String(format: "Latitud: %.6f", location.coordinates.latitude))
                            .font(.caption).foregroundStyle(.secondary)
                        Text(String(format: "Longitud: %.6f", location.coordinates.longitude))
                            .font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        if let url = URL(string: location.link) {
                            Link("Más info", destination: url)
                                .font(.caption).foregroundStyle(.blue)
                        }
                    }

                    descriptionSection
                    Divider()
                    metricsSection
                    nutrientsSection
                    Divider()
                    reportsSection
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        .overlay(backButton, alignment: .topLeading)
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: LocationsDataService.locations.first!)
            .environmentObject(LocationsViewModel())
    }
}

// MARK: - Sections
extension LocationDetailView {

    private var imageSection: some View {
        TabView {
            ForEach(location.imageNames, id: \.self) { name in
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
        }
        .frame(height: 500)
        .tabViewStyle(.page)
        .frame(width: UIScreen.main.bounds.width)
        .clipped()
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.largeTitle).fontWeight(.semibold)
            Text(location.cityName)
                .font(.title3).foregroundStyle(.secondary)
        }
    }

    private var descriptionSection: some View {
        Text(location.description)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(headingForKind(location.kind))
                .font(.headline)

            HStack(alignment: .top, spacing: 16) {
        
                Group {
                    if UIImage(named: "plant") != nil {
                        Image("plant")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                    } else {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.green)
                    }
                }
                .padding(8)
                //.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                VStack(spacing: 10) {
                    iconProgressRow(
                        title: "Sol",
                        systemImage: "sun.max.fill",
                        value: location.metrics.sun,
                        tint: .yellow
                    )
                    iconProgressRow(
                        title: "Humedad",
                        systemImage: "drop.fill",
                        value: location.metrics.moisture,
                        tint: .blue
                    )
                    iconProgressRow(
                        title: "Severidad de plaga",
                        systemImage: "heart.fill",
                        value: location.metrics.pestSeverity,
                        tint: .red
                    )
                }
            }
        }
    }

    private var nutrientsSection: some View {
        Group {
            if location.metrics.potassium != nil || location.metrics.phosphorus != nil {
                HStack(spacing: 12) {
                    Text(location.metrics.potassium ?? "K: —")
                    Text(location.metrics.phosphorus ?? "P: —")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var reportsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reportes").font(.headline)

            HStack {
                Text("Reporte").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("Fecha").font(.caption).foregroundStyle(.secondary).frame(width: 100, alignment: .leading)
                Text("Encargado").font(.caption).foregroundStyle(.secondary).frame(width: 120, alignment: .leading)
                Text("Archivo").font(.caption).foregroundStyle(.secondary).frame(width: 60, alignment: .trailing)
            }

            ForEach(location.reports) { r in
                HStack {
                    Text(r.code)
                    Spacer()
                    Text(format(r.date)).frame(width: 100, alignment: .leading)
                    Text(r.manager).frame(width: 120, alignment: .leading)
                    if r.file != nil {
                        Image(systemName: "arrow.down.circle")
                            .foregroundStyle(.blue)
                            .frame(width: 60, alignment: .trailing)
                    } else {
                        Text("—").foregroundStyle(.secondary).frame(width: 60, alignment: .trailing)
                    }
                }
                .font(.subheadline)
            }
        }
    }

    private func iconProgressRow(title: String,
                                 systemImage: String,
                                 value: Int,
                                 tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .frame(width: 20, height: 20, alignment: .center)
                    .foregroundStyle(tint)

                Text(title)
                Spacer()
                Text("\(value)%")
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(value) / 100.0)
                .tint(tint)
                .scaleEffect(x: 1, y: 1.3, anchor: .center)
        }
        .font(.subheadline)
    }

    private func headingForKind(_ kind: pinKind) -> String {
        switch kind {
        case .safe:   return "Saludable"
        case .risk:   return "Riesgo"
        case .danger: return "Alerta"
        }
    }

    private func format(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: d)
    }

    private var backButton: some View {
        Button { vm.sheetLocation = nil } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(16)
                .foregroundColor(.primary)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 4)
                .padding()
        }
    }
}
