//
//  LocationsView.swift
//  brew
//
//  Created by AGRM  on 09/09/25.
//

import SwiftUI

class LocationsViewModel: ObservableObject{
    
    
}

struct LocationsView: View {
    
    @StateObject private var vm = LocationsViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    LocationsView()
}
