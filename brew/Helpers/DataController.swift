//
//  DataController.swift
//  LoginRegisterApp
//
//  Created by toño on 30/09/25.
//

import Foundation
import SwiftUI   
import SwiftData
import Combine

class DataController: ObservableObject {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: UserEntity.self, Activity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
