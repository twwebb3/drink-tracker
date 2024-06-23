import Foundation
import CoreData
import Combine

class DataManager: ObservableObject {
    @Published var refreshTrigger = false

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
}



