//
//  CoinExchangeTests.swift
//  CoinExchangeTests
//
//  Created by Vikalp on 10/11/24.
//

import XCTest
import CoreData
@testable import CoinExchange

class CurrencyViewModelTests: XCTestCase {
  // Mocking NetworkRequestable
  class MockNetworkManager: NetworkRequestable {
    var shouldReturnError = false
    func fetchData<T>(for url: URL, httpMethod: CoinExchange.HttpMethod) async throws -> T where T : Decodable {
      if shouldReturnError {
        throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network Error"])
      }
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return try! decoder.decode(T.self, from: Data("""
                [{
            "name" : "Bitcoin",
            "symbol": "BTC",
            "is_new": false,
            "is_active": true,
            "type": "coin"
            }]
            """.utf8))
    }
    }

  
  // Mocking DatabaseManagerProtocol
  class MockDatabaseManager: DatabaseManagerProtocol {
    func saveContext(context: NSManagedObjectContext) throws {
      
    }
    
    var shouldReturnEmpty = false
    var savedCoins = [Coins]()
    
    func fetchCryptoCoins() async throws -> [Coins] {
      return shouldReturnEmpty ? [] : savedCoins
    }
    
    func saveCryptoCoin(_ coin: Coins) async throws {
      savedCoins.append(coin)
    }
  }
  
  var viewModel: CurrencyViewModel!
  var mockNetworkManager: MockNetworkManager!
  var mockDatabaseManager: MockDatabaseManager!
  
  override func setUp() {
    super.setUp()
    mockNetworkManager = MockNetworkManager()
    mockDatabaseManager = MockDatabaseManager()
    viewModel = CurrencyViewModel(networkManager: mockNetworkManager, databaseManager: mockDatabaseManager)
  }
  
  override func tearDown() {
    viewModel = nil
    mockNetworkManager = nil
    mockDatabaseManager = nil
    super.tearDown()
  }
  
  // Test: Fetch from database when data is available
  func testFetchDataFromDatabase() async {
    // Arrange: Simulate database having data
    mockDatabaseManager.shouldReturnEmpty = false
    mockDatabaseManager.savedCoins = [Coins(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: true)]
    
    // Act: Fetch data
    await viewModel.fetchData()
    
    // Assert: Data should come from the database
    XCTAssertEqual(viewModel.data.count, 1)
    XCTAssertEqual(viewModel.data.first?.name, "Bitcoin")
    XCTAssertNil(viewModel.error)
  }
  
  // Test: Fetch from network when database is empty
  func testFetchDataFromNetwork() async {
    // Arrange: Simulate empty database
    mockDatabaseManager.shouldReturnEmpty = true
    
    // Act: Fetch data
    await viewModel.fetchData()
    
    // Assert: Data should come from the network
    XCTAssertEqual(viewModel.data.count, 1)
    XCTAssertEqual(viewModel.data.first?.name, "Bitcoin")
    XCTAssertNil(viewModel.error)
  }
  
  // Test: Handle network error
  func testFetchDataNetworkError() async {
    // Arrange: Simulate network error
    mockNetworkManager.shouldReturnError = true
    mockDatabaseManager.shouldReturnEmpty = true
    
    // Act: Fetch data
    await viewModel.fetchData()
    
    // Assert: Error should be set
    XCTAssertTrue(viewModel.data.isEmpty)
    XCTAssertNotNil(viewModel.error)
    XCTAssertEqual(viewModel.error?.localizedDescription, "Network Error")
  }
  
  // Test: Verify database saving after fetching from network
  func testDatabaseSaveAfterNetworkFetch() async {
    // Arrange: Simulate empty database
    mockDatabaseManager.shouldReturnEmpty = true
    
    // Act: Fetch data
    await viewModel.fetchData()
    
    // Assert: Data should be saved to the database
    XCTAssertEqual(mockDatabaseManager.savedCoins.count, 1)
    XCTAssertEqual(mockDatabaseManager.savedCoins.first?.name, "Bitcoin")
  }
}
