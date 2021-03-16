//
//  Charts.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 16.03.2021.
//

import SwiftUI

struct ChartsView: View {
    @State private var pickerSelectedItem = 0
    @State private var dataPoints: [[CGFloat]] = [
        [100, 120, 150],
        [150, 100, 120],
        [120, 150, 100],
        [120, 100, 150],
        [130, 50, 100]
    ]
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
                    Text("Daily").tag(0)
                    Text("Weekly").tag(1)
                    Text("Monthly").tag(2)
                    Text("Yearly").tag(3)
                }.pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                HStack(spacing: 1) {
                    BarView(value: dataPoints[pickerSelectedItem][0], text: "12:00am\n4:00am")
                    BarView(value: dataPoints[pickerSelectedItem][1], text: "4:00am\n8:00am")
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "8:00am\n12:00pm")
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "12:00pm\n04:00pm")
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "12:00pm\n04:00pm")
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "08:00pm\n12:00am")
                }.padding()//.padding(.top, 24)
                .animation(.default)

                Picker(selection: $pickerSelectedItem, label: Text("")) {
                    Text("Weekly").tag(1)
                    Text("Monthly").tag(2)
                    Text("Yearly").tag(3)
                }.pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 1)
                HStack(spacing: 12) {
                    BarView(value: dataPoints[pickerSelectedItem][0], text: "mon", barColor: Color.red)
                    BarView(value: dataPoints[pickerSelectedItem][1], text: "tue", barColor: Color.red)
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "wen", barColor: Color.red)
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "thu", barColor: Color.red)
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "fri", barColor: Color.red)
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "sat", barColor: Color.red)
                    BarView(value: dataPoints[pickerSelectedItem][2], text: "sun", barColor: Color.red)
                }.padding()//.padding(.top, 24)
                .animation(.default)
            }
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
static var previews: some View {
    ChartsView()
  }
}
