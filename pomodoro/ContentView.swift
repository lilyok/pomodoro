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

    @State private var searchTask = ""
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
            // TODO adviser
            Adviser()
                .tabItem {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Task Adviser")
                }
            NavigationView {
                VStack(alignment: .leading) {
                    SearchBar(gapText: "Search a task...", text: $searchTask).padding(.top, 4)
                    List {
                        ForEach(tasks.filter({searchTask.isEmpty ? true : (($0.name ?? "_New task_") == "_New task_" ? "                      " : $0.name! ).lowercased().contains(searchTask.lowercased())})) { task in
                            VStack(alignment: .leading) {
                                TaskView(task: task, settings: settings)
                            }
                        }
                        .onDelete(perform: deleteTasks)
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                            saveData()
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
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
        }
    }
    
    func actionSheet() {
        let img = takeScreenshot()
        showShareActivity(msg:nil, image: img, url: nil, sourceRect: nil)
    }
    
    func takeScreenshot() -> UIImage?{
        
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.windows.first { $0.isKeyWindow }!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
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

func topViewController()-> UIViewController{
    var topViewController:UIViewController = UIApplication.shared.windows.first { $0.isKeyWindow }!.rootViewController!
    
    while ((topViewController.presentedViewController) != nil) {
        topViewController = topViewController.presentedViewController!;
    }
    
    return topViewController
}

func showShareActivity(msg:String?, image:UIImage?, url:String?, sourceRect:CGRect?){
    var objectsToShare = [AnyObject]()
    
    if let url = url {
        objectsToShare = [url as AnyObject]
    }
    
    if let image = image {
        objectsToShare = [image as AnyObject]
    }
    
    if let msg = msg {
        objectsToShare = [msg as AnyObject]
    }
    
    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
    activityVC.modalPresentationStyle = .popover
    activityVC.popoverPresentationController?.sourceView = topViewController().view
    if let sourceRect = sourceRect {
        activityVC.popoverPresentationController?.sourceRect = sourceRect
    }
    
    topViewController().present(activityVC, animated: true, completion: nil)
}
