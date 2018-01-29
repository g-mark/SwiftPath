//
//  Feed.swift
//  SwiftPath Example
//
//  Created by Steven Grosmark on 1/28/18.
//  Copyright © 2018 Steven Grosmark. All rights reserved.
//

import Foundation
import SwiftPath

struct Feed: Decodable {
    let name: String
    let uri: String
    let path: String
    
    enum CodingKeys: String, CodingKey {
        case name, uri, path
    }
}

extension Feed {
    var url: URL? { return URL(string: uri) }
    var jsonPath: SwiftPath? { return SwiftPath(path) }
}
