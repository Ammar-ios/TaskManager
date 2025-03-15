//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 11/03/2025.
//

import SwiftUI

@main
struct TaskManagerApp: App {
    let persistenceController = PersistenceController.shared
    let repository: TaskRepository
    @AppStorage("accentColorHex") private var accentColorHex: String = Color.blue.hexString

    init() {
        let coreDataManager = CoreDataManager(persistentContainer: persistenceController.container)
        repository = coreDataManager
    }

    var body: some Scene {
        WindowGroup {
            TaskView(
                viewModel: TaskListViewModel(repository: repository),
                repository: repository
            )
            .environment(\.accentColor, Color(hex: accentColorHex))
        }
    }
    
    
}
