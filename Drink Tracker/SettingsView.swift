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

    var body: some View {
        VStack {
            Button("Clear Drink History") {
                clearDrinkHistory()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Settings")
    }
    
    private func clearDrinkHistory() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Drink")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(batchDeleteRequest)
            try viewContext.save() // Save the context after deletion
        } catch {
            // Handle the error appropriately
            print("Error clearing drink history: \(error)")
        }
    }
}
