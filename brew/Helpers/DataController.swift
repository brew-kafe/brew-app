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
        // First, try to clean up any problematic database files
        DataController.deleteOldDatabase()
        
        do {
            // Use a custom configuration with a specific database name
            let config = ModelConfiguration("BrewAppDatabase")
            
            if #available(iOS 18.1, macOS 15.1, *) {
                container = try ModelContainer(for: UserEntity.self, Activity.self, AIDiagnosisEntity.self, DiagnosisEntity.self, ReportEntity.self, configurations: config)
            } else {
                container = try ModelContainer(for: UserEntity.self, Activity.self, DiagnosisEntity.self, ReportEntity.self, configurations: config)
            }
        } catch {
            print("Failed to create ModelContainer with custom config: \(error)")
            
            // If that fails, try with in-memory storage as a fallback
            do {
                let inMemoryConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                if #available(iOS 18.1, macOS 15.1, *) {
                    container = try ModelContainer(for: UserEntity.self, Activity.self, AIDiagnosisEntity.self, DiagnosisEntity.self, ReportEntity.self, configurations: inMemoryConfig)
                } else {
                    container = try ModelContainer(for: UserEntity.self, Activity.self, DiagnosisEntity.self, ReportEntity.self, configurations: inMemoryConfig)
                }
                print("Using in-memory storage as fallback")
            } catch {
                fatalError("Failed to create ModelContainer even with in-memory storage: \(error)")
            }
        }
    }
    
    private static func deleteOldDatabase() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        guard let applicationSupportURL = urls.first else { return }
        
        // List of potential problematic database files
        let filesToDelete = [
            "default.store",
            "default.store-shm", 
            "default.store-wal",
            "Model.sqlite",
            "Model.sqlite-shm",
            "Model.sqlite-wal"
        ]
        
        for fileName in filesToDelete {
            let fileURL = applicationSupportURL.appendingPathComponent(fileName)
            do {
                if fileManager.fileExists(atPath: fileURL.path) {
                    try fileManager.removeItem(at: fileURL)
                    print("Deleted old database file: \(fileName)")
                }
            } catch {
                print("Error deleting \(fileName): \(error)")
            }
        }
        
        // Also try to delete the entire Application Support directory contents
        do {
            let contents = try fileManager.contentsOfDirectory(at: applicationSupportURL, includingPropertiesForKeys: nil)
            for item in contents {
                if item.pathExtension == "sqlite" || item.pathExtension == "store" || 
                   item.lastPathComponent.contains("sqlite") || item.lastPathComponent.contains("store") {
                    try fileManager.removeItem(at: item)
                    print("Deleted database file: \(item.lastPathComponent)")
                }
            }
        } catch {
            print("Error cleaning up database files: \(error)")
        }
    }
}
