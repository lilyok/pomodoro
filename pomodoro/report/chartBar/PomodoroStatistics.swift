//
//  PomodoroStatistics.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 21.03.2021.
//

import SwiftUI

class PomodoroStatistics: Codable, Hashable, Identifiable {
    static func == (lhs: PomodoroStatistics, rhs: PomodoroStatistics) -> Bool {
        return lhs.meanCompletedPomodoros < rhs.meanCompletedPomodoros
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(meanCompletedPomodoros)
    }
    
    var meanCompletedPomodoros: Double = 0
    var statisticsCount: Double = 0
    
    func calculate(completedPomodoros: Int64) {
        self.meanCompletedPomodoros = (self.meanCompletedPomodoros * statisticsCount + Double(completedPomodoros)) / (statisticsCount + 1)
        self.statisticsCount += 1
    }
    
    static public func loadStatisticsSettings(key: String = "WeekDailyStatisticsSettings", isNormalized: Bool = false) -> [PomodoroStatistics] {
        if let savedStatistics = UserDefaults.standard.object(forKey: key) as? Data {
            if let loadedStatistics = try? PropertyListDecoder().decode(Array<PomodoroStatistics>.self, from: savedStatistics) {
                if isNormalized {
                    var maxEl: Double = 0
                    for (_, element) in loadedStatistics.enumerated() {
                        if maxEl < element.meanCompletedPomodoros {
                            maxEl = element.meanCompletedPomodoros
                        }
                    }
                    maxEl = maxEl == 0 ? 1 : maxEl
                    for (index, _) in loadedStatistics.enumerated() {
                        loadedStatistics[index].meanCompletedPomodoros /= (maxEl / 200)
                    }
                }
                return loadedStatistics
            }
        }
        if key == "WeekDailyStatisticsSettings" {
            return [PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics()]
        }
        return [PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics(), PomodoroStatistics()]
    }
    
    static public func savePomodoroStatistics(statistic: [PomodoroStatistics], key: String = "WeekDailyStatisticsSettings") {
        if let encoded = try? PropertyListEncoder().encode(statistic) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    static public func calculatePartsOfTheDay(initDate: Date, completedPomodorosBySession: Int64, settings:PomodoroSettings) -> [Int] {
        var result = [0, 0, 0, 0, 0, 0]
        if completedPomodorosBySession == 0 {
            return result
        }
        let partInterval = 4  // 12am, 4am, 8am, 12pm, 4pm, 8pm
        
        var delta = DateComponents()
        var futureDate = initDate
        for i in 1...completedPomodorosBySession * 2 - 1 {
            if i % 2 == 1 {
                delta.minute = settings.pomodoroTime
                let hourMinutes = Calendar.current.dateComponents([.hour, .minute], from: futureDate)
                result[Int(hourMinutes.hour! / partInterval)] += 1
            } else if Int(i) % ((settings.shortBreakTimeNumber + 1) * 2) == 0 {
                delta.minute = settings.longBreakTime
            } else {
                delta.minute = settings.shortBreakTime
            }
            futureDate = Calendar.current.date(byAdding: delta, to: initDate)!
        }
        return result
    }
}
