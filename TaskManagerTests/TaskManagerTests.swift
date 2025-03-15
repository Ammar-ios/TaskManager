//
//  TaskManagerTests.swift
//  TaskManagerTests
//
//  Created by Ammar Ul Haq on 11/03/2025.
//

import XCTest
@testable import TaskManager

final class TaskManagerTests: XCTestCase {
    
    var listViewModel: TaskListViewModel!
    var repository: MockTaskRepository!

    override func setUpWithError() throws {
        super.setUp()
    
        repository = MockTaskRepository()
        listViewModel = TaskListViewModel(repository: repository)
        
        listViewModel.deleteAllTasks()
    }

    override func tearDownWithError() throws {
        
        listViewModel = nil
        repository = nil
        super.tearDown()
    }
    
    func testAddingTask() throws {
          let newTask = TaskItem(
              id: UUID(),
              title: "Sample Text 1",
              description: "Sample Text 1 Description",
              priority: 1,
              dueDate: Date(),
              isCompleted: false,
              order: 0
          )
          
          listViewModel.createTask(task: newTask)
          listViewModel.fetchTasks()
          
          XCTAssertEqual(listViewModel.tasks.count, 1, "Task count should be 1 after adding a task.")
          XCTAssertEqual(listViewModel.tasks.first?.title, "Sample Text 1", "Task title should match the added task.")
          
          listViewModel.deleteAllTasks()
      }
    
    func testSortingAndFiltering() throws {
           let task1 = TaskItem(id: UUID(), title: "Task B", description: nil, priority: 1, dueDate: Date(), isCompleted: false, order: 0)
           let task2 = TaskItem(id: UUID(), title: "Task A", description: nil, priority: 2, dueDate: nil, isCompleted: true, order: 0)
           
           listViewModel.createTask(task: task1)
           listViewModel.createTask(task: task2)
           
           listViewModel.fetchTasks()
           XCTAssertEqual(listViewModel.tasks.count, 2, "Task count should be 2 after adding tasks.")
           
           // Test filtering by completed tasks
           listViewModel.filterOption = .completed
           listViewModel.fetchTasks()
           XCTAssertEqual(listViewModel.tasks.count, 1, "Should show 1 completed task.")
           XCTAssertEqual(listViewModel.tasks.first?.title, "Task A", "Completed task should be Task A.")
           
           // Test sorting by title
           listViewModel.filterOption = .all
           listViewModel.sortOption = .alphabetical
           listViewModel.fetchTasks()
           XCTAssertEqual(listViewModel.tasks.map { $0.title }, ["Task A", "Task B"], "Tasks should be sorted by title.")
           
           // Test sorting by priority
           listViewModel.sortOption = .priority
           listViewModel.fetchTasks()
           XCTAssertEqual(listViewModel.tasks.map { $0.priority }, [2, 1], "Tasks should be sorted by priority (descending).")
           
           listViewModel.deleteAllTasks()
       }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
