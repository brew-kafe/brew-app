//
//  LocationMapAnnotationView.swift
//  brew
//
//  Created by AGRM  on 10/09/25.
//

import SwiftUI

struct LocationMapSafeAnnotationView: View {
    // for safe icon: checkmark.circle.fill
    // for risk : asterisk.circle.fill
    
    let safeColor = Color("Safe")
    var body: some View {
        VStack(spacing:0){
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.white)
                .padding(8)
                .background(safeColor)
                .clipShape(Circle())
            

            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(safeColor)
                .frame(width:12, height:12)
                .rotationEffect(Angle(degrees:180))
                .offset(y:-3)
                .padding(.bottom, 40)
        }
    }
}


struct LocationMapSafeAnnotationView_Previews: PreviewProvider{
    static var previews: some View{
        ZStack {
            Color.black.ignoresSafeArea()
            LocationMapSafeAnnotationView()
        }
    }
}

