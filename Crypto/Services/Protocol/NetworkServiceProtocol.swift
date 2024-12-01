//
//  NetworkServiceProtocol.swift
//  Crypto
//
//  Created by Vishal Paliwal on 26/11/24.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func getCryptoCoins() -> Future<[Crypto], Error>
}
