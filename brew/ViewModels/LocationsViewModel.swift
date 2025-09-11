//
//  LocationsViewModel.swift
//  brew
//
//  Created by AGRM  on 10/09/25.
//

import Foundation
import MapKit
import SwiftUI

class LocationsViewModel: ObservableObject{
    
    //all loaded locations
    @Published var locations: [Location]
    
    //current location on map
    @Published var mapLocation: Location {
        didSet{
            updateMapRegion(location: mapLocation)
        }
    }
    
    //current region on map
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) //el zoom q le das
    
    //Show list of locations
    @Published var showLocationsList: Bool = false
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first! //! unwrapping cus the data is hardcoded, but if we were to get this from the internet and we dont actually know hoew many elements they are and if theres even a first location we should not put the !
        self.updateMapRegion(location: locations.first!)
    }
    
    private func updateMapRegion(location: Location) {
        withAnimation(.easeInOut){
            mapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: mapSpan)
        }
    }
    
    func toggleLocationsList(){
        withAnimation(.easeInOut){
            showLocationsList = !showLocationsList
            
        }
    }
    
    func showNextLocation(location: Location){
        withAnimation(.easeInOut){
            mapLocation = location //update map 
            showLocationsList = false //close list
        }
    }
    
    func nextButtonPressed(){
        //getting the current index of the array of locations
        // $0 means first location
        // guard lets us unwrap
        guard let currentIndex = locations.firstIndex(where: {$0 == mapLocation}) else{
            print("No fue posible encontrar el sig indice en el arreglo de ubicaciones!! pero esto no deberia de pasar, hay algo maaal :/")
            return
            
        }
        
        //check if the current index is valid cus we dont want it to be outta bounds
        let nextIndex = currentIndex + 1
        guard locations.indices.contains(nextIndex) else{
            //if next index is not a valid one we restart at index 0
            guard let firstLocation = locations.first else { return}
            showNextLocation(location: firstLocation)
            return
        }
        //if the location does contain the index
        // next index is valid
        let nextLocation = locations[nextIndex] //if we didnt have the guard statement in locations.indices this line would be pretty dangerous cus it could crash our app cus we would be accessing an index we think is there but it might not be, its okay here tho cus we know forsure theres a next location
        showNextLocation(location: nextLocation)
    }
    
    
    
    
}
