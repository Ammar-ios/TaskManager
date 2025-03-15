import SwiftUI

// Main task view
struct TaskView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var showingTaskCreation = false
    @State private var showingDeleteAlert = false
    @State private var showingCompleteAlert = false
    private let repository: TaskRepository
    @Environment(\.accentColor) private var accentColor
    @State private var isPulsing = false // to track pulse animation
    
    init(viewModel: TaskListViewModel, repository: TaskRepository) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.repository = repository
    }

    var body: some View {
        NavigationStack {
            VStack {
               
                
                if viewModel.tasks.isEmpty {
                    EmptyStateView()
                } else {
                    
                    TaskStatusChart(tasks: viewModel.tasks)
                    
                    List {
                        ForEach(viewModel.tasks) { task in
                            NavigationLink(destination: TaskDetailsView(viewModel: TaskDetailsViewModel(
                                task: task,
                                repository: repository,
                                onDelete: { viewModel.fetchTasks() }
                            ))) {
                                TaskRowView(task: task)
                                    .padding(.vertical, 8)
                            }
                            
                            .swipeActions(edge: .trailing) {
                                Button("Delete", role: .destructive) {
                                    let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.error)
                                    viewModel.deleteTask(task)
                                    showingDeleteAlert = true
                                }
                                Button("Complete") {
                                    viewModel.completeTask(task)
                                    showingCompleteAlert = true
                                }
                                .tint(.green)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                        .onMove(perform: moveTask)
                    }
                    .listStyle(.plain)
                    .background(Color(UIColor.systemBackground))
                }
            }
            .onAppear
            {
               // viewModel.addDummyTasks()
               // viewModel.deleteAllTasks()
                //Function to add Dummy 100 tasks call it once and comment it out.
            }
            .navigationTitle("Tasks")
            .toolbar {
                // Add Task with Plus Icon
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        TaskCreationView(viewModel: viewModel)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30)) // Increase size
                            .foregroundColor(accentColor)
                        
                    }
                }
                // Sort & Filter with Filter Icon
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOption) {
                            ForEach(TaskListViewModel.SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        Picker("Filter By", selection: $viewModel.filterOption) {
                            ForEach(TaskListViewModel.FilterOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(accentColor) // Accent color applied
                    }
                }
                // Settings with Settings Icon
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundColor(accentColor) // Accent color applied
                    }
                }
            }
            .onChange(of: viewModel.sortOption) { _, _ in
                viewModel.fetchTasks()
            }
            .onChange(of: viewModel.filterOption) { _, _ in
                viewModel.fetchTasks()
            }
            .alert("Task Deleted", isPresented: $showingDeleteAlert) {
                Button("Undo") { viewModel.undoDelete() }
                Button("OK", role: .cancel) {}
            } message: {
                Text("The task has been deleted.")
            }
            .alert("Task Completed", isPresented: $showingCompleteAlert) {
                Button("Undo") { viewModel.undoComplete() }
                Button("OK", role: .cancel) {}
            } message: {
                Text("The task has been marked as completed.")
            }
            .accentColor(.accentColor) // Applies accent color to navigation elements
        }
    }

    private func moveTask(from source: IndexSet, to destination: Int) {
        viewModel.moveTask(from: source, to: destination)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// Custom view for each task row
struct TaskRowView: View {
    let task: TaskItem
    @Environment(\.accentColor) private var accentColor
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            Rectangle()
                .fill(priorityColor(for: task.priority))
                .frame(width: 5, height: 60)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .accessibilityLabel(task.isCompleted ? "Completed task, \(task.title)" : task.title)
                

                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let dueDate = task.dueDate {
                    let isOverdue = Calendar.current.compare(dueDate, to: Date(), toGranularity: .day) == .orderedAscending
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(accentColor) // Apply accent color to calendar icon
                        Text(formattedDate(dueDate))
                            .font(.caption)
                            .foregroundColor(isOverdue ? .red : .secondary)
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    private func priorityColor(for priority: Int16) -> Color {
        switch priority {
        case 0: return .green // Low
        case 1: return .orange // Medium
        case 2: return .red // High
        default: return .gray
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
