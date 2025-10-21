//
//  APIDiagnosisService.swift
//  brew
//
//  Created by toño on 20/10/25.
//

import Foundation

enum DiagnosisAPIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case httpError(Int)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Error de decodificación: \(error.localizedDescription)"
        case .httpError(let code):
            return "Error HTTP: \(code)"
        case .unknown:
            return "Error desconocido"
        }
    }
}

// MARK: - API Request Models
struct DiagnosisCreateRequest: Codable {3
    let userId: String
    let parcelName: String
    let plantNumber: String?
    let technicianName: String
    let primaryDeficiency: String
    let deficiencyElement: String
    let detectionState: String
    let aiConfidence: Double?
    let aiDescription: String?
    let aiRecommendations: [String]
    let allElements: [ElementAnalysisAPI]
    let photoUrls: [String]
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case parcelName = "parcel_name"
        case plantNumber = "plant_number"
        case technicianName = "technician_name"
        case primaryDeficiency = "primary_deficiency"
        case deficiencyElement = "deficiency_element"
        case detectionState = "detection_state"
        case aiConfidence = "ai_confidence"
        case aiDescription = "ai_description"
        case aiRecommendations = "ai_recommendations"
        case allElements = "all_elements"
        case photoUrls = "photo_urls"
        case notes
    }
}

struct ElementAnalysisAPI: Codable {
    let element: String
    let percentage: Double
    let detectionState: String
    let deficiencyLevel: String?
    let recommendations: [String]
    
    enum CodingKeys: String, CodingKey {
        case element, percentage
        case detectionState = "detection_state"
        case deficiencyLevel = "deficiency_level"
        case recommendations
    }
}

// MARK: - API Response Models
struct DiagnosisAPIResponse: Codable {
    let diagnosisId: String
    let userId: String
    let parcelName: String
    let plantNumber: String?
    let technicianName: String
    let primaryDeficiency: String
    let deficiencyElement: String
    let detectionState: String
    let aiConfidence: Double?
    let aiDescription: String?
    let aiRecommendations: [String]
    let allElements: [ElementAnalysisAPI]
    let photoUrls: [String]
    let diagnosisDate: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case diagnosisId = "diagnosis_id"
        case userId = "user_id"
        case parcelName = "parcel_name"
        case plantNumber = "plant_number"
        case technicianName = "technician_name"
        case primaryDeficiency = "primary_deficiency"
        case deficiencyElement = "deficiency_element"
        case detectionState = "detection_state"
        case aiConfidence = "ai_confidence"
        case aiDescription = "ai_description"
        case aiRecommendations = "ai_recommendations"
        case allElements = "all_elements"
        case photoUrls = "photo_urls"
        case diagnosisDate = "diagnosis_date"
        case createdAt = "created_at"
    }
}

struct DiagnosisListResponse: Codable {
    let diagnoses: [DiagnosisAPIResponse]
    let total: Int
    let page: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case diagnoses, total, page
        case pageSize = "page_size"
    }
}

// MARK: - API Service
class APIDiagnosisService {
    static let shared = APIDiagnosisService()
    
    private let baseURL = "https://brew-api-production.up.railway.app/api/diagnoses"
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
    
    private var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
    
    private init() {}
    
    // MARK: - Create Diagnosis
    func createDiagnosis(
        _ diagnosis: DiagnosisEntity,
        userId: String,
        completion: @escaping (Result<DiagnosisAPIResponse, DiagnosisAPIError>) -> Void
    ) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Convert DiagnosisEntity to API request
        let elements = diagnosis.allElements.map { elem in
            ElementAnalysisAPI(
                element: elem.element,
                percentage: elem.percentage,
                detectionState: elem.detectionState.rawValue,
                deficiencyLevel: elem.deficiencyLevel,
                recommendations: elem.recommendations
            )
        }
        
        let request = DiagnosisCreateRequest(
            userId: userId,
            parcelName: diagnosis.parcelName,
            plantNumber: diagnosis.plantNumber,
            technicianName: diagnosis.technicianName,
            primaryDeficiency: diagnosis.primaryDeficiency,
            deficiencyElement: diagnosis.deficiencyElement,
            detectionState: diagnosis.detectionState,
            aiConfidence: diagnosis.aiConfidence,
            aiDescription: diagnosis.aiDescription,
            aiRecommendations: diagnosis.aiRecommendations,
            allElements: elements,
            photoUrls: diagnosis.photoURLs,
            notes: nil
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            completion(.failure(.decodingError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let response = try self?.decoder.decode(DiagnosisAPIResponse.self, from: data)
                if let response = response {
                    completion(.success(response))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Get User Diagnoses
    func getUserDiagnoses(
        userId: String,
        completion: @escaping (Result<[DiagnosisAPIResponse], DiagnosisAPIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let diagnoses = try self?.decoder.decode([DiagnosisAPIResponse].self, from: data)
                if let diagnoses = diagnoses {
                    completion(.success(diagnoses))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Get Single Diagnosis
    func getDiagnosis(
        diagnosisId: String,
        completion: @escaping (Result<DiagnosisAPIResponse, DiagnosisAPIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(diagnosisId)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let diagnosis = try self?.decoder.decode(DiagnosisAPIResponse.self, from: data)
                if let diagnosis = diagnosis {
                    completion(.success(diagnosis))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Delete Diagnosis
    func deleteDiagnosis(
        diagnosisId: String,
        completion: @escaping (Result<Void, DiagnosisAPIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(diagnosisId)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknown))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}
