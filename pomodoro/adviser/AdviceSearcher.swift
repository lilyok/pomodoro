//
//  AdviceSearcher.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 04.05.2021.
//

import SwiftUI

struct AdviceSearcher: View {
    @State private var searchText = ""
    @State private var adviceNames = [Topic]()
    
    var body: some View {
        SearchBar(gapText: "Search your goal...", text: $searchText)
        List(adviceNames.filter({searchText.isEmpty ? true : $0.title.lowercased().contains(searchText.lowercased())}), id: \.link) { item in
            ReadyMadePlan(topic: item)
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        guard let url = URL(string: LINK[ENVNAME]!) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(TopicListResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.adviceNames = decodedResponse.data
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
}
