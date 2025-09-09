//
//  OnboardingView.swift
//  brew
//
//  Created by AGRM  on 08/09/25.
//

import SwiftUI

enum OnbordingPage: Int, CaseIterable{
    case browsingMenu
    case quickDelivery
    case orderTracking
}

struct OnboardingView: View {
    
    @State private var currentPage = 0
    @State private var isAnimating = false
    @State private var deliveryOffset = false
    @State private var trackingProgress: CGFloat = 0.0
    
    
    var body: some View {
        VStack{
            TabView(selection: $currentPage){
                ForEach(OnbordingPage.allCases, id:)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
