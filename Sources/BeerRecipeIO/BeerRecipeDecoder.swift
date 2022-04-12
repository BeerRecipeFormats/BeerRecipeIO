//
//  BeerRecipeDecoder.swift
//  BeerRecipeIO
//
//  Created by Thomas Bonk on 08.04.22.
//  Copyright © 2022 Thomas Bonk <thomas@meandmymac.de>
//
//  Licensed under the Apache License, Version 2.0 (the "License"):
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AbstractBeerRecipe
import Foundation

public protocol BeerRecipeDecoder {
  
  // MARK: Methods
  
  /// Read the contents from the given URL, parse the recipe and return it.
  /// A default implementation exists for this method.
  ///
  /// - Parameters:
  ///   - url: The URL of the recipe
  /// - Returns: The recipe
  func decode(url: URL) async -> Result<[BeerRecipe], Error>
  
  /// Read the contents from the given URL, parse the recipe and return it.
  /// A default implementation exists for this method. This method is working
  /// synchronously
  ///
  /// - Parameters:
  ///   - url: The URL of the recipe
  /// - Returns: The recipe
  func decodeSync(url: URL) -> Result<[BeerRecipe], Error>
  
  /// Parse the recipe form the data and return it.
  ///
  /// - Parameters:
  ///   - data: The recipe data with the recipe
  /// - Returns: The recipe
  func decode(data: Data) -> Result<[BeerRecipe], Error>
  
  /// Parse the recipe form the string and return it.
  /// A default implementation exists for this method.
  ///
  /// - Parameters:
  ///   - string: The recipe with the recipe
  /// - Returns: The recipe
  func decode(string: String) -> Result<[BeerRecipe], Error>
}

public extension BeerRecipeDecoder {
  
  @available(swift 5.5)
  func decode(url: URL) async -> Result<[BeerRecipe], Error> {
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      
      return decode(data: data)
    } catch {
      return Result.failure(error)
    }
  }
  
  func decodeSync(url: URL) -> Result<[BeerRecipe], Error> {
    let semaphore = DispatchSemaphore(value: 0)
    var result: Result<[BeerRecipe], Error>?
    
    let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
      guard error == nil else {
        result = Result.failure(error!)
        semaphore.signal()
        return
      }
      
      result = decode(data: data!)
      semaphore.signal()
    }
    
    task.resume()
    semaphore.wait()
    return result!
  }
  
  func decode(string: String) -> Result<[BeerRecipe], Error> {
    return decode(data: string.data(using: .utf8)!)
  }
}
