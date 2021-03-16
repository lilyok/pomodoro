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
    private var settings: PomodoroSettings
    
    @State private var openSettings = false
    
    init() {
        self.settings = PomodoroSettings.loadPomodoroSettings()
    }
    
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
        TabView {
            NavigationView {
                List {
                    ForEach(tasks) { task in
                        TaskView(task: task, settings: settings)
                    }
                    .onDelete(perform: deleteTasks)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        saveData()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            openSettings.toggle()
                            
                        }) {
                            Label("Settings", systemImage: "gearshape")
                        }.fullScreenCover(isPresented: $openSettings) {
                            SettingsView(settings: settings).onDisappear(){
                                self.settings.savePomodoroSettings()
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addTask) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "timer")
                Text("Pomodoro")
            }
            NavigationView {
                ChartsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: actionSheet) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)
                            }                        }
                    }
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Statistics")
            }
            // TODO recommendator
            //            Text("Search presets for your goal")
            //                .tabItem {
            //                    Image(systemName: "doc.text.magnifyingglass")
            //                    Text("Tasks Presets")
            //            }
        }
        }
        
        func actionSheet() {
            guard let data = URL(string: "https://www.zoho.com") else { return }
            let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
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
