//
//  Untilities.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 03.03.2021.
//

struct Constants {
    static let maxPomodorosNumber = 64
    
    static let pomodoroTime = 10//25 * 60
    static let shortBreakTime = 3//5 * 60
    static let longBreakTime = 5//15 * 60
//    static let pomodoroTime = 25 * 60
//    static let shortBreakTime = 5 * 60
//    static let longBreakTime = 15 * 60

    static let shortBreakTimeNumber = 3
}

struct TimerType {
    static let pomodoro = "pomodoro"
    static let shortBreak = "short break"
    static let longBreak = "long break"
}


func secondsToHoursMinutesSeconds (seconds : Int) -> String {
    let h = seconds / 3600
    let m = (seconds % 3600) / 60
    let s = (seconds % 3600) % 60
    if h > 0 { return ("\(h) Hours, \(m) Minutes, \(s) Seconds") }
    if m > 0 { return ("\(m) Minutes, \(s) Seconds") }
    return ("\(s) Seconds")
}
