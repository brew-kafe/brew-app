//
//  ContentView.swift
//  brew
//
//  Created by toño on 02/09/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text(":)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
