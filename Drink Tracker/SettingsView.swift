//
//  SettingsView.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 3/21/24.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dataManager: DataManager
    @ObservedObject var user: User

    var body: some View {
        VStack {
            Button("Clear Drink History") {
                dataManager.clearDrinkHistory(context: viewContext)
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(8)
            
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Weight (kg)", value: $user.weight, formatter: NumberFormatter())
                    TextField("Height (cm)", value: $user.height, formatter: NumberFormatter())
                    Picker("Gender", selection: $user.gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Settings")
    }
}

extension Notification.Name {
    static let didWipeData = Notification.Name("didWipeData")
}

extension NumberFormatter {
    static var weightFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    static var heightFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }
}
