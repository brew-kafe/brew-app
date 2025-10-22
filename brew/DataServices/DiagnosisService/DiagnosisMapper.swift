//
//  DiagnosisMapper.swift
//  brew
//
//  Created by toño on 21/10/25.
//

import Foundation

/// Maps between API models and local SwiftData models
struct DiagnosisMapper {
    
    // MARK: - API Response to Local Entity
    static func toEntity(from apiResponse: DiagnosisAPIResponse) -> DiagnosisEntity {
        let localElements = apiResponse.all_elements.map { apiElement in
            ElementAnalysis(
                element: apiElement.element,
                percentage: apiElement.percentage,
                detectionState: apiElement.detection_state,
                deficiencyLevel: apiElement.deficiency_level,
                recommendations: apiElement.recommendations
            )
        }
        
        return DiagnosisEntity(
            id: UUID(uuidString: apiResponse.diagnosis_id) ?? UUID(),
            parcelName: apiResponse.parcel_name,
            plantNumber: apiResponse.plant_number,
            technicianName: apiResponse.technician_name,
            primaryDeficiency: apiResponse.primary_deficiency,
            deficiencyElement: apiResponse.deficiency_element,
            detectionState: apiResponse.detection_state,
            aiConfidence: apiResponse.ai_confidence ?? 0.0,
            aiDescription: apiResponse.ai_description ?? "",
            aiRecommendations: apiResponse.ai_recommendations,
            allElements: localElements,
            photoURLs: apiResponse.photo_urls,
            diagnosisDate: apiResponse.diagnosis_date,
            createdAt: apiResponse.created_at
        )
    }
    
    // MARK: - Update Entity from API Response
    static func updateEntity(
        _ entity: DiagnosisEntity,
        from apiResponse: DiagnosisAPIResponse
    ) {
        entity.parcelName = apiResponse.parcel_name
        entity.plantNumber = apiResponse.plant_number
        entity.technicianName = apiResponse.technician_name
        entity.primaryDeficiency = apiResponse.primary_deficiency
        entity.deficiencyElement = apiResponse.deficiency_element
        entity.detectionState = apiResponse.detection_state
        entity.aiConfidence = apiResponse.ai_confidence ?? 0.0
        entity.aiDescription = apiResponse.ai_description ?? ""
        
        // Update computed properties using their setters
        let recommendations = apiResponse.ai_recommendations
        entity.aiRecommendations = recommendations
        
        // Update elements using setter
        let localElements = apiResponse.all_elements.map { apiElement in
            ElementAnalysis(
                element: apiElement.element,
                percentage: apiElement.percentage,
                detectionState: apiElement.detection_state,
                deficiencyLevel: apiElement.deficiency_level,
                recommendations: apiElement.recommendations
            )
        }
        entity.allElements = localElements
        
        // Update photo URLs using setter
        let urls = apiResponse.photo_urls
        entity.photoURLs = urls
        
        entity.diagnosisDate = apiResponse.diagnosis_date
        entity.createdAt = apiResponse.created_at
    }
    
    // MARK: - Photo Analysis Response to Create Request
    static func toCreateRequest(
        from photoAnalysis: PhotoAnalysisResponse,
        userId: String,
        parcelName: String,
        plantNumber: String?,
        technicianName: String
    ) -> DiagnosisCreateAPIRequest {
        return DiagnosisCreateAPIRequest(
            user_id: userId,
            parcel_name: parcelName,
            plant_number: plantNumber,
            technician_name: technicianName,
            primary_deficiency: photoAnalysis.primaryDeficiency ?? "Unknown",
            deficiency_element: photoAnalysis.deficiencyElement ?? "Unknown",
            detection_state: photoAnalysis.detectionState,
            ai_confidence: photoAnalysis.aiConfidence,
            ai_description: photoAnalysis.aiDescription,
            ai_recommendations: photoAnalysis.aiRecommendations,
            all_elements: photoAnalysis.allElements,
            photo_urls: photoAnalysis.photoUrl.map { [$0] } ?? [],
            notes: nil
        )
    }
    
    // MARK: - Local Entity to API Request
    static func toAPIRequest(from entity: DiagnosisEntity, userId: String) -> DiagnosisCreateAPIRequest {
        let apiElements = entity.allElements.map { localElement in
            ElementAnalysisAPI(
                element: localElement.element,
                percentage: localElement.percentage,
                detection_state: localElement.detectionState,
                deficiency_level: localElement.deficiencyLevel,
                recommendations: localElement.recommendations
            )
        }
        
        return DiagnosisCreateAPIRequest(
            user_id: userId,
            parcel_name: entity.parcelName,
            plant_number: entity.plantNumber,
            technician_name: entity.technicianName,
            primary_deficiency: entity.primaryDeficiency,
            deficiency_element: entity.deficiencyElement,
            detection_state: entity.detectionState,
            ai_confidence: entity.aiConfidence,
            ai_description: entity.aiDescription,
            ai_recommendations: entity.aiRecommendations,
            all_elements: apiElements,
            photo_urls: entity.photoURLs,
            notes: nil
        )
    }
}
