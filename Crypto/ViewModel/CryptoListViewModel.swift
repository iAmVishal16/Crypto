//
//  CryptoListViewModel.swift
//  Crypto
//
//  Created by Vishal Paliwal on 26/11/24.
//

import Foundation
import Combine

class CryptoListViewModel {
    private var networkService = NetworkService.shared
    private var allCryptos: [Crypto] = []
    private var bags = Set<AnyCancellable>()
    
    private(set) var isLoading = false
    
    var isFilterActive = false
    var filteredCryptos: [Crypto] = []
    var onDataUpdate: (() -> Void)?

    // Fetch data from the API
    func fetchCryptoList(_ isLoadMore: Bool = false) {
        self.isLoading = true
        
        networkService.getCryptoCoins().sink { error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            print(error)
                
        } receiveValue: { coins in
            print(coins.count)
                        
            DispatchQueue.main.async {
                self.isLoading = false
                if isLoadMore {
                    // TODO: will implement load more data here
                } else {
                    self.allCryptos = coins
                    self.filteredCryptos = self.allCryptos
                    DispatchQueue.main.async {
                        self.onDataUpdate?()
                    }
                }
                
            }
        }
        .store(in: &bags)
    }
    
    func applyFilters(isActive: Bool?, isInActive: Bool?, type: String?, isNew: Bool?) {
        
        var activeCrypto: [Crypto] = []
        if isActive ?? false {
            activeCrypto = allCryptos.filter { crypto in
                let matchesActive = isActive == nil || crypto.isActive == isActive
                let matchesType = type == nil || crypto.type == type
                let matchesNew = isNew == nil || crypto.isNew == isNew
                return matchesActive
            }
        }
        
        var inactiveCrypto: [Crypto] = []
        if isInActive ?? false {
            inactiveCrypto = allCryptos.filter { crypto in
                let matchesInActive = isInActive == nil || crypto.isActive == !(isInActive ?? false)
                return matchesInActive
            }
        }
        
        var typeCrypto:[Crypto] = []
        if let _ = type {
            typeCrypto = allCryptos.filter { crypto in
                let matchesType = type == nil || crypto.type == type
                return matchesType
            }
        }
        
        var newCrypto: [Crypto] = []
        if isNew ?? false {
            newCrypto = allCryptos.filter { crypto in
                let matchesNew = isNew == nil || crypto.isNew == isNew
                return matchesNew
            }
        }
        
        let combinedCrypto = activeCrypto + inactiveCrypto + typeCrypto + newCrypto
        
        if combinedCrypto.count > 0 {
            filteredCryptos = combinedCrypto
        } else {
            filteredCryptos = allCryptos
        }
        
        
        onDataUpdate?()
    }
    
    func search(query: String) {
        if query.isEmpty {
            if isFilterActive {
//                do not do anything
            } else {
                filteredCryptos = allCryptos
            }
        } else {
            filteredCryptos = filteredCryptos.filter { crypto in
                crypto.name.lowercased().contains(query.lowercased()) ||
                crypto.symbol.lowercased().contains(query.lowercased())
            }
        }
        onDataUpdate?()
    }
}
