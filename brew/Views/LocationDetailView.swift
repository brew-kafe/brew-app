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
    var body: some View {
        ScrollView{
            VStack{
                imageSection
                    .shadow(color:Color.black.opacity(0.3), radius: 20, x:0, y:10)
                VStack(alignment:.leading, spacing:16){
                    titleSection
                    Divider()
                    descriptionSection
                  
                }
                .frame(maxWidth:.infinity, alignment: .leading)
                .padding()
              
            }
        }
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
        .overlay(backButton, alignment: .topLeading)
    }
}


struct LocationDetailView_Previews: PreviewProvider{
    static var previews: some View{
        LocationDetailView(location: LocationsDataService.locations.first!) //exclamation mark issokay here since we know theres at least one item in the array
    }
}

extension LocationDetailView{
    private var imageSection: some View {
        TabView {
            ForEach(location.imageNames, id: \.self) {
                Image($0)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(height:500)
        .tabViewStyle(PageTabViewStyle())
        .frame(width: UIScreen.main.bounds.width) //we gotta fix this for ipad but for phone isokay as is
        .clipped()
    }
    private var titleSection: some View{
        VStack(alignment:.leading, spacing:8){
            Text(location.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text(location.cityName)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    private var descriptionSection: some View{
        VStack(alignment:.leading, spacing:8){
            Text(location.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var backButton: some View{
        Button{
            vm.sheetLocation = nil
        }label: {
            Image(systemName:"xmark")
                .font(.headline)
                .padding(16)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius:4)
                .padding()
            
        }
    }
}

