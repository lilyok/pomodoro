//
//  PomodoroTimer.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 03.03.2021.
//

import UserNotifications


class PomodoroTimer {
    public var timerType: String = TimerType.pomodoro
    public var timeRemaining: Int? = nil
    private var isRun: Bool = true
    private let settings: PomodoroSettings
    private var taskId: String
    
    init(taskId: String, settings: PomodoroSettings, isNewTimer: Bool) {
        self.taskId = taskId
        self.settings = settings
        self.timeRemaining = settings.pomodoroTime * 60
        let plannedNumber = UserDefaults.standard.value(forKey:"plannedNumber") as? Int ?? 0

        if isNewTimer && plannedNumber == 0 {
            self.setAllNotifications(maxNumber: PomodoroSettings.maxNotificatiosNumber / settings.sessionsNumberBeforeLongBreak / 2)
        } else {
            self.timeRemaining = getTimeRemaining()
        }
        saveTaskSettings()
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

        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
            let userDefaults = UserDefaults.standard
            let plannedNumber = UserDefaults.standard.value(forKey:"plannedNumber") as? Int ?? 0
            if (plannedNumber > 0) {
                userDefaults.set(plannedNumber - 1, forKey: "plannedNumber")
            }
        }
        return currentDate
    }
    
    private func setAllNotifications(maxNumber: Int, isAdditionalRequests: Bool = false) {
        if !isAdditionalRequests {
            clearAll()
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(maxNumber * 2 * settings.sessionsNumberBeforeLongBreak, forKey: "plannedNumber")
        let initDate = userDefaults.object(forKey: "lastNotificationDate") as? Date ?? nil
        let initIndex = userDefaults.object(forKey: "lastNotificationIndex") as? Int ?? nil

        var currentDate = initDate != nil ? initDate! : Date()
        var currentIndex = initIndex != nil ? initIndex! : 1000

        var curIndex = 0
        for _ in 1...maxNumber{
            for i in 1...settings.sessionsNumberBeforeLongBreak {
                currentDate = createNotification(index: currentIndex + curIndex, timerType: TimerType.pomodoro, currentDate: currentDate)
                currentDate = createNotification(index: currentIndex + curIndex + 1, timerType: i == settings.sessionsNumberBeforeLongBreak ? TimerType.longBreak : TimerType.shortBreak, currentDate: currentDate)
                curIndex += 2
            }
        }
        currentIndex += curIndex
        userDefaults.set(currentDate, forKey: "lastNotificationDate")
        userDefaults.set(currentIndex, forKey: "lastNotificationIndex")
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
            return TimeInterval(settings.pomodoroTime * 60)
        } else if timerType == TimerType.shortBreak {
            return TimeInterval(settings.shortBreakTime * 60)
        } else if timerType == TimerType.longBreak {
            return TimeInterval(settings.longBreakTime * 60)
        }
        return 0
    }

    public func getTimeRemaining() -> Int? {
        let currentDate = Date()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            let freeSessionsCount = (PomodoroSettings.maxNotificatiosNumber - requests.count) / self.settings.sessionsNumberBeforeLongBreak / 2
            let plannedNumber = UserDefaults.standard.value(forKey:"plannedNumber") as? Int ?? 0
            
            if self.isRun && freeSessionsCount > 0 && plannedNumber == 0 {
                self.setAllNotifications(maxNumber: freeSessionsCount, isAdditionalRequests: true)
            }
            for request in requests.sorted(by: { $0.identifier < $1.identifier } ) {
                self.timerType = self.getTimerType(requestId: request.identifier)
                
                let localTrigger = request.trigger  as! UNCalendarNotificationTrigger
                let date = localTrigger.nextTriggerDate()
                if date == nil {
                    continue
                }
                let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate, to: date ?? currentDate)
                let s = diffs.second ?? 0
                let m = diffs.minute ?? 0
                let h = diffs.hour ?? 0
                let summary = s + m * 60 + h * 3600
                if (diffs.year ?? 0 > 0 || diffs.month ?? 0 > 0 || diffs.day ?? 0 > 0 || (summary > Int(self.getTimeByType(timerType: self.timerType)))) {
                    continue
                } else {
                    self.timeRemaining = summary
                    return
                }
            }
        })
        return self.timeRemaining
    }
    
    private func clearAll() {
        UserDefaults.standard.removeObject(forKey: "lastNotificationDate")
        UserDefaults.standard.removeObject(forKey: "lastNotificationIndex")
        UserDefaults.standard.removeObject(forKey: "plannedNumber")
        UserDefaults.standard.removeObject(forKey: "TaskSettings")

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

    }
    public func stopTimer() {
        clearAll()
        self.isRun = false
        saveTaskSettings()
        let userDefaults = UserDefaults.standard
        userDefaults.set(1, forKey: "plannedNumber")
        _ = createNotification(index: 0, timerType: "", currentDate: Date(), isBreak: true)
    }
    
    private func saveTaskSettings() {
        let userDefaults = UserDefaults.standard
        var settings = userDefaults.object(forKey: "TaskSettings") as? [String:Bool] ?? [:]
        settings[taskId] = isRun
        userDefaults.set(settings, forKey: "TaskSettings")
    }

//    private func tmpPrint() {
//        let plannedNumber = UserDefaults.standard.value(forKey:"plannedNumber") as? Int ?? 0
//        print("plannedNumber", plannedNumber)
//    }
}
