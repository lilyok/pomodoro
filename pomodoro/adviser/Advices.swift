//
//  Advices.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 21.04.2021.
//

import SwiftUI

let ENVNAME: String = "PROD" //"TEST"  // "PROD"
let LINK: [String: String] = ["TEST": "http://127.0.0.1:5000/api", "PROD":  "https://adviser-lilyok.vercel.app/api"]

struct Adviser: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoalTips.title, ascending: true),
        ],
        animation: .default)
    private var plans: FetchedResults<GoalTips>
    
    @State private var isLoading = false
    @State private var summaryCount = 0
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack {
                if (plans.count == 0) {
                    Text("You haven't added anything yet..").padding(.top, 2)
                }
                NavigationLink(destination: AdviceSearcher()) {
                    HStack{
                        Spacer()
                        Label("Find tips for your new goal", systemImage: "plus")
                            .padding().foregroundColor(Color.black).background(Color.yellow)
                            .cornerRadius(40).padding(5)
                        Spacer()
                    }
                }.onAppear(perform: loadAdvices)
                if (isLoading) {
                    ProgressView("Loading").foregroundColor(.yellow)
                        .scaleEffect(1.5, anchor: .center).progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                } else {
                    List {
                        ForEach(self.plans) { plan in
                            TipList(title: plan.title!, plan: plan.goalTips?.allObjects as? [GoalTip] ?? [])
                        }.onDelete(perform: deletePlans)
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                            saveData()
                        }
                    }
                }
            }.navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {Text("Added goals")})})
        }.onReceive(timer) { _ in
            if (self.isLoading && self.summaryCount == self.plans.count) {
                self.isLoading = false
                self.viewContext.refreshAllObjects()
                
            } else if (self.summaryCount == self.plans.count) {
                timer.upstream.connect().cancel()
            }
        }
    }

    private func deletePlans(offsets: IndexSet) {
        offsets.map { plans[$0] }.forEach { (el : GoalTips) in
            setReadyMadePlanVersion(link: el.link!, version: nil)
        }
        withAnimation {
            offsets.map { plans[$0] }.forEach(viewContext.delete)
            self.saveData()
        }
    }
    
    func loadAdvices() {
        self.isLoading = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        let linkToDownload = getTopicsToDownlad()
        let versions = getAllReadyMadePlanVersions()

        self.summaryCount = versions.count

        var indexesToDelete: [Int] = []
        for (index, el) in self.plans.enumerated() {
            let key: String = el.link!
            if (versions.keys.contains(key) == false) {
                indexesToDelete.append(index)
                continue
            }
            if (versions[key] != el.version) {
                self.loadData(link: el.link!, title: el.title!, version: versions[key]!, update: true, elToUpdate: el)
            }
        }

        for index in indexesToDelete {
            viewContext.delete(self.plans[index])
        }

        if (linkToDownload.count == 0) {
            return
        }

        for el in linkToDownload {
            self.loadData(link: el.link, title: el.title, version: el.version)
        }

        clearTopicsToDownlad()
    }
    
    func loadData(link: String, title: String, version: String, update: Bool = false, elToUpdate: GoalTips? = nil) {
        guard let url = URL(string: LINK[ENVNAME]! + "?topic=" + link) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(TopicDetailsResponse.self, from: data) {
                    DispatchQueue.main.async {
                        let adviceDetails = decodedResponse.data
                        if update {
                            updateTask(link: link, title: title, version: version, adviceDetails: adviceDetails, elToUpdate: elToUpdate!)
                        } else {
                            addTask(link: link, title: title, version: version, adviceDetails: adviceDetails)
                        }
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
    func updateTask(link: String, title: String, version: String, adviceDetails: [TopicTaskDetails], elToUpdate: GoalTips) {
        elToUpdate.title = title
        elToUpdate.link = link
        elToUpdate.version = version
        
        var nameToGoalTip = [String : GoalTip]()
        for goalTip in elToUpdate.goalTips?.allObjects as? [GoalTip] ?? [] {
            nameToGoalTip[goalTip.name!] = goalTip
        }
        elToUpdate.goalTips = nil
        
        for tip in adviceDetails {
            let goalTip = GoalTip(context: viewContext)
            goalTip.name = tip.title
            goalTip.timestamp = nameToGoalTip[tip.title]?.timestamp
            goalTip.spoiledPomodoros = nameToGoalTip[tip.title]?.spoiledPomodoros ?? 0
            goalTip.completedPomodoros = nameToGoalTip[tip.title]?.completedPomodoros ?? 0
            goalTip.isCompleted = nameToGoalTip[tip.title]?.isCompleted ?? false
            
            for link in tip.references.links {
                let tipLink = TipLink(context: viewContext)
                tipLink.link = link.link
                tipLink.text = link.description
                tipLink.tip = goalTip
            }
            
            goalTip.goal = elToUpdate
        }
        self.saveData()

        
    }

    func addTask(link: String, title: String, version: String, adviceDetails: [TopicTaskDetails]) {
        withAnimation {
            PomodoroTimer.allowNotifications()
            let newPlan = GoalTips(context: viewContext)
            newPlan.title = title
            newPlan.link = link
            newPlan.version = version
            
            for tip in adviceDetails {
                let goalTip = GoalTip(context: viewContext)
                goalTip.name = tip.title
                goalTip.timestamp = Date()
                goalTip.spoiledPomodoros = Int64(0)
                goalTip.completedPomodoros = Int64(0)
                goalTip.isCompleted = false
                
                for link in tip.references.links {
                    let tipLink = TipLink(context: viewContext)
                    tipLink.link = link.link
                    tipLink.text = link.description
                    tipLink.tip = goalTip
                }
                goalTip.goal = newPlan
            }
            self.saveData()
        }
    }
    
    func saveData() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


func getTopicsToDownlad() -> Set<Topic> {
    if let data = UserDefaults.standard.value(forKey:"NewTopics") as? Data {
        let curTopics = try? PropertyListDecoder().decode(Set<Topic>.self, from: data)
        if (curTopics != nil) {
            return curTopics!
        }
    }
    return Set<Topic>()
}


func clearTopicsToDownlad(){
    UserDefaults.standard.set(nil, forKey: "NewTopics")
}
