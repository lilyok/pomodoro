//
//  ReadyMadePlanDetails.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 04.05.2021.
//

import SwiftUI

struct ReadyMadePlanDetails: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var adviceDetails = [TopicTaskDetails]()
    @State private var currentStatus: PlanStatus? = nil
    @State private var selection: String = ""
    
    let topic: Topic
    enum PlanStatus {case added, unloaded, outdated}

    var body: some View {
        VStack{
            VStack{
                Text(self.topic.title).font(.system(size: 20)).fontWeight(.medium)
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                    .padding(15).onAppear(perform: loadData)
                
                ScrollView {
                    ForEach(adviceDetails, id: \.title) { item in
                        ReadyMadeTaskDetails(task: item, isExpanded: self.selection == item.title)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.yellow, lineWidth: 4))
                            .cornerRadius(15).padding(1).onTapGesture { self.selectDeselect(item) }
                            .animation(.linear(duration: 0.3))
                    }
                }.padding(.horizontal, 15)
            }
            Spacer()
            HStack {
                Button(action: {
                    saveReadyMadePlans()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text((self.currentStatus == PlanStatus.unloaded ? "Add these tips" :
                            (self.currentStatus == PlanStatus.added ? "Delete these tips" : "Update these tips")))
                    
                    .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding().foregroundColor(Color.white).background(self.currentStatus == PlanStatus.added ? Color.red : Color.blue)
                    .cornerRadius(40).onAppear() {
                        if (self.currentStatus == nil) {
                            self.currentStatus = self.getPlanStatus()
                        }
                    }
                }
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                        .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding().foregroundColor(Color.white).background(Color.red).cornerRadius(40)
                })
            }
        }
    }
    
    private func getPlanStatus() -> PlanStatus {
        let currentVersion = self.getReadyMadePlanVersion()
        if (currentVersion == nil) {
            return PlanStatus.unloaded
        }
        if (currentVersion == topic.version) {
            return PlanStatus.added
        }
        return PlanStatus.outdated
    }
    
    public func saveReadyMadePlans() {
        if currentStatus == PlanStatus.added {
            setReadyMadePlanVersion(version: nil, topic: topic)
            return
        }
        let userDefaults = UserDefaults.standard
        
        if currentStatus == PlanStatus.unloaded {
            var newTopics = getTopicsToDownlad()
            if (!newTopics.contains(topic)) {
                newTopics.insert(topic)
                userDefaults.set(try? PropertyListEncoder().encode(newTopics), forKey: "NewTopics")
            }
        }
        setReadyMadePlanVersion(link: topic.link, version: topic.version)
    }
    
    private func getReadyMadePlanVersion() -> String? {
        let userDefaults = UserDefaults.standard
        let versions = userDefaults.object(forKey: "ReadyMadePlanVersion") as? [String:String] ?? [:]
        return versions[topic.link]
    }
    
    private func selectDeselect(_ task: TopicTaskDetails) {
        selection = selection == task.title ? "" : task.title
    }
    
    func loadData() {
        guard let url = URL(string: LINK[ENVNAME]! + "?topic=" + self.topic.link) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(TopicDetailsResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.adviceDetails = decodedResponse.data
                        if (self.adviceDetails.count > 0) {
                            self.selection = self.adviceDetails[0].title
                        }
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
}

