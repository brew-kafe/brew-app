//
//  LocationsListView.swift
//  brew
//
//  Created by AGRM on 10/09/25.
//

import SwiftUI

struct LocationsListView: View {
    
    @EnvironmentObject private var vm: LocationsViewModel
    
    @State private var searchText: String = ""
    @State private var selectedFilter: String = "Todos"
    
    // filters locations by search + filter
    private var filteredLocations: [Location] {
        vm.locations.filter { location in
            // Search condition
            let matchesSearch = searchText.isEmpty ||
                location.name.localizedCaseInsensitiveContains(searchText) ||
                location.cityName.localizedCaseInsensitiveContains(searchText)
            
            // Filter condition
            let matchesFilter = selectedFilter == "Todos" || location.status == selectedFilter
            
            return matchesSearch && matchesFilter
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Manual search bar cus the searcheable feature was giving me extra padding above i couldnt remove
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Buscar parcela", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            // Filters
            Picker("Filter", selection: $selectedFilter) {
                Text("Todos").tag("Todos")
                Text("Sano").tag("Sano")
                Text("Con roya").tag("Con roya")
                Text("En riesgo").tag("En riesgo")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            // List of results (filtered automatically)
            List {
                ForEach(filteredLocations) { location in
                    Button {
                        vm.showNextLocation(location: location)
                    } label: {
                        listRowView(location: location)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct LocationsListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsListView()
            .environmentObject(LocationsViewModel())
    }
}

extension LocationsListView {
    
    fileprivate func listRowView(location: Location) -> some View {
        HStack {
            if let imageName = location.imageNames.first {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            }
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.headline)
                Text(location.cityName)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

