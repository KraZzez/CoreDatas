//
//  CoreDataManager.swift
//  NYTest
//
//  Created by Ludvig Krantzén on 2022-11-23.
//
// 49:19 Core Data Relationships, predicatates...

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    
    let persistentContainer: NSPersistentContainer
    static let shared: CoreDataManager = CoreDataManager()
    private init() {
        
        persistentContainer = NSPersistentContainer(name: "CoreDataModel")
        persistentContainer.loadPersistentStores { description, error  in
            if let error = error {
                fatalError("Unable to initialize Core Data \(error)")
            }
        }
    }
}


class CoreDataManagers {
    static let instance = CoreDataManagers()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { (descrption, error) in
            if let error = error {
                print("Error loading Core Data. \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
            print("saved")
        } catch let error {
            print("Error saving Core Data. \(error.localizedDescription)")
        }
    }
}

class CoreDataRelationshipViewModel: ObservableObject {
    
    let manager = CoreDataManagers.instance
    @Published var frequencies: [Frequency] = []
    @Published var taskObjects: [TaskObject] = []
    @Published var subTasks: [SubTask] = []
    
    init() {
        getFrequencies()
        getTaskObjects()
        getSubTasks()
    }
    
    func getFrequencies() {
        let request = NSFetchRequest<Frequency>(entityName: "Frequency")
        
        do {
            frequencies = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func getTaskObjects() {
        let request = NSFetchRequest<TaskObject>(entityName: "TaskObject")
        
        do {
            taskObjects = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func getSubTasks() {
        let request = NSFetchRequest<SubTask>(entityName: "SubTask")
        
        do {
            subTasks = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func addFrequency() {
        let newFrequency = Frequency(context: manager.context)
        newFrequency.name = "Daily"
        save()
    }
    
    func addTaskObject() {
        let newTaskObject = TaskObject(context: manager.context)
        newTaskObject.mainTask = "NEW"
        newTaskObject.isComplete = false
        newTaskObject.dateCreated = Date()
        newTaskObject.category = "TESSST"
        
        newTaskObject.frequency = frequencies[0]
        save()
    }
    
    func addSubTask() {
        getTaskObjects() // Doesnt work like I want
        getFrequencies()
        let newSubTask = SubTask(context: manager.context)
        newSubTask.name = "aadadada"
        newSubTask.isComplete = false
        
        newSubTask.taskObject = taskObjects[0]
        newSubTask.frequency = frequencies[0]
        save()
    }
    
    func addFirstObject() {
        getFrequencies()
        getSubTasks()
        let newTaskObject = TaskObject(context: manager.context)
        newTaskObject.mainTask = "Take out trash"
        newTaskObject.isComplete = false
        newTaskObject.dateCreated = Date()
        newTaskObject.category = "Shores"
        
        newTaskObject.frequency = frequencies[0]
        
        newTaskObject.addToSubTasks(subTasks[2])
        save()
    }
    
    func addFirstSubTask() {
        let newSubObject = SubTask(context: manager.context)
        newSubObject.name = "SideQuest"
        newSubObject.isComplete = false
        
        newSubObject.taskObject = taskObjects[0]
        newSubObject.frequency = frequencies[0]
        save()
    }
    
    func addTest() {
        let newSubObject = SubTask(context: manager.context)
        newSubObject.name = "SideQuest"
        newSubObject.isComplete = false
        
        save()
        getFrequencies()
        getTaskObjects()
        getSubTasks()
        let newTaskObject = TaskObject(context: manager.context)
        newTaskObject.mainTask = "Take out trash"
        newTaskObject.isComplete = false
        newTaskObject.dateCreated = Date()
        newTaskObject.category = "Shores"
        
        newTaskObject.frequency = frequencies[0]
        
        newTaskObject.addToSubTasks(subTasks[0])
        save()
    }
    // 7,4
    
    
    func save() {
        frequencies.removeAll()
        taskObjects.removeAll()
        subTasks.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.manager.save()
            self.getFrequencies()
            self.getTaskObjects()
            self.getSubTasks()
        }
    }
}
struct CoreDataRelationships: View {
    
    @StateObject var vm = CoreDataRelationshipViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Button(action: {
                        vm.addTaskObject()
                        vm.addSubTask()
                    }, label: {
                        Text("Button")
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.cornerRadius(10))
                    })
                    ScrollView(.horizontal, showsIndicators: true, content: {
                        HStack(alignment: .top) {
                            ForEach(vm.frequencies) { frequency in
                                FrequencyView(entity: frequency)
                            }
                        }
                    })
                    
                    ScrollView(.horizontal, showsIndicators: true, content: {
                        HStack(alignment: .top) {
                            ForEach(vm.taskObjects) { object in
                                TaskObjectView(entity: object)
                            }
                        }
                    })
                    
                    ScrollView(.horizontal, showsIndicators: true, content: {
                        HStack(alignment: .top) {
                            ForEach(vm.subTasks) { task in
                                SubTaskView(entity: task)
                            }
                        }
                    })
                }
            }
        }
    }
}

struct CoreDataRelationships_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataRelationships()
    }
}


struct FrequencyView: View {
    
    let entity: Frequency
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Frequency: \(entity.name ?? "")")
                .bold()
            
            if let taskObjects = entity.taskObjects?.allObjects as? [TaskObject] {
                Text("TaskObjects:")
                    .bold()
                ForEach(taskObjects) { object in
                    Text(object.category ?? "")
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct TaskObjectView: View {
    
    let entity: TaskObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("MainTask: \(entity.mainTask ?? "")")
                .bold()
            Text("Category: \(entity.category ?? "")")
                .bold()
            if entity.isComplete {
                Text("Is completed: True")
            } else {
                Text("Is completed: False")
            }
            Text("Date Created: \(entity.dateCreated ?? Date())")
            
            Text("Frequency: ")
                .bold()
            Text(entity.frequency?.name ?? "")
            
            if let subTasks = entity.subTasks?.allObjects as? [SubTask] {
                Text("SubTasks: ")
                    .bold()
                ForEach(subTasks) { subTask in
                    Text(subTask.name ?? "")
                    if subTask.isComplete {
                        Text("Is completed: True")
                    } else {
                        Text("Is completed: False")
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.green.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct SubTaskView: View {
    
    let entity: SubTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SubTask Name: \(entity.name ?? "")")
                .bold()
            
            if entity.isComplete {
                Text("Is completed: True")
            } else {
                Text("Is completed: False")
            }
            
            Text("Frequency: ")
                .bold()
            Text(entity.frequency?.name ?? "")
            
            Text("Connected to maintask: ")
                .bold()
            Text(entity.taskObject?.mainTask ?? "")
        }
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.blue.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
