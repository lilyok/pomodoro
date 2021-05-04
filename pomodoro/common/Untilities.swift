//
//  Untilities.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 03.03.2021.
//

import SwiftUI

struct TimerType {
    static let pomodoro = "pomodoro"
    static let shortBreak = "short break"
    static let longBreak = "long break"
}

func secondsToHoursMinutesSeconds (seconds : Int) -> String {
    if seconds < 0{
        return "..."
    }
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = (seconds % 3600) % 60
    var result = ""
    if h > 0 {
        result += "\(h) Hours"
    }
    if m > 0 {
        result += (h > 0 ? ", \(m) Minutes" : "\(m) Minutes")
    }
    if s > 0 {
        result += (h > 0 || m > 0 ? ", \(s) Seconds" : "\(s) Seconds")
    }
    return result
}

func isTaskRunning(name: String?, timestamp: Date?) -> Bool {
    let TasksStatus = UserDefaults.standard.object(forKey: "TaskSettings") as? [String:Bool] ?? [:]
    let key = "\(name ?? "")_\(timestamp ?? Date())"
    return TasksStatus[key] != nil ? TasksStatus[key]! : false
}

