//
//  Coin.swift
//  SwiftPath Example
//
//  Created by Steven Grosmark on 1/28/18.
//  Copyright © 2018 Steven Grosmark. All rights reserved.
//

import Foundation

struct Coin: Decodable {
    let name: String
    let symbol: String
    let usd: Double
    
    enum CodingKeys: String, CodingKey {
        case name, symbol
        case usd
    }
}

extension Coin {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name: String = try container.decode(String.self, forKey: .name)
        let symbol: String = try container.decode(String.self, forKey: .symbol)
        let usd: Double
        if let doubleString = try? container.decode(String.self, forKey: .usd),
            let doubleFromString = Double(doubleString) {
            usd = doubleFromString
        }
        else {
            usd = try container.decode(Double.self, forKey: .usd)
        }
        self.init(name: name, symbol: symbol, usd: usd)
    }
}
