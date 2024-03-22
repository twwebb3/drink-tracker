//
//  Drink.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 3/21/24.
//

import Foundation

struct Drink {
    var type: String // For simplicity, this could just be the name of the drink
    var alcoholContent: Double // Alcohol by volume (ABV) percentage
    var volume: Double // Volume of drink in milliliters
    var startTime: Date? // When the user starts the drink
    var endTime: Date? // When the user finishes the drink
}
