//
//  DatabaseManager.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import CoreData
import Foundation

protocol DatabaseManagerProtocol {
  func saveContext(context: NSManagedObjectContext) throws
  func saveCryptoCoin(_ coin: Coins) async throws
  func fetchCryptoCoins() async throws -> [Coins]
}

class DatabaseManager: @preconcurrency DatabaseManagerProtocol {
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoinExchange")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  func saveContext(context: NSManagedObjectContext) throws {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        throw error
      }
    }
  }
  
  @MainActor
  func saveCryptoCoin(_ coinData: Coins) async throws {
    let managedContext = persistentContainer.viewContext
    let coin = Coin(context: managedContext)
    coin.name = coinData.name
    coin.symbol = coinData.symbol
    coin.type = coinData.type
    coin.isActive = coinData.isActive
    coin.isNew = coinData.isNew
    
    try saveContext(context: managedContext)
  }
  
  @MainActor
  func fetchCryptoCoins() async throws -> [Coins] {
    let managedContext = persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Coin> = Coin.fetchRequest()
    
    let coinEntities = try managedContext.fetch(fetchRequest)
    return coinEntities.map { coin in
      Coins(name: coin.name ?? "",
            symbol: coin.symbol ?? "",
            type: coin.type ?? "",
            isActive: coin.isActive,
            isNew: coin.isNew)
    }
  }
}
