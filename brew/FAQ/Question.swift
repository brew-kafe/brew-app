//
//  Question.swift
//  brew
//
//  Created by Regina Romero on 9/30/25.
//

import Foundation


struct Question: Codable, Identifiable {
    let id: Int
    let question: String
    let answer: String
    var isExpanded: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, question, answer
        // not including isExpanded → ignored during decoding
    }
}

