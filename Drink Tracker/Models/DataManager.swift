import Foundation
import CoreData
import Combine

class DataManager: ObservableObject {
    @Published var refreshTrigger = false
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
            self.viewContext = context
    }
    
    private func setupNotification() {
        
        NotificationCenter.default.addObserver(forName: .didWipeData, object: nil, queue: .main) { _ in
            self.refreshData()
        }
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: .main) { _ in
            self.refreshData()
        }
    }

    func refreshData() {
        viewContext.performAndWait {
                viewContext.refreshAllObjects()
            }
    }

    func clearDrinkHistory(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Drink")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            notifyRefresh(context: context)
        } catch {
            print("Error clearing drink history: \(error)")
        }
    }

    func notifyRefresh(context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            self.refreshTrigger.toggle()
            context.refreshAllObjects()  // Ensure UI is synced with the latest data state
        }
    }
    
    func addDrink(type: String, alcoholContent: Double, volume: Double) {
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



