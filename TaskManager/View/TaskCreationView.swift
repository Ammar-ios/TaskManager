//
//  TaskCreationView.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 12/03/2025.
//

import SwiftUI

struct TaskCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accentColor) private var accentColor // Access the user-defined accent color
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Int16 = 1 // Default to Medium
    @State private var dueDate = Date()
    @ObservedObject private var viewModel: TaskListViewModel
    

    init(viewModel: TaskListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(Int16(0))
                        Text("Medium").tag(Int16(1))
                        Text("High").tag(Int16(2))
                    }
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                    .tint(accentColor) // Apply the custom accent color
                    .accessibilityLabel("Save Task.")
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveTask() {
        let newTask = TaskItem(
            id: UUID(), // Assign a unique identifier
            title: title,
            description: description.isEmpty ? nil : description, // Handle empty description
            priority: priority,
            dueDate: dueDate,
            isCompleted: false,
            order: 0 // New tasks should get the correct order later
        )
        
        viewModel.createTask(task: newTask)
    }
}
