//
//  APIError.swift
//  LoginRegisterApp
//
//  Created by toño on 26/09/25.
//

import Foundation

enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API URL is invalid."
        case .requestFailed: return "The request failed."
        case .decodingFailed: return "Failed to decode the response."
        case .serverError(let msg): return "Server error: \(msg)"
        case .unknown: return "An unknown error occurred."
        }
    }
}
