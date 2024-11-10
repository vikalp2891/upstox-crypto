//
//  NetworkManager.swift
//  CoinExchange
//
//  Created by Vikalp on 10/11/24.
//

import Foundation

enum HttpMethod: String {
  case get
  case post
  
  var method: String { rawValue.uppercased() }
}

protocol NetworkRequestable {
  func fetchData<T: Decodable>(for url: URL, httpMethod: HttpMethod) async throws -> T
}

class NetworkManager {
  
  enum ManagerErrors: Error {
    case invalidResponse
    case invalidStatusCode(Int)
  }
  
  private let session: NetworkRequestable
  
  init(session: NetworkRequestable = URLSession.shared) {
    self.session = session
  }
  
  func request<T: Decodable>(fromURL url: URL, httpMethod: HttpMethod = .get) async throws -> T {
    return try await session.fetchData(for: url, httpMethod: httpMethod)
  }
}

extension URLSession: NetworkRequestable {
  func fetchData<T: Decodable>(for url: URL, httpMethod: HttpMethod) async throws -> T {
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.method
    
    let (data, response) = try await self.data(for: request)
    
    guard let urlResponse = response as? HTTPURLResponse else {
      throw NetworkManager.ManagerErrors.invalidResponse
    }
    
    if !(200..<300).contains(urlResponse.statusCode) {
      throw NetworkManager.ManagerErrors.invalidStatusCode(urlResponse.statusCode)
    }
    
    do {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let decodedData = try decoder.decode(T.self, from: data)
      return decodedData
    } catch {
      throw error
    }
  }
}
