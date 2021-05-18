//
//  QuoteView.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 18.05.2021.
//

import SwiftUI


struct QuoteView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var result = ""
    @State private var isLoading = false
    
    var specificColor: Color = Color.blue
    var fgColor: Color = Color.white
    var isModal: Bool = true
    
    let links = ["https://adviser-lilyok.vercel.app/api?topic=quotes",
                 "https://gist.githubusercontent.com/nasrulhazim/54b659e43b1035215cd0ba1d4577ee80/raw/e3c6895ce42069f0ee7e991229064f167fe8ccdc/quotes.json",
                 "https://gist.githubusercontent.com/b1nary/ea8fff806095bcedacce/raw/6e6de20d7514b93dd69b149289264997b49459dd/enterpreneur-quotes.json"]
    
    var body: some View {
        VStack(alignment: .leading) {
            if isModal {
                Spacer()
            }
            Text("Motivational quote for you").multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center).font(.title2)
            if isModal {
                Spacer()
            }
            if (isLoading) {
                ProgressView("Loading").foregroundColor(specificColor)
                    .scaleEffect(1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: specificColor))
                    .padding(20).multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center).font(.title3)
            } else {
                Text(self.result).padding(20).multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center).font(.title3)
            }
            if isModal {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Got It!").padding().font(.title2).background(specificColor).foregroundColor(fgColor)
                        .cornerRadius(30.0)
                }.frame(maxWidth: .infinity, alignment: .center)
            }
            Spacer()
        }.onAppear(perform: loadData)
    }
    
    func loadData() {
        self.isLoading = true
        let indx = Int.random(in: 0..<3)
        guard let url = URL(string: links[indx]) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = decodeResponse(data: data, indx: indx) {
                    DispatchQueue.main.async {
                        self.result = getResltQuote(responses: decodedResponse, indx: indx)
                        self.isLoading = false
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    private func decodeResponse(data: Data, indx: Int) -> Any? {
        switch indx {
        case 0:
            print(data)
            return try? JSONDecoder().decode([TypeFitQuote].self, from: data)
        case 1:
            return try? JSONDecoder().decode(AnotherQuotes.self, from: data)
        case 2:
            return try? JSONDecoder().decode([EnterpreneurQuotes].self, from: data)
        default:
            return nil
        }
    }
    
    private func getResltQuote(responses: Any?, indx: Int) -> String {
        let DUMMY_QUOTE = "server unavailable"
        if responses == nil {
            return DUMMY_QUOTE
        }
        switch indx {
        case 0:
            let parsedResponse = (responses as! [TypeFitQuote])
            let num = Int.random(in: 0..<parsedResponse.count)
            let response = parsedResponse[num]
            if response.author != nil {
                return "\(response.text)\n\n(\(response.author!))"
            }
            return response.text
        case 1:
            let parsedResponse = (responses as! AnotherQuotes).quotes
            let num = Int.random(in: 0..<parsedResponse.count)
            let response = parsedResponse[num]
            return "\(response.quote)\n\n(\(response.author))"
        case 2:
            let parsedResponse = (responses as! [EnterpreneurQuotes])
            let num = Int.random(in: 0..<parsedResponse.count)
            let response = parsedResponse[num]
            return "\(response.text)\n\n(\(response.from))"
        default:
            return DUMMY_QUOTE
        }
    }
    
    struct TypeFitQuote: Codable {
        var text: String
        var author: String?
    }
    
    struct AnotherQuotes: Codable {
        var quotes: [AnotherQuote]
    }
    
    struct AnotherQuote: Codable {
        var quote: String
        var author: String
    }
    
    struct EnterpreneurQuotes: Codable {
        var text: String
        var from: String
    }
}

