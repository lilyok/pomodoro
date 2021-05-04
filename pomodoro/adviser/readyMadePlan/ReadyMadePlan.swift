//
//  ReadyMadePlan.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 04.05.2021.
//

import SwiftUI

struct ReadyMadePlan: View {
    private let topic: Topic
    
    @State private var openPlan = false
    
    init(topic: Topic) {
        self.topic = topic
    }
    
    var body: some View {
        Text("• " + topic.title)
            .onTapGesture {
                openPlan.toggle()
            }
            .font(.title2)
            .fullScreenCover(isPresented: $openPlan) {
                ReadyMadePlanDetails(topic: topic)
            }
    }
}

func getAllReadyMadePlanVersions() -> [String:String] {
    let userDefaults = UserDefaults.standard
    let versions = userDefaults.object(forKey: "ReadyMadePlanVersion") as? [String:String] ?? [:]
    return versions
}

func setReadyMadePlanVersion(link: String? = nil, version: String? = nil, topic: Topic? = nil) {
    let userDefaults = UserDefaults.standard
    var versions = userDefaults.object(forKey: "ReadyMadePlanVersion") as? [String:String] ?? [:]
    versions[topic == nil ? link! : topic?.link ?? ""] = version
    userDefaults.set(versions, forKey: "ReadyMadePlanVersion")
    if (topic == nil) {
        return
    }
    // topic is nessesary for case when user added and immediately deleted a plan
    if let data = UserDefaults.standard.value(forKey:"NewTopics") as? Data {
        var curTopics = try? PropertyListDecoder().decode(Set<Topic>.self, from: data)
        if (curTopics != nil) {
            curTopics!.remove(topic!)
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(curTopics), forKey: "NewTopics")
    }
}

