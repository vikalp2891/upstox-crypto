//
//  CoinFilterTests.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import XCTest
import Combine
@testable import CoinExchange

class FilterTests: XCTestCase {
  
  var viewModel: CurrencyViewModel! // Assuming the class where applyFilters and deselectFilter are defined
  var cancellables: Set<AnyCancellable> = []
  
  override func setUp() {
    super.setUp()
    viewModel = CurrencyViewModel(networkManager: URLSession.shared, databaseManager: DatabaseManager())
    // Sample Data to use in test cases
    viewModel.data = [
      Coins(name: "Bitcoin", symbol: "BTC", type: "coin", isActive: true, isNew: false),
      Coins(name: "Ethereum", symbol: "ETH", type: "token", isActive: true, isNew: false),
      Coins(name: "Ripple", symbol: "XRP", type: "coin", isActive: false, isNew: false),
      Coins(name: "Cardano", symbol: "ADA", type: "coin", isActive: true, isNew: true),
      Coins(name: "Litecoin", symbol: "LTC", type: "coin", isActive: true, isNew: false),
      Coins(name: "Chainlink", symbol: "LINK", type: "token", isActive: true, isNew: true),
      Coins(name: "Polkadot", symbol: "DOT", type: "coin", isActive: true, isNew: true),
      Coins(name: "Tezos", symbol: "XTZ", type: "token", isActive: true, isNew: true),
      Coins(name: "Maker", symbol: "MKR", type: "token", isActive: true, isNew: true)
    ]
    
  }
  
  // Test applyFilters with "Active Coin" filter
  func testApplyFilters_ActiveCoin() {
    let expectation = XCTestExpectation(description: "Filtered data should contain only active coins")
    
    let filterOption = FilterOption(isActive: true, type: "coin")
    viewModel.applyFilters(option: filterOption)
    
    viewModel.$filteredData
      .sink { filteredData in
        let expectedFilteredData = self.viewModel.data.filter { $0.isActive == true && $0.type == "coin" }
        XCTAssertEqual(filteredData.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  // Test applyFilters with "Inactive Token" filter
  func testApplyFilters_InactiveCoin() {
    
    let filterOption = FilterOption(isActive: false, type: "coin")
    viewModel.applyFilters(option: filterOption)
    let expectation = XCTestExpectation(description: "Filtered data should contain only Inactive coin")
    viewModel.$filteredData
      .sink { filteredData in
        let expectedFilteredData = self.viewModel.data.filter { $0.isActive == false && $0.type == "coin" }
        XCTAssertEqual(filteredData.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1.0)

  }
  
  // Test applyFilters with "New Coins" filter
  func testApplyFilters_NewCoin() {
    let filterOption = FilterOption(type: "coin", isNew: true)
    viewModel.applyFilters(option: filterOption)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain only new coins")
    viewModel.$filteredData
      .sink { filteredData in
        let expectedFilteredData = self.viewModel.data.filter { $0.isNew == true && $0.type == "coin" }
        XCTAssertEqual(filteredData.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1.0)

  }
  
  // Test applyFilters with "All Tokens" filter
  func testApplyFilters_AllTokens() {
    let filterOption = FilterOption(type: "token")
    viewModel.applyFilters(option: filterOption)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain only tokens")
    viewModel.$filteredData
      .sink { filteredData in
        let expectedFilteredData = self.viewModel.data.filter { $0.type == "token" }
        XCTAssertEqual(filteredData.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1.0)

  }
  
  func testApplyFilters_AllCoins() {
    let filterOption = FilterOption(type: "coin")
    viewModel.applyFilters(option: filterOption)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain only coins")
    viewModel.$filteredData
      .sink { filteredData in
        let expectedFilteredData = self.viewModel.data.filter { $0.type == "coin" }
        XCTAssertEqual(filteredData.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1.0)
    
  }
  
  func testApplyFilters_MultiSelection() {
    let filterOption1 = FilterOption(isActive: true, type: "coin")
    viewModel.applyFilters(option: filterOption1)
    let filterOption2 = FilterOption(isActive: true, type: "token")
    viewModel.applyFilters(option: filterOption2)
    
    let expectation = XCTestExpectation(description: "Filtered data should contain coins and tokens")
    viewModel.$filteredData
      .sink { filteredData in
        let expectedFilteredData = self.viewModel.data.filter { $0.isActive == true }
        XCTAssertEqual(filteredData.count, expectedFilteredData.count, "Filtered data match expected results")
        expectation.fulfill()
      }
      .store(in: &cancellables)
    
    wait(for: [expectation], timeout: 1.0)
    
  }
  
  override func tearDown() {
    // Reset any necessary state
    viewModel = nil
    super.tearDown()
  }
}
