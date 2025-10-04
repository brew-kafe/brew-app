//
//  UserEntity.swift
//  LoginRegisterApp
//
//  Created by toño on 29/09/25.
//

import SwiftData
import Foundation

@Model
final class UserEntity {
    @Attribute(.unique) var serverID: UUID?
    var name: String
    var email: String
    var role: String
    var cooperativeID: Int?
    var dateJoined: Date
    var status: String

    init(serverID: UUID? = nil,
         name: String,
         email: String,
         role: String = "user",
         cooperativeID: Int? = nil,
         dateJoined: Date = .now,
         status: String = "active") {
        self.serverID = serverID
        self.name = name
        self.email = email
        self.role = role
        self.cooperativeID = cooperativeID
        self.dateJoined = dateJoined
        self.status = status
    }
}
