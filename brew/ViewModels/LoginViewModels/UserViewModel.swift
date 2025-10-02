//
//  UserViewModel.swift
//  LoginRegisterApp
//
//  Created by toño on 26/09/25.
//

import SwiftUI
import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var users: [UserDTO] = []
    @Published var errorMessage: String?

    private let api = APIService()

    // MARK: - Fetch All Users
    func fetchUsers() {
        api.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Add User
    func addUser(_ request: RegisterRequest) {
        api.registerUser(request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newUser):
                    self?.users.append(newUser)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Delete User
    func deleteUser(at offsets: IndexSet) {
        for index in offsets {
            let user = users[index]
            deleteUser(user) // call the API-based deletion
        }
    }

    // Keep the delete by UserDTO for API calls
    func deleteUser(_ user: UserDTO) {
        guard let id = user.id else { return }
        api.deleteUser(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.users.removeAll { $0.id == id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Update User
    func updateUser(id: UUID, update: UserUpdateRequest) {
        api.updateUser(id: id, update: update) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedUser):
                    if let index = self?.users.firstIndex(where: { $0.user_id == updatedUser.user_id }) {
                        self?.users[index] = updatedUser
                    }
                case .failure(let error):
                    print("Update failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
