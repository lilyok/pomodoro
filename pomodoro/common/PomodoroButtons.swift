//
//  PomodoroButtons.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 04.05.2021.
//

import SwiftUI


struct PomodoroButtons: View {
    let task: Task
    let isColored: Bool

    @Binding var completeTask: Bool
    @Binding var runTask: Bool
    @Binding var isNewTimer: Bool

    var body: some View {
        HStack {
            if !completeTask && !task.isCompleted {
                Button(action: {
                    isNewTimer = true
                    runTask.toggle()
                }) {
                    Text("Run")
                        .frame(minWidth: 10, idealWidth: 50, maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(
                            isColored ?
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(40)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                Button(action: {
                    withAnimation {
                        runTask = false
                        task.isCompleted = true
                        completeTask.toggle()
                    }
                }) {
                    Text("Complete")
                        .frame(minWidth: 10, idealWidth: 50, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(
                            isColored ?
                            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.red]), startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(40)
                }
                .buttonStyle(BorderlessButtonStyle())
            } else {
                Spacer()
                Button(action: {
                    withAnimation {
                        task.isCompleted = false
                        completeTask.toggle()
                    }
                }) {
                    Text("COMPLETED").frame(minWidth: 10, idealWidth: 50, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                }
            }
        }
    }
}
