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
                        addDrink(type: drink.type, alcoholContent: drink.alcoholContent, volume: drink.volume)
                    }
                }
                
                Section(header: Text("Estimated BAC")) {
                    Text("BAC: \(calculateBAC(currentTime: Date()), specifier: "%.3f")‰")
                    Text("Feeling: \(describeBACLevel(bac: calculateBAC(currentTime: Date())))")
                    Text("Hours until sober: \(hoursUntilSober(bac: calculateBAC(currentTime: Date())), specifier: "%.2f")")
                }
                
                Section(header: Text("Last Drink")) {
                    if let lastDrink = drinks.last {
                                        Section {
                                            Text("Last Drink: \(lastDrink.startTime ?? Date(), formatter: itemFormatter)")
                                        }
                                    }
                }
                
                Section {
                    NavigationLink(destination: SettingsView(dataManager: dataManager)) {
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
    
    private func addDrink(type: String, alcoholContent: Double, volume: Double) {
        withAnimation {
            let newDrink = Drink(context: viewContext)
            newDrink.type = type
            newDrink.alcoholContent = alcoholContent
            newDrink.volume = volume
            newDrink.startTime = Date()
            newDrink.endTime = Date().addingTimeInterval(3600) // For simplicity, 1 hour later
            
            do {
                try viewContext.save()
            } catch {
                // Handle the Core Data error, e.g., show an error message
                print(error.localizedDescription)
            }
        }
    }
    
    private func calculateBAC(currentTime: Date) -> Double {
        guard weight > 0 else { return 0 }

        let metabolismRate = 0.015 // Average metabolism rate per hour

        // Calculate total grams of alcohol, adjusted for metabolism over time from each drink
        let totalAlcoholGrams = drinks.reduce(0) { total, drink in
            guard let startTime = drink.startTime else { return total }
            
            let hoursSinceDrink = currentTime.timeIntervalSince(startTime) / 3600 // Convert seconds to hours
            let initialAlcoholGrams = drink.alcoholContent * drink.volume * 0.789 / 100
            
            // If the drink has been fully metabolized, don't include it
            if hoursSinceDrink * metabolismRate >= initialAlcoholGrams / weight {
                return total
            }
            
            let remainingAlcohol = max(0, initialAlcoholGrams - (hoursSinceDrink * metabolismRate * weight))
            return total + remainingAlcohol
        }
        
        // Convert body weight to grams and adjust for water distribution ratio
        let bodyWeightGrams = weight * 1000 // Convert kg to grams
        let adjustedBodyWeight = bodyWeightGrams * (gender == "Male" ? 0.68 : 0.55)
        
        // Calculate BAC
        let bac = (totalAlcoholGrams / adjustedBodyWeight) * 100
        
        // Ensure BAC is not negative
        return max(0, bac)
    }


    
    private func describeBACLevel(bac: Double) -> String {
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
    
    private func hoursUntilSober(bac: Double) -> Double {
        // Assuming BAC drops at about 0.015 per hour
        return max(0, bac / 0.015)
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
        ContentView(dataManager: DataManager()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

