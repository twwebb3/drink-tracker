//
//  User.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 3/21/24.
//

// User.swift

import Foundation
import Combine

class User: ObservableObject {
    @Published var weight: Double {
        didSet { save() }
    }
    @Published var height: Double {
        didSet { save() }
    }
    @Published var gender: String {
        didSet { save() }
    }
    
    init() {
        // Load saved user data or set default values
        self.weight = UserDefaults.standard.double(forKey: "user_weight") != 0 ? UserDefaults.standard.double(forKey: "user_weight") : 81.193
        self.height = UserDefaults.standard.double(forKey: "user_height") != 0 ? UserDefaults.standard.double(forKey: "user_height") : 180.34
        self.gender = UserDefaults.standard.string(forKey: "user_gender") ?? "Male"
    }
    
    private func save() {
        UserDefaults.standard.set(weight, forKey: "user_weight")
        UserDefaults.standard.set(height, forKey: "user_height")
        UserDefaults.standard.set(gender, forKey: "user_gender")
    }
}

