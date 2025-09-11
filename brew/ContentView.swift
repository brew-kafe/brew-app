//
//  ContentView.swift
//  brew
//
//  Created by toño on 02/09/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {

            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(languageManager.localizedString("settings"))
                }
        }
    }

#Preview {
    ContentView()
}
