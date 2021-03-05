//
//  PomodoroTimer.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 03.03.2021.
//

import UserNotifications


class PomodoroTimer {
    public var timerType: String = TimerType.pomodoro
    public var timeRemaining: Int? = Constants.pomodoroTime
    private var isRun: Bool = true
    
    init() {
        self.setAllNotifications()
    }
    
    private func createNotification(index: Int, timerType: String, currentDate: Date, isBreak: Bool = false) -> Date {
        let identifier = String(index) + timerType
        let interval: Double = getTimeByType(timerType: timerType, isBreak: isBreak)
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        content.title = isBreak ? "timer has interrupted" : "\(timerType) is over"
        content.subtitle = isBreak ? "would you like to start new pomodoro?" : (timerType == TimerType.pomodoro ? "break has started" : "new pomodoro has started")

        let currentDate = currentDate.addingTimeInterval(interval + 1)
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        return currentDate
    }
    
    private func setAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let maxNumber: Int = Constants.maxPomodorosNumber / 2 / (Constants.shortBreakTimeNumber + 1)

        var currentDate = Date()
        
        var curIndex = 0
        for _ in 1...maxNumber{
            for i in 1...Constants.shortBreakTimeNumber + 1 {
                currentDate = createNotification(index: 1000 + curIndex, timerType: TimerType.pomodoro, currentDate: currentDate)
                currentDate = createNotification(index: 1000 + curIndex + 1, timerType: i == Constants.shortBreakTimeNumber + 1 ? TimerType.longBreak : TimerType.shortBreak, currentDate: currentDate)
                curIndex += 2
            }
        }
    }

    public static func allowNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func isTimerType(requestId: String, timerType: String) -> Bool {
        return (timerType == requestId.suffix(timerType.count))
    }

    
    private func getTimerType(requestId: String) -> String {
        for timerType in [TimerType.pomodoro, TimerType.shortBreak, TimerType.longBreak] {
            if isTimerType(requestId: requestId, timerType: timerType) {
                return timerType
            }
        }
        return ""
    }
    
    private func getTimeByType(timerType: String, isBreak: Bool=false) -> Double {
        if isBreak {
            return 0.1
        } else if timerType == TimerType.pomodoro {
            return TimeInterval(Constants.pomodoroTime)
        } else if timerType == TimerType.shortBreak {
            return TimeInterval(Constants.shortBreakTime)
        } else if timerType == TimerType.longBreak {
            return TimeInterval(Constants.longBreakTime)
        }
        return 0
    }

    public func getTimeRemaining() -> Int? {
        let currentDate = Date()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            if self.isRun && requests.count == 0 {
                self.setAllNotifications()
            }
            for request in requests.sorted(by: { $0.identifier < $1.identifier } ) {
                self.timerType = self.getTimerType(requestId: request.identifier)
                
                let localTrigger = request.trigger  as! UNCalendarNotificationTrigger
                let date = localTrigger.nextTriggerDate()

                let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate, to: date ?? currentDate)
                let s = diffs.second ?? 0
                let m = diffs.minute ?? 0
                let h = diffs.hour ?? 0
                let summary = s + m * 60 + h * 3600
                if (diffs.year ?? 0 > 0 || diffs.month ?? 0 > 0 || diffs.day ?? 0 > 0 || (summary > Int(self.getTimeByType(timerType: self.timerType)))) {
                    continue
                } else {
                    self.timeRemaining  = summary
                    return
                }
            }
        })
        return self.timeRemaining
    }
    
    public func stopTimer() {
        self.isRun = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        _ = createNotification(index: 0, timerType: "", currentDate: Date(), isBreak: true)
    }
}
