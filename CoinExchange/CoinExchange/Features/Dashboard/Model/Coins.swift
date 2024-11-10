//
//  Coins.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import Foundation

struct Coins: Codable, Hashable {
  let name: String
  let symbol: String
  let type: String
  let isActive: Bool
  let isNew: Bool
}

struct FilterOption {
  var isActive: Bool?
  var type: String?
  var isNew: Bool?
}

enum FilterButtonType {
  case activeCoin
  case onlyCoin
  case onlyToken
  case inactiveCoin
  case newCoin
}
