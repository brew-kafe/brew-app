//
//  UserDTO.swift
//  LoginRegisterApp
//
//  Created by toño on 29/09/25.
//

import Foundation

nonisolated struct UserDTO: Codable, Identifiable {
    
    let user_id: UUID?
    let name: String
    let email: String
    let role: String
    let status: String
    let date_joined: Date
    let cooperative_id: Int?

    
    var id: UUID? { user_id }
}
