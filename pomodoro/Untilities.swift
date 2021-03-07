//
//  Untilities.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 03.03.2021.
//

struct TimerType {
    static let pomodoro = "pomodoro"
    static let shortBreak = "short break"
    static let longBreak = "long break"
}

func secondsToHoursMinutesSeconds (seconds : Int) -> String {
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
