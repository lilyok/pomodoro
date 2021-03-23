//
//  Charts.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 16.03.2021.
//

import SwiftUI

struct ChartsView: View {
    @State private var pickerSelectedItem = 0
    @State private var dataPoints: [[PomodoroStatistics]] = [
        PomodoroStatistics.loadStatisticsSettings(isNormalized: true),
        PomodoroStatistics.loadStatisticsSettings(key: "HourlyStatisticsSettings", isNormalized: true)
    ]
    
    let lables = [["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"],
                  ["12:00am - 03:59am", "04:00am - 07:59am", "08:00am - 11:59am",
                   "12:00pm - 03:59pm", "04:00pm - 07:59pm", "08:00pm - 11:59pm"]]

    var body: some View {
        ZStack {
            VStack {
                Text("The most productive time to work for you")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("(based on counting your finished pomodoros)")
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Picker(selection: $pickerSelectedItem, label: Text("")) {
                    Text("WeekDays").tag(0)
                    Text("Hours").tag(1)
                }.pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                ZStack {
                    Rectangle().frame(height: 200)
                        .foregroundColor(.black)
                    HStack(spacing: 2) {
                        ForEach(0..<dataPoints[pickerSelectedItem].count, id: \.self) {i in
                            BarView(value: CGFloat(dataPoints[pickerSelectedItem][i].meanCompletedPomodoros), text: lables[pickerSelectedItem][i]).animation(.easeInOut)
                        }
                    }
                }.padding(.horizontal, 24)
            }
        }.onAppear() {
            dataPoints = [
                PomodoroStatistics.loadStatisticsSettings(isNormalized: true),
                PomodoroStatistics.loadStatisticsSettings(key: "HourlyStatisticsSettings", isNormalized: true)
            ]
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
static var previews: some View {
    ChartsView()
  }
}
