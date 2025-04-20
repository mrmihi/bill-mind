//
//  Item.swift
//  billMind
//
//  Created by Pasindu Dinal on 2025-04-20.
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
