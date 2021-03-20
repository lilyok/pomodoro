//
//  TaskView.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 16.03.2021.
//

import SwiftUI

struct TaskView: View {
    var task: Task
    let settings: PomodoroSettings
    
    @State private var completeTask = false
    @State private var runTask = false
    @State private var isNewTimer = false;

    let timer = Timer.publish(every: 0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading) {
            TaskDetails(task: task)
            HStack {
                if !completeTask && !task.isCompleted {
                    Button(action: {
                        isNewTimer = true
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
            CurrentTaskView(task: task, settings: settings, isNewTimer: isNewTimer)
        }.background((!completeTask && !task.isCompleted) ?
                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.clear]), startPoint: .leading, endPoint: .trailing):
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing))
        .opacity((!completeTask && !task.isCompleted) ? 1.0: 0.8).cornerRadius(5)
        .onReceive(timer) { _ in
            if !isNewTimer {
                let TasksStatus = UserDefaults.standard.object(forKey: "TaskSettings") as? [String:Bool] ?? [:]
                let key = "\(task.name ?? "")_\(task.timestamp ?? Date())"
                self.runTask = TasksStatus[key] != nil ? TasksStatus[key]! : false
            }
            timer.upstream.connect().cancel()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isNewTimer = false
        }
    }
}
