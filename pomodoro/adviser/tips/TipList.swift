//
//  TipList.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 04.05.2021.
//

import SwiftUI

struct TipList: View {
    let title: String
    let plan: [GoalTip]
    
    @State private var isExpanded: Bool = false
    @State private var selection: String = ""
    
    private func selectDeselect(_ title: String) {
        selection = selection == title ? "" : title
    }
    
    var body: some View {
        VStack{
            VStack{
                Text(title).font(.system(size: 20))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                    .padding(15)
                VStack {
                    Button(action: {isExpanded.toggle()}) {
                        Label("Show Tips", systemImage: "list.triangle").frame(maxWidth: .infinity)
                    }.buttonStyle(BorderlessButtonStyle()).frame(maxWidth: .infinity, minHeight: 30)
                    .foregroundColor(.black).background(Color.yellow).cornerRadius(15)
                    if (isExpanded) {
                        ScrollView {
                            ForEach(plan.sorted {
                                !$0.isCompleted || $0.timestamp! < $1.timestamp!
                            }) { item in
                                TipDetails(task: item, isExpanded: self.selection == item.name)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.yellow, lineWidth: 4)
                                    )
                                    .cornerRadius(15)
                                    .padding(1)
                                    .onTapGesture { self.selectDeselect(item.name ?? "") }
                                    .animation(.linear(duration: 0.3))
                            }
                        }.padding(.horizontal, 15).animation(.linear(duration: 0.5))
                    }
                }.overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.yellow, lineWidth: 4))
            }.onAppear(){
                for item in plan {
                    if isTaskRunning(name: item.name, timestamp: item.timestamp) {
                        isExpanded = true
                        break
                    }
                }
            }
        }
    }
}
