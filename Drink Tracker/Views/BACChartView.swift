//
//  BACChartView.swift
//  Drink Tracker
//
//  Created by Theodore Webb on 9/24/24.
//

import SwiftUI
import Charts
import CoreData

struct BACDataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let bac: Double
}

struct BACChartView: View {
    @ObservedObject var user: User
    var drinks: [Drink]

    private let hoursBack: Double = 4
    private let hoursForward: Double = 12
    private let intervalMinutes: Double = 15

    private var dataPoints: [BACDataPoint] {
        let now = Date()
        let startTime = now.addingTimeInterval(-hoursBack * 3600)
        let endTime = now.addingTimeInterval(hoursForward * 3600)

        var points: [BACDataPoint] = []
        var currentTime = startTime

        while currentTime <= endTime {
            let bac = BACUtility.calculateBAC(user: user, drinks: drinks, currentTime: currentTime)
            points.append(BACDataPoint(time: currentTime, bac: bac))
            currentTime = currentTime.addingTimeInterval(intervalMinutes * 60)
        }

        return points
    }

    private var currentBAC: Double {
        BACUtility.calculateBAC(user: user, drinks: drinks, currentTime: Date())
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("BAC Over Time")
                .font(.headline)

            Chart {
                // BAC curve
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("Time", point.time),
                        y: .value("BAC", point.bac)
                    )
                    .foregroundStyle(.blue)

                    AreaMark(
                        x: .value("Time", point.time),
                        y: .value("BAC", point.bac)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }

                // Legal limit line (0.08)
                RuleMark(y: .value("Legal Limit", 0.08))
                    .foregroundStyle(.red.opacity(0.7))
                    .lineStyle(StrokeStyle(dash: [5, 5]))
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("0.08")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }

                // Current time marker
                RuleMark(x: .value("Now", Date()))
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
            .chartYScale(domain: 0...max(0.1, dataPoints.map(\.bac).max() ?? 0.1))
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 250)
        }
        .padding()
    }
}
