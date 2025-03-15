//
//  TaskItem.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 12/03/2025.
//

import Foundation


struct TaskItem: Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let priority: Int16
    let dueDate: Date?
    var isCompleted: Bool
    var order: Int16
}
