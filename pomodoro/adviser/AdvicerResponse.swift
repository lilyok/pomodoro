//
//  AdvicerResponse.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 22.04.2021.
//

import SwiftUI

struct TopicListResponse: Codable {
    var data: [Topic]
}

struct Topic: Codable, Hashable {
    var title: String
    var link: String
    var version: String
    
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        return lhs.link == rhs.link
    }
}

struct TopicDetailsResponse: Codable {
    var data: [TopicTaskDetails]
}

struct TopicTaskDetails: Codable, Hashable {
    var title: String
    var references: TopicReferences
    
    static func == (lhs: TopicTaskDetails, rhs: TopicTaskDetails) -> Bool {
        return lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

struct TopicReferences: Codable {
    var info: String
    var links: [LinkInfo]
}

struct LinkInfo: Codable {
    var link: String
    var description: String
}
