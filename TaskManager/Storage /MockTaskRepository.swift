//
//  MockTaskRepository.swift
//  TaskManagerTests
//
//  Created by Ammar Ul Haq on 14/03/2025.
//

import Foundation
@testable import TaskManager


class MockTaskRepository: TaskRepository {
    
    private var tasks: [TaskItem] = []
    
    func createTask(_ taskItem: TaskItem) {
        tasks.append(taskItem)
    }
    
    func fetchTasks(sortOption: TaskListViewModel.SortOption, filterOption: TaskListViewModel.FilterOption) -> [TaskItem] {
        var filteredTasks = tasks
        
        // Filtering
        switch filterOption {
        case .completed:
            filteredTasks = tasks.filter { $0.isCompleted }
        case .pending:
            filteredTasks = tasks.filter { !$0.isCompleted }
        case .all:
            break
        }
        
        // Sorting
        switch sortOption {
        case .manual:
            break
        case .priority:
            filteredTasks.sort { $0.priority > $1.priority }
        case .dueDate:
            filteredTasks.sort { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
        case .alphabetical:
            filteredTasks.sort { $0.title < $1.title }
        }
        
        return filteredTasks
    }
    
    func updateTask(_ taskItem: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == taskItem.id }) {
            tasks[index] = taskItem
        }
    }
    
    func deleteTask(_ taskItem: TaskItem) {
        tasks.removeAll { $0.id == taskItem.id }
    }
    
    func deleteAllTasks() {
        tasks.removeAll()
    }
    
    func addDummyTasks() {
        tasks = (1...100).map { i in
            TaskItem(
                id: UUID(),
                title: "Dummy Task \(i)",
                description: "Description for Dummy Task \(i)",
                priority: Int16(Int.random(in: 1...3)),
                dueDate: Calendar.current.date(byAdding: .day, value: i % 30, to: Date()),
                isCompleted: Bool.random(),
                order: Int16(i)
            )
        }
    }
}
