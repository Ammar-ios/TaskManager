//
//  CoreDataManager.swift
//  TaskManager
//
//  Created by Ammar Ul Haq on 11/03/2025.
//

import CoreData

protocol TaskRepository {
    func createTask(_ taskItem: TaskItem)
    func fetchTasks(sortOption: TaskListViewModel.SortOption, filterOption: TaskListViewModel.FilterOption) -> [TaskItem]
    func updateTask(_ taskItem: TaskItem)
    func deleteTask(_ taskItem: TaskItem)
    func deleteAllTasks()
    func addDummyTasks()
}

class CoreDataManager: TaskRepository {
   
    
    let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = persistentContainer
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func addDummyTasks() {
        for i in 1...100 {
            let task = Task(context: context)
            task.id = UUID()
            task.title = "Dummy Task \(i)"
            task.taskdescription = "This is a dummy task description for task \(i)."
            task.priority = Int16([0,1, 2].randomElement()!) // Random priority (1 to 3)
            task.dueDate = Calendar.current.date(byAdding: .day, value: i % 30, to: Date()) // Spread due dates
            task.isCompleted = Bool.random() // Random completion status
            task.order = Int16(i) // Order based on loop index
        }
        
        saveContext()
        print("✅ Successfully added 100 dummy tasks.")
    }

    
    func createTask(_ taskItem: TaskItem) {
        let task = Task(context: context)
        task.id = taskItem.id
        task.title = taskItem.title
        task.taskdescription = taskItem.description
        task.priority = taskItem.priority
        task.dueDate = taskItem.dueDate
        task.isCompleted = taskItem.isCompleted
        task.order = taskItem.order // Keep order value

        saveContext()
    }

    
    func fetchTasks(sortOption: TaskListViewModel.SortOption, filterOption: TaskListViewModel.FilterOption) -> [TaskItem] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Sorting
        switch sortOption {
        case .manual:
            request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        case .priority:
            request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        case .dueDate:
            request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        case .alphabetical:
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }

        do {
            var tasks = try context.fetch(request)
            
            // Filtering
            switch filterOption {
            case .completed:
                tasks = tasks.filter { $0.isCompleted }
            case .pending:
                tasks = tasks.filter { !$0.isCompleted }
            case .all:
                break // No filtering
            }

            return tasks.map { task in
                TaskItem(
                    id: task.id!, // Use the existing ID from the Task entity
                    title: task.title ?? "Untitled",
                    description: task.taskdescription,
                    priority: task.priority,
                    dueDate: task.dueDate,
                    isCompleted: task.isCompleted,
                    order: task.order
                )
            }
            
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }

    
    func updateTask(_ taskItem: TaskItem) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", taskItem.id as CVarArg)

        do {
            if let task = try context.fetch(request).first {
                task.title = taskItem.title
                task.taskdescription = taskItem.description
                task.priority = taskItem.priority
                task.dueDate = taskItem.dueDate
                task.isCompleted = taskItem.isCompleted
                task.order = taskItem.order

                saveContext()
            }
            else
            {
                print("")
            }
        } catch {
            print("Failed to update task: \(error)")
        }
    }
    
    func deleteAllTasks() {
        
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

            do {
                let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            } catch {
                print("Failed to delete all tasks: \(error)")
            }
        }
    

    
    func deleteTask(_ taskItem: TaskItem) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", taskItem.id as CVarArg)

        do {
            if let task = try context.fetch(request).first {
                context.delete(task)
                saveContext()
            }
        } catch {
            print("Failed to delete task: \(error)")
        }
    }
}
