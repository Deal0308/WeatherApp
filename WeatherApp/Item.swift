//
//  Item.swift
//  WeatherApp
//
//  Created by Michael Deal on 8/20/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
