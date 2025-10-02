//
//  UserUpdateRequest.swift
//  LoginRegisterApp
//
//  Created by toño on 29/09/25.
//

import Foundation

struct UserUpdateRequest: Codable {
    var name: String?
    var email: String?
    var role: String?
    var status: String?
    var password: String?
    var cooperative_id: Int?
}
