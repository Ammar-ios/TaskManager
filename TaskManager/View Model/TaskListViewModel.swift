//
//  TaskListViewModel.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 11/03/2025.
//

import Foundation

import SwiftUI

class TaskListViewModel: ObservableObject {
    // Published properties to update the UI automatically
    @Published var tasks: [TaskItem] = []
    @Published var sortOption: SortOption = .manual
    @Published var filterOption: FilterOption = .all

    // Enum for sorting options, including manual sorting
    enum SortOption: String, CaseIterable {
        case manual = "Manual"
        case priority = "Priority"
        case dueDate = "Due Date"
        case alphabetical = "Alphabetical"
    }

    // Enum for filtering options
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case completed = "Completed"
        case pending = "Pending"
    }

    // Dependency on TaskRepository protocol
    private let repository: TaskRepository
    
    private var lastDeletedTask: TaskItem?
    private var lastCompletedTask: TaskItem?
    

    // Initializer with dependency injection
    init(repository: TaskRepository) {
        self.repository = repository
        fetchTasks()
    }
    
    
    var completionPercentage: Double {
            let totalTasks = tasks.count
            guard totalTasks > 0 else { return 0.0 }
            let completedTasks = tasks.filter { $0.isCompleted }.count
            return Double(completedTasks) / Double(totalTasks)
        }
    
    /// Creates a new task and refreshes the task list
    func createTask(task: TaskItem) {
        repository.createTask(task)
        fetchTasks()
    }
    
    func addDummyTasks()
    {
        repository.addDummyTasks()
        fetchTasks()
    }
    
    func deleteAllTasks()
    {
        repository.deleteAllTasks()
        fetchTasks()
    }
    
    /// Deletes a task, stores it for potential undo, and refreshes the list
    func deleteTask(_ task: TaskItem) {
        lastDeletedTask = task
        repository.deleteTask(task)
        fetchTasks()
    }
    
    /// Undoes the last deletion by recreating the task with a new ID
    func undoDelete() {
        if let task = lastDeletedTask {
            let newTask = TaskItem(
                id: UUID(), // Generate a new ID to avoid conflicts
                title: task.title,
                description: task.description,
                priority: task.priority,
                dueDate: task.dueDate,
                isCompleted: task.isCompleted,
                order: task.order
            )
            repository.createTask(newTask)
            lastDeletedTask = nil
            fetchTasks()
        }
    }
    
    /// Marks a task as completed and refreshes the list
    func completeTask(_ task: TaskItem) {
        lastCompletedTask = task
        var updatedTask = task
        updatedTask.isCompleted = true
        repository.updateTask(updatedTask)
        fetchTasks()
    }
    
    /// Undoes the last completion and refreshes the list
    func undoComplete() {
        if let task = lastCompletedTask {
            var updatedTask = task
            updatedTask.isCompleted = false
            repository.updateTask(updatedTask)
            lastCompletedTask = nil
            fetchTasks()
        }
    }
    
    /// Reorders tasks and updates their order in the repository
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        for (index, _) in tasks.enumerated() {
            tasks[index].order = Int16(index) // Update order directly in the array
            repository.updateTask(tasks[index])
        }
        // No need to call fetchTasks() if sortOption is .manual, as the array is already updated
        if sortOption != .manual {
            fetchTasks() // Refresh to apply other sorting if not manual
        }
    }

    /// Fetches tasks from the repository with the current sort and filter options
    func fetchTasks() {
        tasks = repository.fetchTasks(sortOption: sortOption, filterOption: filterOption)
    }
}
