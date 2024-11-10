//
//  Coins.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import Foundation

//MARK: Codable object for Coins Data
struct Coins: Codable, Hashable {
  let name: String
  let symbol: String
  let type: String
  let isActive: Bool
  let isNew: Bool
}

//MARK: To filter out coins
struct FilterOption {
  var isActive: Bool?
  var type: String?
  var isNew: Bool?
}
