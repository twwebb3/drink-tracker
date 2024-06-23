//
//  Drink_TrackerApp.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 3/21/24.
//

import SwiftUI

@main
struct Drink_TrackerApp: App {
    let persistenceController = PersistenceController.shared
    var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataManager: dataManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
