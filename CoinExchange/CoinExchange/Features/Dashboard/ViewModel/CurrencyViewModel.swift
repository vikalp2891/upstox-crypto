//
//  CurrencyViewModel.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import Foundation

class CurrencyViewModel: ObservableObject {
  
  private let networkManager: NetworkRequestable
  private let databaseManager: DatabaseManagerProtocol
  @Published var data: [Coins] = []
  @Published var filteredData: [Coins] = []
  @Published var error: Error?
  var filterOption = FilterOption()
  
  init(networkManager: NetworkRequestable = URLSession.shared, databaseManager: DatabaseManagerProtocol = DatabaseManager()) {
    self.networkManager = networkManager
    self.databaseManager = databaseManager
  }
  

  // Usage of `fetchData` with asynchronous network and database calls.
  func fetchData() async {
    do {
      let cryptoCoins = try await databaseManager.fetchCryptoCoins()
      if cryptoCoins.isEmpty {
        // Fetch data from network if the database is empty
        let url = URL(string: APIConstants.baseURL)!
        let result: [Coins] = try await networkManager.fetchData(for: url, httpMethod: .get)
        self.data = result
        // Save fetched coins to the database
        for coin in result {
          try await databaseManager.saveCryptoCoin(coin)
        }
      } else {
        self.data = cryptoCoins
      }
    } catch {
      self.error = error
    }
  }
  
  // Function to apply filters and append or remove results
  func applyFilters(option: FilterOption) {
    
    // Result variable to hold the current filtered data
    var result: [Coins] = filteredData
    
    // If isActive is specified, filter accordingly
    if let isActive = option.isActive, let type = option.type {
      if (type == "coin" || type == "token") && isActive {
        let filteredCoins = data.filter { $0.isActive == isActive && $0.type == type }
        result.append(contentsOf: filteredCoins)
      }
      if (type == "coin" || type == "token") && isActive == false {
        let filteredCoins = data.filter { $0.isActive == false && $0.type == type }
        result.append(contentsOf: filteredCoins)
      }
    }
    
    // If isNew is specified, filter accordingly
    else if let isNew = option.isNew {
      let new = data.filter { $0.isNew == isNew && $0.type == "coin" }
      result.append(contentsOf: new)
    }
    
    // If type is specified, filter accordingly
    else if let type = option.type {
      let coinType = data.filter { $0.type == type }
      result.append(contentsOf: coinType)
    }
    
    // Remove duplicates
    result = Array(Set(result))
    
    // Update the filtered items array
    filteredData = result
  }
  
  // Function to deselect a filter
  func deselectFilter(option: FilterOption) {
    
    // Result variable to hold the current filtered data
    var result: [Coins] = filteredData
    
    // If isActive is specified, filter accordingly
    if let isActive = option.isActive, let type = option.type {
      if (type == "coin" || type == "token") && isActive {
        result.removeAll{$0.isActive == isActive && $0.type == type}
      }
      if (type == "coin" || type == "token") && isActive == false {
        result.removeAll{$0.isActive == false && $0.type == type}
      }
    }
    
    // If isNew is specified, filter accordingly
    else if let isNew = option.isNew {
      result.removeAll{ $0.isNew == isNew && $0.type == "coin" }
    }
    
    // If type is specified, filter accordingly
    else if let type = option.type {
      result.removeAll{ $0.type == type }
    }
    
    // Remove duplicates
    result = Array(Set(result))
    
    // Update the filtered items array
    filteredData = result
  }
  
  func search(query: String) {
    filteredData = data.filter { item in
      item.name.lowercased().contains(query.lowercased()) || item.symbol.lowercased().contains(query.lowercased())
    }
  }
  
}