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

    init(task: Task, settings: PomodoroSettings, isNewTimer: Bool) {
        self.task = task
        self.settings = settings
        self.currentTimer = PomodoroTimer(taskId: self.createStrTaskId(), settings: settings, isNewTimer: isNewTimer)
        saveTaskTimeSettings()
    }

    var body: some View {
        Spacer()
        TaskDetails(task: task, isRun: true, timerType: currentTimer!.timerType)
        Button(action: {
                currentTimer!.stopTimer()
                if currentTimer?.timerType == TimerType.pomodoro {
                    self.task.spoiledPomodoros += 1
                }
            saveTaskTimeSettings(isStart: false)
                presentationMode.wrappedValue.dismiss()
        }) {
            Text("time remaining: \(secondsToHoursMinutesSeconds(seconds:  self.timeRemaining ?? 0))")
                .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white).padding(.horizontal, 20).padding(.vertical, 5)
                .onAppear(){
                    self.timeRemaining = self.currentTimer!.getTimeRemaining()
                    calculateMeasures()
                }
        }
            .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .onReceive(timer) { time in
                timeRemaining = self.currentTimer!.getTimeRemaining()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                calculateMeasures()
            }
            Spacer()
    }
    
    private func calculateMeasures() {
        let initTime = UserDefaults.standard.object(forKey: "InitTaskTime") as? Date ?? nil
        if initTime != nil {
            var initCompletedPomodoros = UserDefaults.standard.object(forKey: "InitCompletedPomodoros") as! Int64

            let currentDate = Date()
            let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: initTime!, to: currentDate )

            let summary = diffs.second! + diffs.minute! * 60 + diffs.hour! * 3600 + diffs.day! * 3600 * 24

            let session_duration = 60*(settings.pomodoroTime + (settings.pomodoroTime + settings.shortBreakTime) * settings.shortBreakTimeNumber)
            let full_session_duration = 60*settings.longBreakTime + session_duration
            
            let full_session_pomodoros = Int64(Int(summary / full_session_duration) * (1 + settings.shortBreakTimeNumber))
            initCompletedPomodoros += full_session_pomodoros
            print(initTime!, currentDate, initCompletedPomodoros, full_session_pomodoros, self.task.completedPomodoros)

            let delta_durations = min(summary % full_session_duration, session_duration)
            print(delta_durations, (delta_durations + settings.shortBreakTime * 60) / 60 , settings.shortBreakTime + settings.pomodoroTime)

            if delta_durations > settings.pomodoroTime {
                initCompletedPomodoros += Int64((delta_durations + settings.shortBreakTime * 60) / 60 / (settings.shortBreakTime + settings.pomodoroTime))
            }
            self.task.completedPomodoros = initCompletedPomodoros
        }
    }

    private func saveTaskTimeSettings(isStart: Bool = true) {
        if !isStart {
            UserDefaults.standard.removeObject(forKey: "InitTaskTime")
            UserDefaults.standard.removeObject(forKey: "InitCompletedPomodoros")
            return
        }
        if UserDefaults.standard.object(forKey: "InitTaskTime") as? Date ?? nil == nil {
            UserDefaults.standard.set(Date(), forKey: "InitTaskTime")
            UserDefaults.standard.set(task.completedPomodoros, forKey: "InitCompletedPomodoros")
        }
    }


//    private func saveStatisticsSettings() {
//        let weekday = Calendar.current.component(.weekday, from: Date())
//        let userDefaults = UserDefaults.standard
//        var settings = userDefaults.object(forKey: "WeekDailyStatisticsSettings") as? [String:Int64] ?? [:]
//        settings[String(weekday)] = self.task.completedPomodoros
//        userDefaults.set(settings, forKey: "WeekDailyStatisticsSettings")
//    }
    
    private func createStrTaskId() -> String {
        return "\(task.name ?? "")_\(task.timestamp ?? Date())"
    }
}
