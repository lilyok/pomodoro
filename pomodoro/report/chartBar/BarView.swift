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
    var barColor: Color = Color.blue
    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule().frame(height: value)
                .foregroundColor(fgColor)
            Capsule().frame(height: value)
                .foregroundColor(barColor)
            Capsule().frame(height: value)
                .foregroundColor(barColor)
            Capsule().frame(height: value)
                .foregroundColor(barColor)
            Capsule().frame(height: value)
                .foregroundColor(barColor)
            Text(text).rotationEffect(Angle(degrees: -90)).foregroundColor(.white).frame(minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: value, maxHeight: value, alignment: .center).font(.system(size: 16)).padding(-5)
        }
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 2){
//            BarView(value: 100, text: "mon", barColor: Color.red)
//            BarView(value: 150, text: "tue", barColor: Color.red)
//            BarView(value: 140, text: "wen", barColor: Color.red)
//            BarView(value: 100, text: "thu", barColor: Color.red)
//            BarView(value: 100, text: "fri", barColor: Color.red)
//            BarView(value: 100, text: "sat", barColor: Color.red)
//            BarView(value: 100, text: "sun", barColor: Color.red)
            BarView(value: 150, text: "12:00am\n4:00am")
            BarView(value: 150, text: "4:00am\n8:00am")
            BarView(value: 150, text: "8:00am\n12:00pm")
            BarView(value: 150, text: "12:00pm\n04:00pm")
            BarView(value: 150, text: "12:00pm\n04:00pm")
            BarView(value: 150, text: "08:00pm\n12:00am")
        }.padding()
    }
}
