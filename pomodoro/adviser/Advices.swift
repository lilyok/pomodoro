//
//  Advices.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 21.04.2021.
//

import SwiftUI

struct Adviser: View {
    @State private var searchText = ""
    @State private var adviceNames = [Topic]()
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText).padding(.top)
            List(adviceNames.filter({searchText.isEmpty ? true : $0.title.lowercased().contains(searchText.lowercased())}), id: \.link) { item in
                VStack(alignment: .leading) {
                    ReadyMadePlan(title: item.title, link: item.link)
                }
            }
            .onAppear(perform: loadData)
        }
    }
    
    func loadData() {
        guard let url = URL(string: "https://adviser-lilyok.vercel.app/api") else {
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

struct ReadyMadePlan: View {
    private let title: String
    private let link: String
    
    @State private var openPlan = false
    
    init(title: String, link: String) {
        self.title = title
        self.link = link
    }
    
    var body: some View {
        Text(title)
            .onTapGesture {
                openPlan.toggle()
            }
            .font(.title2)
            .fullScreenCover(isPresented: $openPlan) {
                ReadyMadePlanDetails(title: title, link: link)
            }
    }
}

struct ReadyMadePlanDetails: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var adviceDetails = [TopicTaskDetails]()

    private let title: String
    private let link: String


    init(title: String, link: String) {
        self.title = title
        self.link = link
    }

    var body: some View {
        VStack{
            Text(self.title).font(.title2)
            Spacer()
            List(adviceDetails, id: \.title) { item in
                VStack(alignment: .leading) {
//                    ReadyMadePlan(title: item.title, link: item.title)
                    ReadyMadeTaskDetails(task: item)
                }
            }
            .onAppear(perform: loadData)
            
            Spacer()
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Add to my plans")
                        .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(40)
                })
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                        .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(40)
                })
            }
        }
        
    }
    
    func loadData() {
        guard let url = URL(string: "https://adviser-lilyok.vercel.app/api?topic=" + self.link) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(TopicDetailsResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.adviceDetails = decodedResponse.data
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
}


struct ReadyMadeTaskDetails: View {
    private let task: TopicTaskDetails

    init(task: TopicTaskDetails) {
        self.task = task
    }
    var body: some View {
        VStack {
            Text(task.title)
                .font(.title3).foregroundColor(.primary)
                .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
            ForEach(task.references.links, id: \.description) { item in
                Text(item.description).foregroundColor(.primary)
                if item.link != "" {
                    Link("Open the resource", destination: URL(string: item.link)!)
                        .frame( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.red]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(40).buttonStyle(BorderlessButtonStyle())
                }
                Spacer()
            }
        }
    }
}


struct Adviser_Previews: PreviewProvider {
    static var previews: some View {
        Adviser()
    }
}
