//
//  BarView.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 16.03.2021.
//

import SwiftUI
//min 50
struct BarView: View {
    var value: CGFloat = 0
    var text: String = ""
    var fgColor: Color = Color.black
    var barColor: Color = Color.red
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle().frame(height: value)
                    .foregroundColor(fgColor)
                Rectangle().frame(height: value)
                    .foregroundColor(barColor)
                Rectangle().frame(height: value)
                    .foregroundColor(barColor)
                Rectangle().frame(height: value)
                    .foregroundColor(barColor)
                Rectangle().frame(height: value)
                    .foregroundColor(barColor)
                Text(text).foregroundColor(.white).rotationEffect(.degrees(-90))
                    .fixedSize()
                    .frame(width: 20, height: 180, alignment: .center)
            }.frame(minHeight: 200, alignment: .bottom)
        }
    }
}

struct BarView_Previews: PreviewProvider {

    static var previews: some View {
        
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
//                Picker(selection: $pickerSelectedItem, label: Text("")) {
//                    Text("WeekDays").tag(0)
//                    Text("Hours").tag(1)
//                }.pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                HStack(spacing: 2) {
                    BarView(value: 1, text: "12:00am-04:00am")
                    BarView(value: 1, text: "12:00am-04:00am")
                    BarView(value: 100, text: "12:00am-04:00am")
                    BarView(value: 10, text: "12:00am-04:00am")
                    BarView(value: 0, text: "12:00am-04:00am")

                    BarView(value: 200, text: "12:00am-04:00am")
                }.padding()
                .animation(.default)
            }
        }
    }
}
