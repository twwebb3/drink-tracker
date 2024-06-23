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

    var body: some View {
        VStack {
            Button("Clear Drink History") {
                dataManager.clearDrinkHistory(context: viewContext)
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Settings")
    }
}

extension Notification.Name {
    static let didWipeData = Notification.Name("didWipeData")
}
