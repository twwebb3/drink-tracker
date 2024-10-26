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
    var dataManager = DataManager(context: PersistenceController.shared.container.viewContext)
    var user = User()
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataManager: dataManager, user: user)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
