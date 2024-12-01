//
//  PersistentStorageService.swift
//  Crypto
//
//  Created by Vishal Paliwal on 30/11/24.
//

import Foundation
import CoreData

final class PersistentStorageService: PersistentStorageProtocol {
    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "CryptoModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Save Cryptos
    func saveCryptos(_ cryptos: [Crypto]) {
        // Clear existing records to avoid duplicates
        clearAllCryptos()

        for crypto in cryptos {
            let cryptoEntity = CryptoEntity(context: context)
            cryptoEntity.id = UUID()
            cryptoEntity.name = crypto.name
            cryptoEntity.symbol = crypto.symbol
            cryptoEntity.isNew = crypto.isNew
            cryptoEntity.isActive = crypto.isActive
            cryptoEntity.type = crypto.type
        }

        do {
            try context.save()
        } catch {
            print("Failed to save cryptos: \(error)")
        }
    }

    // MARK: - Fetch All Cryptos
    func fetchAllCryptos() -> [Crypto] {
        let fetchRequest: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        do {
            let cryptoEntities = try context.fetch(fetchRequest)
            return cryptoEntities.map {
                Crypto(name: $0.name ?? "",
                       symbol: $0.symbol ?? "",
                       isNew: $0.isNew,
                       isActive: $0.isActive,
                       type: $0.type ?? "")
            }
        } catch {
            print("Failed to fetch cryptos: \(error)")
            return []
        }
    }

    // MARK: - Fetch Filtered Cryptos
    func fetchFilteredCryptos(isActive: Bool? = nil, isNew: Bool? = nil, type: String? = nil) -> [Crypto] {
        let fetchRequest: NSFetchRequest<CryptoEntity> = CryptoEntity.fetchRequest()
        var predicates: [NSPredicate] = []

        if let isActive = isActive {
            predicates.append(NSPredicate(format: "isActive == %@", NSNumber(value: isActive)))
        }
        if let isNew = isNew {
            predicates.append(NSPredicate(format: "isNew == %@", NSNumber(value: isNew)))
        }
        if let type = type {
            predicates.append(NSPredicate(format: "type == %@", type))
        }

        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        do {
            let cryptoEntities = try context.fetch(fetchRequest)
            return cryptoEntities.map {
                Crypto(name: $0.name ?? "",
                       symbol: $0.symbol ?? "",
                       isNew: $0.isNew,
                       isActive: $0.isActive,
                       type: $0.type ?? "")
            }
        } catch {
            print("Failed to fetch filtered cryptos: \(error)")
            return []
        }
    }

    // MARK: - Delete All Cryptos
    func clearAllCryptos() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CryptoEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to clear cryptos: \(error)")
        }
    }
}

