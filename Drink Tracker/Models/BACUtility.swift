//
//  BACUtility.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 10/26/24.
//
import Foundation
import CoreData


struct BACUtility {
    static func calculateBAC(user: User, drinks: [Drink], currentTime: Date) -> Double {
        // Ensure the user's weight is positive
        guard user.weight > 0 else { return 0 }

        // Define metabolism rate and gender constant
        let metabolismRate: Double = 0.015 // Average metabolism rate per hour
        let r: Double = (user.gender.lowercased() == "male") ? 0.68 : 0.55

        // Calculate BAC contributions from each drink
        let bacContributions = drinks.compactMap { drink -> Double? in
            guard let startTime = drink.startTime else { return nil }

            let hoursSinceDrink = currentTime.timeIntervalSince(startTime) / 3600.0

            if hoursSinceDrink < 0 {
                // Drink time is in the future, ignore or handle accordingly
                return nil
            }

            // Calculate grams of alcohol in this drink
            // Formula: A = (ABV / 100) * Volume (mL) * 0.789 (density of ethanol in g/mL)
            let alcoholGrams = (drink.alcoholContent / 100.0) * drink.volume * 0.789

            // Calculate BAC contribution for this drink
            // BAC = (A / (r * W * 10)) - (beta * T)
            let bacFromDrink = (alcoholGrams / (r * user.weight * 10)) - (metabolismRate * hoursSinceDrink)

            // Ensure that the BAC contribution is not negative
            return max(0, bacFromDrink)
        }

        // Sum all BAC contributions
        let totalBAC = bacContributions.reduce(0.0, +)

        // Ensure BAC is not negative
        return max(0, totalBAC)
    }
    
    static func describeBACLevel(bac: Double) -> String {
        switch bac {
        case 0..<0.02: return "Normal behavior, no impairment"
        case 0.02..<0.05: return "Mild impairment, slight mood elevation"
        case 0.05..<0.08: return "Decreased coordination, euphoria"
        case 0.08..<0.15: return "Significant impairment, poor judgment"
        case 0.15..<0.3: return "Severe impairment, potential loss of consciousness"
        case 0.3...: return "Potentially life-threatening"
        default: return "Data unavailable"
        }
    }
    
    static func hoursUntilSober(bac: Double) -> Double {
        // Assuming BAC drops at about 0.015 per hour
        return max(0, bac / 0.015)
    }
}
