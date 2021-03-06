//
//  SettingsView.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 07.03.2021.
//

import SwiftUI

class PomodoroSettings: Codable {
    static let maxNotificatiosNumber = 64

    static let minPomodoroTime = 10
    static let maxPomodoroTime = 120
    static let minShortBreakTime = 1
    static let maxShortBreakTime = 60
    static let minLongBreakTime = 5
    static let maxLongBreakTime = 120
    static let minSessionsNumberBeforeLongBreak = 1
    static let maxSessionsNumberBeforeLongBreak = 10

    var pomodoroTime = 25
    var shortBreakTime = 5
    var longBreakTime = 15

    var sessionsNumberBeforeLongBreak = 3
    
    public func setSettings(pomodoroIndex: Int, shortBreakIndex: Int, longBreakIndex: Int, sessionsNumberBeforeLongBreakIndex: Int) {
        self.pomodoroTime = PomodoroSettings.minPomodoroTime + pomodoroIndex
        self.shortBreakTime = PomodoroSettings.minShortBreakTime + shortBreakIndex
        self.longBreakTime = PomodoroSettings.minLongBreakTime + longBreakIndex
        self.sessionsNumberBeforeLongBreak = PomodoroSettings.minSessionsNumberBeforeLongBreak + sessionsNumberBeforeLongBreakIndex
    }
    
    public func getPomodoroIndex() -> Int {
        return self.pomodoroTime - PomodoroSettings.minPomodoroTime
    }
    
    public func getShortBreakIndex() -> Int {
        return self.shortBreakTime - PomodoroSettings.minShortBreakTime
    }
  
    public func getLongBreakIndex() -> Int {
        return self.longBreakTime - PomodoroSettings.minLongBreakTime
    }

    public func getSessionsNumberBeforeLongBreakIndex() -> Int {
        return self.sessionsNumberBeforeLongBreak - PomodoroSettings.minSessionsNumberBeforeLongBreak
    }
    
    static public func loadPomodoroSettings() -> PomodoroSettings {
        if let savedSettings = UserDefaults.standard.object(forKey: "PomodoroSettings") as? Data {
            let decoder = JSONDecoder()
            if let loadedSettings = try? decoder.decode(PomodoroSettings.self, from: savedSettings) {
                return loadedSettings
            }
        }
        return PomodoroSettings()
    }
    
    public func savePomodoroSettings() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "PomodoroSettings")
        }
    }
}


struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var pomodoroIndex = 15
    @State private var shortBreakIndex = 4
    @State private var longBreakIndex = 5
    @State private var sessionsNumberBeforeLongBreakIndex = 2
    
    var settings: PomodoroSettings

    init(settings: PomodoroSettings) {
        self.settings = settings
    }

    var body: some View {
        NavigationView {
            Form {
                Picker("Pomodoro session:", selection: $pomodoroIndex) {
                    ForEach(PomodoroSettings.minPomodoroTime ..< PomodoroSettings.maxPomodoroTime + 1) {
                        Text("\(secondsToHoursMinutesSeconds(seconds: $0 * 60))")
                    }
                }
                Picker("Short break:", selection: $shortBreakIndex) {
                    ForEach(PomodoroSettings.minShortBreakTime ..< PomodoroSettings.maxShortBreakTime + 1) {
                        Text("\(secondsToHoursMinutesSeconds(seconds: $0 * 60))")
                    }
                }
                Picker("Long break:", selection: $longBreakIndex) {
                    ForEach(PomodoroSettings.minLongBreakTime ..< PomodoroSettings.maxLongBreakTime + 1) {
                        Text("\(secondsToHoursMinutesSeconds(seconds: $0 * 60))")
                    }
                }
                Picker("Long break after:", selection: $sessionsNumberBeforeLongBreakIndex) {
                    ForEach(PomodoroSettings.minSessionsNumberBeforeLongBreak ..< PomodoroSettings.maxSessionsNumberBeforeLongBreak + 1) {
                        Text("\($0) sessions")
                    }
                }
            }
        }.onAppear {
            self.pomodoroIndex = settings.getPomodoroIndex()
            self.shortBreakIndex = settings.getShortBreakIndex()
            self.longBreakIndex = settings.getLongBreakIndex()
            self.sessionsNumberBeforeLongBreakIndex = settings.getSessionsNumberBeforeLongBreakIndex()
        }
        HStack {
            Spacer()
            Button(action: {
                settings.setSettings(pomodoroIndex: pomodoroIndex, shortBreakIndex: shortBreakIndex, longBreakIndex: longBreakIndex, sessionsNumberBeforeLongBreakIndex: sessionsNumberBeforeLongBreakIndex)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(40)
            }
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Color.red)
                    .cornerRadius(40)
            }
            Spacer()
        }
    }
}
