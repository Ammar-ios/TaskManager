//
//  TaskDetailsViewModel.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 12/03/2025.
//

import Foundation
import SwiftUI


class TaskDetailsViewModel: ObservableObject {
    // Make task private to prevent direct access from the View
    private var task: TaskItem
    private let repository: TaskRepository
    private let onDelete: () -> Void
    

    init(task: TaskItem, repository: TaskRepository, onDelete: @escaping () -> Void = {}) {
        self.task = task
        self.repository = repository
        self.onDelete = onDelete
    }

    // Expose properties for the View to use
    var title: String { task.title }
    var isCompleted: Bool { task.isCompleted }
    var description: String? { task.description }
    var priority: Int16 { task.priority }

    /// Sets the task's completion status and updates it in the repository
    func setCompletion(to newValue: Bool) {
        task.isCompleted = newValue
        repository.updateTask(task)
        onDelete()
        
    }

    /// Deletes the task from the repository
    func deleteTask() {
        repository.deleteTask(task)
        onDelete()
    }

    /// Formats the due date for display
    func formattedDueDate() -> String {
        guard let dueDate = task.dueDate else { return "No Due Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dueDate)
    }

    /// Returns the priority as a string
    func priorityText() -> String {
        switch task.priority {
        case 0: return "Low"
        case 1: return "Medium"
        case 2: return "High"
        default: return "Unknown"
        }
    }

    /// Returns the color based on priority
    func priorityColor() -> Color {
        switch task.priority {
        case 0: return .blue
        case 1: return .orange
        case 2: return .red
        default: return .gray
        }
    }
}
