//
//  APILoginService.swift
//  brew
//
//  Created by toño on 01/10/25.
//

import Foundation

class APIService {
    private let baseURL = "https://brew-api-production.up.railway.app/api/users"
    
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",  // microseconds
                "yyyy-MM-dd'T'HH:mm:ss.SSS",     // milliseconds
                "yyyy-MM-dd'T'HH:mm:ss"          // seconds only
            ]
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateStr) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateStr)"
            )
        }
        
        return d
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<UserDTO, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else {
            completion(.failure(.invalidURL)); return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = LoginRequestDTO(email: email, password: password)
        req.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: req) { data, _, error in
            if error != nil { completion(.failure(.requestFailed)); return }
            guard let data = data else { completion(.failure(.unknown)); return }

            do {
                let loggedInUser = try self.decoder.decode(UserDTO.self, from: data)
                completion(.success(loggedInUser))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    // MARK: - Create
    func registerUser(_ request: RegisterRequest, completion: @escaping (Result<UserDTO, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else {
            completion(.failure(.invalidURL)); return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            req.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(.decodingFailed)); return
        }

        URLSession.shared.dataTask(with: req) { data, _, error in
            if error != nil { completion(.failure(.requestFailed)); return }
            guard let data = data else { completion(.failure(.unknown)); return }

            do {
                let newUser = try self.decoder.decode(UserDTO.self, from: data)
                completion(.success(newUser))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    

    // MARK: - Read
    func fetchUsers(completion: @escaping (Result<[UserDTO], APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/") else {
            completion(.failure(.invalidURL)); return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil { completion(.failure(.requestFailed)); return }
            guard let data = data else { completion(.failure(.unknown)); return }

            do {
                let users = try self.decoder.decode([UserDTO].self, from: data)
                completion(.success(users))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }

    // MARK: - Update
    func updateUser(id: UUID, update: UserUpdateRequest, completion: @escaping (Result<UserDTO, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            completion(.failure(.invalidURL)); return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(update)
        } catch {
            completion(.failure(.decodingFailed)); return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if error != nil { completion(.failure(.requestFailed)); return }
            guard let data = data else { completion(.failure(.unknown)); return }

            do {
                let updatedUser = try self.decoder.decode(UserDTO.self, from: data)
                completion(.success(updatedUser))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }

    // MARK: - Delete
    func deleteUser(id: UUID, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            completion(.failure(.invalidURL)); return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(.failure(.requestFailed)); return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(.unknown)); return
            }
            completion(.success(()))
        }.resume()
    }
}
