//
//  PersistentStorageProtocol.swift
//  Crypto
//
//  Created by Vishal Paliwal on 30/11/24.
//

import Foundation

protocol PersistentStorageProtocol {
    func saveCryptos(_ cryptos: [Crypto])
    func fetchAllCryptos() -> [Crypto]
    func fetchFilteredCryptos(isActive: Bool?, isNew: Bool?, type: String?) -> [Crypto]
    func clearAllCryptos()
}
