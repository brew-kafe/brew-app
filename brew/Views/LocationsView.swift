//
//  LocationsView.swift
//  brew
//
//  Created by AGRM  on 09/09/25.
//

import SwiftUI

class LocationsViewModel: ObservableObject{
    @Published var locations: [Location]
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
    }
    
}

struct LocationsView: View {
    
    @StateObject private var vm = LocationsViewModel()
    
    var body: some View {
        List{
            ForEach(vm.locations) {
                Text($0.name)
                
            }
        }
    }
}

#Preview {
    LocationsView()
}
