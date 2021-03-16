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
    @State private var timeBeforeBackground: Date? = nil

    private var currentTimer: PomodoroTimer? = nil
    private var task: Task
    private let settings: PomodoroSettings

    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(task: Task, settings: PomodoroSettings, isNewTimer: Bool) {
        self.task = task
        self.settings = settings
        self.currentTimer = PomodoroTimer(taskId: "\(task.name ?? "")_\(task.timestamp ?? Date())", settings: settings, isNewTimer: isNewTimer)
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
                    self.timeRemaining = self.currentTimer!.getTimeRemaining()
                }
        }
            .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .onReceive(timer) { time in
                timeRemaining = self.currentTimer!.getTimeRemaining()
                if self.timeBeforeBackground == nil && timeRemaining == 0 && currentTimer?.timerType == TimerType.pomodoro {
                    self.task.completedPomodoros += 1
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                if currentTimer?.timerType == TimerType.pomodoro {
                    self.timeBeforeBackground = Date().addingTimeInterval(-60*Double(settings.pomodoroTime) + Double(timeRemaining!))
                } else {
                    self.timeBeforeBackground = Date().addingTimeInterval(Double(timeRemaining!))
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                if self.timeBeforeBackground != nil {
                    let currentDate = Date()
                    let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self.timeBeforeBackground!, to: currentDate )

                    let summary = diffs.second! + diffs.minute! * 60 + diffs.hour! * 3600 + diffs.day! * 3600 * 24

                    let session_duration = 60*(settings.pomodoroTime + (settings.pomodoroTime + settings.shortBreakTime) * settings.shortBreakTimeNumber)
                    let full_session_duration = 60*settings.longBreakTime + session_duration
                    
                    let full_session_pomodoros = Int64(Int(summary / full_session_duration) * (1 + settings.shortBreakTimeNumber))
                    self.task.completedPomodoros += full_session_pomodoros

                    let delta_durations = min(summary % full_session_duration, session_duration)
                    if delta_durations > settings.pomodoroTime {
                        self.task.completedPomodoros += Int64((delta_durations + settings.shortBreakTime * 60) / 60 / (settings.shortBreakTime + settings.pomodoroTime))
                    }

                    self.timeBeforeBackground = nil
                }
            }
            Spacer()
    }
}
