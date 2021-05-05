//
//  ReadyMadeTaskDetails.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 04.05.2021.
//

import SwiftUI

struct ReadyMadeTaskDetails: View {
    let task: TopicTaskDetails
    let isExpanded: Bool
    
    var body: some View {
        VStack {
            Label(task.title, systemImage: "list.triangle")
                .fixedSize(horizontal: false, vertical:true)
                .font(.system(size: 18))
                .padding()
                .frame(minHeight: 50)
                .foregroundColor(.black)
                .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                .background(Color.yellow)
            
            if isExpanded {
                ForEach(task.references.links, id: \.description) { item in
                    Text(item.description)
                        .fixedSize(horizontal: false, vertical:true)
                        .foregroundColor(.primary).font(.system(size: 16))
                        .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                    if item.link != "" {
                        Link("Open the resource", destination: URL(string: item.link)!)
                            .frame( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.yellow)
                            .cornerRadius(40).buttonStyle(BorderlessButtonStyle())
                    }
                    Divider().background(Color.yellow)
                }.padding(.horizontal, 7)
            }
        }
    }
}
