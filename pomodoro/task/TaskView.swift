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
            PomodoroButtons(task: task, isColored: true, completeTask: $completeTask, runTask: $runTask, isNewTimer: $isNewTimer).padding(2)
        }.fullScreenCover(isPresented: $runTask) {
            CurrentTaskView(task: task, settings: settings, isNewTimer: isNewTimer)
        }.background((!completeTask && !task.isCompleted) ?
                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.clear]), startPoint: .leading, endPoint: .trailing):
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing))
        .opacity((!completeTask && !task.isCompleted) ? 1.0: 0.8).cornerRadius(5)
        .onReceive(timer) { _ in
            if !isNewTimer {
                self.runTask = isTaskRunning(name: task.name, timestamp: task.timestamp)
            }
            isNewTimer = false
            timer.upstream.connect().cancel()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isNewTimer = false
        }
    }
}
