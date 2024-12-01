//
//  Constants.swift
//  Crypto
//
//  Created by Vishal Paliwal on 30/11/24.
//

import Foundation

struct API {
    static let domain = "https://37656be98b8f42ae8348e4da3ee3193f."
    static let endpoint = ""
    static let key = ""
    
    private struct Routes {
        static let cryptoCoinsAPI = "api.mockbin.io"
    }
    
    // https://37656be98b8f42ae8348e4da3ee3193f.api.mockbin.io
    static let coinsRequestURL =  domain + Routes.cryptoCoinsAPI
}

struct Constants {
    
    struct AppDefaults {

    }
    
    enum CryptoType: String {
        case coin = "coin"
        case token = "token"
    }
}
