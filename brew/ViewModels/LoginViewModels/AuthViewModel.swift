//
//  AuthViewModel.swift
//  LoginRegisterApp
//
//  Created by toño on 26/09/25.
//

import Foundation
import Combine


class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var currentUser: UserDTO?
    @Published var errorMessage: String?

    private let api = APIService()

    func register(name: String, email: String, password: String, role: String, cooperativeID: Int?) {
        let newUser = RegisterRequest(
            name: name,
            email: email,
            password: password,
            role: role,
            cooperative_id: cooperativeID
        )

        api.registerUser(newUser) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                }
            }
        }
    }

    func login(email: String, password: String) {
        api.loginUser(email: email, password: password) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                }
            }
        }
    }
}
