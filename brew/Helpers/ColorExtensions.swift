//
//  ColorExtensions.swift
//  brew
//
//  Created by AI Assistant on 04/10/25.
//

import SwiftUI
import UIKit

// MARK: - Color Extensions
extension Color {
    /// Creates a Color from a hex string
    /// - Parameter hex: Hex color string (with or without #, supports 6 or 8 characters)
    /// - Returns: Color instance, defaults to blue if invalid hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            // Default to blue for invalid hex
            self.init(.sRGB, red: 0, green: 0.478, blue: 1, opacity: 1)
            return
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Converts Color to hex string
    /// - Returns: Hex string representation (6 characters, no #)
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "007AFF" }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    /// Creates a UIColor from a hex string
    /// - Parameter hex: Hex color string (with or without #)
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(rgb & 0x0000FF) / 255,
                  alpha: 1)
    }
}