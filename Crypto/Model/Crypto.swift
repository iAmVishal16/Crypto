//
//  Crypto.swift
//  Crypto
//
//  Created by Vishal Paliwal on 26/11/24.
//

struct Crypto: Codable {
    let name: String
    let symbol: String
    let isNew: Bool
    let isActive: Bool
    let type: String

    enum CodingKeys: String, CodingKey {
        case name
        case symbol
        case isNew = "is_new"
        case isActive = "is_active"
        case type
    }
}
