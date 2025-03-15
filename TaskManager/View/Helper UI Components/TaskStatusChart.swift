//
//  TaskStatusChart.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 13/03/2025.
//

import Foundation
import SwiftUI
import Charts


struct TaskCategory: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}

struct TaskStatusChart: View {
    let tasks: [TaskItem]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
            // Calculate task statistics
            let completedCount = tasks.filter { $0.isCompleted }.count
            let pendingCount = tasks.filter { !$0.isCompleted }.count
            let totalTasks = tasks.count
            
            // Define chart data
            let categories = [
                TaskCategory(name: "Completed", count: completedCount),
                TaskCategory(name: "Pending", count: pendingCount)
            ]
            
            // Define chart colors based on color scheme
            let taskChartColors = colorScheme == .dark ? chartColorsDark : chartColors
            
            // Horizontal layout with chart and statistics
            HStack {
                // Chart with increased size
                Chart(categories) { category in
                    SectorMark(
                        angle: .value("Tasks", category.count),
                        innerRadius: .ratio(0.65),
                        angularInset: 2.0
                    )
                    .foregroundStyle(by: .value("Category", category.name))
                    .cornerRadius(10.0)
                    .annotation(position: .overlay) {
                        Text("\(category.count)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .chartForegroundStyleScale(
                    domain: ["Completed", "Pending"],
                    range: taskChartColors
                )
                .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.2) // Larger chart
                
                // Statistics with increased vertical spacing
                VStack(alignment: .leading, spacing: 15) { // More spacing between titles
                    Text("Task Overview")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    HStack {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("Completed: \(completedCount)")
                            .font(.subheadline)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    
                    HStack {
                        Circle().fill(Color.orange).frame(width: 10, height: 10)
                        Text("Pending: \(pendingCount)")
                            .font(.subheadline)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    
                    HStack {
                        Circle().fill(Color.blue).frame(width: 10, height: 10)
                        Text("Total Tasks: \(totalTasks)")
                            .font(.subheadline)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                }
                .padding(.leading, 20) // Spacing between chart and stats
            }
            .frame(width: UIScreen.main.bounds.width * 0.9) // Reduced padding for compactness
        
    }
}

// Placeholder for chart colors (define these based on your app’s theme)
let chartColors: [Color] = [.green, .orange]
let chartColorsDark: [Color] = [.init(red: 0.2, green: 0.8, blue: 0.2), .init(red: 1.0, green: 0.5, blue: 0.0)]
