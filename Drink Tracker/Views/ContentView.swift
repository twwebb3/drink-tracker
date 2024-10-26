//
//  ContentView.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 3/21/24.
//

import SwiftUI
import CoreData

struct DrinkOption {
    var type: String
    var alcoholContent: Double
    var volume: Double
}

let predefinedDrinks = [
    DrinkOption(type: "Single", alcoholContent: 40, volume: 45),
    DrinkOption(type: "Double", alcoholContent: 40, volume: 90),
    DrinkOption(type: "Beer", alcoholContent: 4, volume: 384),
    DrinkOption(type: "Water", alcoholContent: 0, volume: 100)
]

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dataManager: DataManager
    @ObservedObject var user: User
    
    // Fetching drinks from CoreData
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Drink.startTime, ascending: true)],
        animation: .default)
    private var drinks: FetchedResults<Drink>
    
    private var itemFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
            return formatter
        }
    
    // State for the selected drink option
    @State private var selectedDrinkIndex = 0

    // Hardcoded user info
    let weight: Double = 81.193 // kg
    let height: Double = 180.34 // cm
    let gender: String = "Male"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select Drink")) {
                    Picker("Drink Type", selection: $selectedDrinkIndex) {
                                            ForEach(0..<predefinedDrinks.count, id: \.self) { index in
                                                Text(predefinedDrinks[index].type).tag(index)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                }
                .onAppear(perform: setupNotification)
                
                Section(header: Text("Add Drink")) {
                    Button("Add Drink") {
                        let drink = predefinedDrinks[selectedDrinkIndex]
                        dataManager.addDrink(type: drink.type, alcoholContent: drink.alcoholContent, volume: drink.volume)
                    }
                }
                
                Section(header: Text("Estimated BAC")) {
                    let bac = BACUtility.calculateBAC(user: user, drinks: Array(drinks), currentTime: Date())
                    Text("BAC: \(bac, specifier: "%.3f")‰")
                    Text("Feeling: \(BACUtility.describeBACLevel(bac: bac))")
                    Text("Hours until sober: \(BACUtility.hoursUntilSober(bac: bac), specifier: "%.2f")")
                }
                
                Section(header: Text("Last Drink")) {
                    if let lastDrink = drinks.last {
                                        Section {
                                            Text("Last Drink: \(lastDrink.startTime ?? Date(), formatter: itemFormatter)")
                                        }
                                    }
                }
                
                Section {
                    NavigationLink(destination: SettingsView(dataManager: dataManager, user: user)) {
                        Text("Settings")
                    }
                    NavigationLink(destination: DataView(dataManager: dataManager)) {
                        Text("Data")
                    }
                }
                
                Section(header: Text("Refresh")) {
                    Button("Refresh Data") {
                        self.refreshData()
                    }
                }
            }
            .navigationBarTitle("BAC Tracker")
            .onReceive(dataManager.$refreshTrigger) { _ in
                // Trigger a view refresh
            }
        }
    }
    
    
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(forName: .didWipeData, object: nil, queue: .main) { _ in
            refreshData()
        }
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: .main) { _ in
            refreshData()
        }
    }

    private func refreshData() {
        viewContext.performAndWait {
                viewContext.refreshAllObjects()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataManager: DataManager(context: PersistenceController.shared.container.viewContext), user: User()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

