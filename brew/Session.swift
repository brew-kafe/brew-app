//
//  Session.swift
//  brew
//
//  Created by Monserrath Valenzuela on 21/10/25.
//

import SwiftUI

enum UserRole: String, Codable {
    case admin
    case technician
}

@MainActor
final class Session: ObservableObject {
    @Published var role: UserRole = .technician
    @Published var selectedTab: String = "home"
}
