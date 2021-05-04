//
//  TipDetails.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 04.05.2021.
//

import SwiftUI

struct TipDetails: View {
    let task: GoalTip
    let isExpanded: Bool
    
    @State private var completeTask: Bool = false
    @State private var runTask: Bool = false
    @State private var isNewTimer: Bool = false
    
    let timer = Timer.publish(every: 0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // DO NOT DELETE isNewTimer from the line below
            Label(isNewTimer ? task.name ?? "" : task.name ?? "", systemImage: "list.triangle") // DO NOT DELETE isNewTimer
                .font(.system(size: 18))
                .padding()
                .frame(minHeight: 50)
                .foregroundColor(.black)
                .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                .background(Color.yellow)
            if isExpanded {
                ForEach((task.links?.allObjects as? [TipLink] ?? [])) { item in
                    Text(item.text!).foregroundColor(.primary).font(.system(size: 16))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                    if item.link != "" {
                        Link("Open the resource", destination: URL(string: item.link!)!)
                            .frame( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.yellow)
                            .cornerRadius(40).buttonStyle(BorderlessButtonStyle())
                    }
                    Divider().background(Color.yellow)
                }.padding(.horizontal, 7)
            }
            PomodoroButtons(task: task, isColored: false, completeTask: $completeTask, runTask: $runTask, isNewTimer: $isNewTimer).padding(2).background(Color.yellow)
            
        }.fullScreenCover(isPresented: $runTask) {
            CurrentTaskView(task: task, settings: PomodoroSettings.loadPomodoroSettings(), isNewTimer: isNewTimer)
        }.background((!completeTask && !task.isCompleted) ? Color.clear: Color.yellow)
        .opacity((!completeTask && !task.isCompleted) ? 1.0: 0.8).cornerRadius(5)
        .onReceive(timer) { _ in
            if !isNewTimer {
                self.runTask = isTaskRunning(name: task.name, timestamp: task.timestamp)
            }
            isNewTimer = false
            timer.upstream.connect().cancel()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isNewTimer = false
        }
    }
}
