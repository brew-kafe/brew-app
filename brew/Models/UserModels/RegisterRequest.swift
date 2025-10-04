//
//  RegisterRequest.swift
//  LoginRegisterApp
//
//  Created by toño on 29/09/25.
//
import Foundation

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let role: String
    let cooperative_id: Int?
}
