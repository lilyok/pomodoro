//
//  TaskDetails.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 03.03.2021.
//

import SwiftUI


struct TaskDetails: View {
    @State private var name: String = ""
    @ObservedObject var task: Task
    var isRun: Bool = false
    var timerType: String = ""

    var body: some View {
        HStack {
            Text("Task name: ")
                .font(.title2)
                .foregroundColor(isRun ? .secondary : (task.isCompleted ? Color.white : .primary))
            ZStack(alignment: .leading) {
                if name.isEmpty {
                    if self.task.name == nil || self.task.name == "_New task_" {
                        Text("Type here task name").foregroundColor(task.isCompleted ? Color.white : .secondary)
                    } else {
                        Text("\(self.task.name!)").foregroundColor(isRun ? .secondary : (task.isCompleted ? Color.white : .primary))
                    }
                }
                if !isRun {
                    TextField("", text: $name, onCommit: {
                        self.task.name = self.name
                    }).foregroundColor(task.isCompleted ? Color.white : .primary)
                    .onChange(of: name) { newValue in
                        self.task.name = name
                    }
                }
            }
        }
        HStack {
            Text("completed\npomodoros")
                .foregroundColor(isRun ? .secondary : (task.isCompleted ? Color.white : .primary))
            Text("\(task.completedPomodoros)")
                .foregroundColor(isRun ? .secondary : (task.isCompleted ? Color.white : .primary)).padding()
            Spacer()
            Text("spoiled\npomodoros")
                .foregroundColor(isRun ? .secondary : (task.isCompleted ? Color.white : .primary))
            Text("\(task.spoiledPomodoros)")
                .foregroundColor(isRun ? .secondary : (task.isCompleted ? Color.white : .primary))

            Spacer()
        }
        if isRun {
            HStack {
            Spacer()
                Text("\(timerType) in the process")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black).opacity(0.7)
                    .cornerRadius(40.0)
                Spacer()
            }
        }
    }
}
