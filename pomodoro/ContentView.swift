//
//  ContentView.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 19.02.2021.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \Task.timestamp, ascending: false),
        ],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    func saveData() {
        do {
          try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    var body: some View {
        NavigationView {
                List {
                    ForEach(tasks) { task in
                        TaskView(task: task)
                }
                .onDelete(perform: deleteTasks)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                            saveData()

                        }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                  #if os(iOS)
                  EditButton()
                  #endif
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                  Button(action: addTask) {
                      Label("Add Item", systemImage: "plus")
                  }
                }
            }
        }
    }
    
    struct TaskView: View {
        var task: Task
        
        @State private var completeTask = false
        @State private var runTask = false

        var body: some View {
            VStack(alignment: .leading) {
                TaskDetails(task: task)
                HStack {
                    if !completeTask && !task.isCompleted {
                        Button(action: {
                            runTask.toggle()
                        }) {
                            Text("Run")
                                .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(40)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                        Button(action: {
                            withAnimation {
                                runTask = false
                                task.isCompleted = true
                                completeTask.toggle()
                            }
                        }) {
                            Text("Complete")
                                .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.red]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(40)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    } else {
                        Spacer()
                        Text("COMPLETED").frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding()
                            .foregroundColor(Color.white)
                    }
                }
            }.fullScreenCover(isPresented: $runTask) {
                CurrentTaskView(task: task)
            }.background((!completeTask && !task.isCompleted) ?
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white]), startPoint: .leading, endPoint: .trailing):
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing))
            .opacity((!completeTask && !task.isCompleted) ? 1.0: 0.8).cornerRadius(5)
        }
    }

    private func addTask() {
        withAnimation {
            PomodoroTimer.allowNotifications()
            let newTask = Task(context: viewContext)
            newTask.timestamp = Date()
            newTask.name = "_New task_"
            newTask.spoiledPomodoros = Int64(0)
            newTask.completedPomodoros = Int64(0)
            newTask.isCompleted = false
            self.saveData()
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
            self.saveData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
