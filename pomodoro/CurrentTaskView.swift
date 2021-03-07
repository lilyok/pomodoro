//
//  CurrentTaskView.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 03.03.2021.
//

import SwiftUI


struct CurrentTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var timeRemaining: Int? = nil
    private var currentTimer: PomodoroTimer? = nil
    private var task: Task
    private let settings: PomodoroSettings

    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(task: Task, settings: PomodoroSettings) {
        self.task = task
        self.settings = settings
        self.currentTimer = PomodoroTimer(settings: settings)
    }

    var body: some View {
        Spacer()
        TaskDetails(task: task, isRun: true, timerType: currentTimer!.timerType)
        Button(action: {
                currentTimer!.stopTimer()
                if currentTimer?.timerType == TimerType.pomodoro {
                    self.task.spoiledPomodoros += 1
                }
                presentationMode.wrappedValue.dismiss()
        }) {
            Text("time remaining: \(secondsToHoursMinutesSeconds(seconds:  self.timeRemaining ?? 0))")
                .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 5)
                .onAppear(){
                    self.timeRemaining = settings.pomodoroTime * 60
                }
        }
            .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .onReceive(timer) { time in
                timeRemaining = self.currentTimer!.getTimeRemaining()
                if timeRemaining == 0 && currentTimer?.timerType == TimerType.pomodoro {
                    self.task.completedPomodoros += 1
                }
            }
            Spacer()
    }
}
