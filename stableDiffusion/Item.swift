//
//  Item.swift
//  stableDiffusion
//
//  Created by Allison McEntire on 6/25/23.
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
