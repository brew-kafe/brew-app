//
//  TsotsilMLXTranslator.swift
//  brew
//
//  MLX-based Tsotsil translator for iOS
//  Created by Humbe on 15/10/25.
//

import Foundation
import Combine

/// MLX-based translator for Tsotsil language support
class TsotsilMLXTranslator: ObservableObject {
    static let shared = TsotsilMLXTranslator()
    
    @Published var isModelLoaded = false
    @Published var isTranslating = false
    @Published var lastError: String?
    
    private var translationCache: [String: String] = [:]
    private let maxCacheSize = 100
    
    // Tsotsil dataset for fallback translation
    private var tsotsilDataset: [[String: String]] = []
    
    private init() {
        loadTsotsilDataset()
        // In production, initialize MLX model here
        // For now, we'll use the dataset for translation
    }
    
    // MARK: - Dataset Loading
    
    private func loadTsotsilDataset() {
        guard let url = Bundle.main.url(forResource: "Tsotsil_Dataset", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dataset = try? JSONDecoder().decode([[String: String]].self, from: data) else {
            print("Failed to load Tsotsil dataset")
            return
        }
        
        self.tsotsilDataset = dataset
        self.isModelLoaded = true
        print("✅ Tsotsil dataset loaded: \(dataset.count) entries")
    }
    
    // MARK: - Translation Methods
    
    /// Translate text from Spanish to Tsotsil
    func translateToTsotsil(_ text: String) async -> String {
        isTranslating = true
        defer { isTranslating = false }
        
        // Check cache first
        if let cached = translationCache[text] {
            return cached
        }
        
        // In production: Use MLX model for translation
        // For now: Use dataset-based translation
        let translation = await datasetBasedTranslation(text, from: "spanish", to: "tsotsil")
        
        // Cache result
        cacheTranslation(original: text, translated: translation)
        
        return translation
    }
    
    /// Translate text from Tsotsil to Spanish
    func translateFromTsotsil(_ text: String) async -> String {
        isTranslating = true
        defer { isTranslating = false }
        
        // Check cache
        if let cached = translationCache[text] {
            return cached
        }
        
        let translation = await datasetBasedTranslation(text, from: "tsotsil", to: "spanish")
        
        // Cache result
        cacheTranslation(original: text, translated: translation)
        
        return translation
    }
    
    /// Detect if text is in Tsotsil language
    func detectTsotsil(_ text: String) -> Bool {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if any word in the text matches Tsotsil words
        let words = cleanText.components(separatedBy: .whitespaces)
        
        for word in words {
            if tsotsilDataset.contains(where: { $0["tsotsil"]?.lowercased().contains(word) ?? false }) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Private Helpers
    
    private func datasetBasedTranslation(_ text: String, from sourceLanguage: String, to targetLanguage: String) async -> String {
        let cleanText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try exact match first
        if let match = tsotsilDataset.first(where: { 
            $0[sourceLanguage]?.lowercased() == cleanText 
        }) {
            return match[targetLanguage] ?? text
        }
        
        // Try word-by-word translation for phrases
        let words = text.components(separatedBy: .whitespaces)
        var translatedWords: [String] = []
        
        for word in words {
            let cleanWord = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
            
            if let match = tsotsilDataset.first(where: {
                $0[sourceLanguage]?.lowercased() == cleanWord
            }) {
                translatedWords.append(match[targetLanguage] ?? word)
            } else {
                translatedWords.append(word)
            }
        }
        
        let result = translatedWords.joined(separator: " ")
        return result != text ? result : text
    }
    
    private func cacheTranslation(original: String, translated: String) {
        if translationCache.count >= maxCacheSize {
            // Remove oldest entry
            if let firstKey = translationCache.keys.first {
                translationCache.removeValue(forKey: firstKey)
            }
        }
        translationCache[original] = translated
    }
    
    // MARK: - MLX Model Integration (Future Implementation)
    
    /// Initialize MLX model for on-device translation
    /// This should be implemented when integrating actual MLX Swift library
    private func initializeMLXModel() {
        // TODO: Initialize MLX model
        // Example structure:
        // 1. Load model weights from bundle
        // 2. Initialize MLX Swift wrapper
        // 3. Set up inference pipeline
        // 4. Validate model performance
    }
    
    /// Run MLX inference for translation
    private func runMLXInference(_ text: String, direction: TranslationDirection) async throws -> String {
        // TODO: Implement MLX inference
        // This will replace the dataset-based translation
        throw NSError(domain: "MLX not implemented", code: -1)
    }
}

enum TranslationDirection {
    case spanishToTsotsil
    case tsotsilToSpanish
}

// MARK: - MLX Configuration

struct MLXModelConfig {
    let modelName: String
    let tokenizerPath: String
    let maxSequenceLength: Int
    let batchSize: Int
    
    static let `default` = MLXModelConfig(
        modelName: "tsotsil_translator_v1",
        tokenizerPath: "tokenizer",
        maxSequenceLength: 512,
        batchSize: 1
    )
}
