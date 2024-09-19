//
//  DataView.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 8/19/24.
//

import SwiftUI
import CoreData

struct DataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dataManager: DataManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Drink.startTime, ascending: true)],
        animation: .default
    )
    private var drinks: FetchedResults<Drink>

    var body: some View {
        List {
            ForEach(drinks) { drink in
                VStack(alignment: .leading) {
                    Text(drink.type ?? "Unknown Type")
                        .font(.headline)
                    HStack {
                        Text("Alcohol Content: \(drink.alcoholContent, specifier: "%.1f")%")
                        Spacer()
                        Text("Volume: \(drink.volume, specifier: "%.1f") ml")
                    }
                    .font(.subheadline)
                    HStack {
                        Text("Start: \(formatDate(drink.startTime))")
                        Spacer()
                        Text("End: \(formatDate(drink.endTime))")
                    }
                    .font(.caption)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Drinks")
    }
    
    private func formatDate(_ date: Date?) -> String {
            guard let date = date else { return "N/A" }
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
}

