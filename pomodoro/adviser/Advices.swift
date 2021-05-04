//
//  Advices.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 21.04.2021.
//

import SwiftUI

let ENVNAME: String = "TEST"  // "PROD"
let LINK: [String: String] = ["TEST": "http://127.0.0.1:5000/api", "PROD":  "https://adviser-lilyok.vercel.app/api"]


func isTaskRunning(name: String?, timestamp: Date?) -> Bool { // TODO to common code
    let TasksStatus = UserDefaults.standard.object(forKey: "TaskSettings") as? [String:Bool] ?? [:]
    let key = "\(name ?? "")_\(timestamp ?? Date())"
    return TasksStatus[key] != nil ? TasksStatus[key]! : false
}

struct PomodoroButtons: View { // TODO to common code
    let task: Task
    let isColored: Bool

    @Binding var completeTask: Bool
    @Binding var runTask: Bool
    @Binding var isNewTimer: Bool

    var body: some View {
        HStack {
            if !completeTask && !task.isCompleted {
                Button(action: {
                    isNewTimer = true
                    runTask.toggle()
                }) {
                    Text("Run")
                        .frame(minWidth: 10, idealWidth: 50, maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(
                            isColored ?
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(40)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                Button(action: {
                    withAnimation {
                        runTask = false
                        task.isCompleted = true
                        completeTask.toggle()
                    }
                }) {
                    Text("Complete")
                        .frame(minWidth: 10, idealWidth: 50, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(
                            isColored ?
                            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.red]), startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(40)
                }
                .buttonStyle(BorderlessButtonStyle())
            } else {
                Spacer()
                Button(action: {
                    withAnimation {
                        task.isCompleted = false
                        completeTask.toggle()
                    }
                }) {
                    Text("COMPLETED").frame(minWidth: 10, idealWidth: 50, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                        .foregroundColor(Color.white)
                }
            }
        }
    }
}

struct TipList: View {
    let title: String
    let plan: [GoalTip]


    @State private var isExpanded: Bool = false
    @State private var selection: String = ""
    
    @State private var completeTask = false
    @State private var runTask = false
    @State private var isNewTimer = false;
    
    private func selectDeselect(_ title: String) {
        if (selection == title) {
            selection = ""
            return
        }
        selection = title
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
                    }.overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.yellow, lineWidth: 4)
                    )
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

struct TipDetails: View {
    let task: GoalTip
    let isExpanded: Bool

    @State private var completeTask: Bool = false
    @State private var runTask: Bool = false
    @State private var isNewTimer: Bool = true  // TODO??????

    let timer = Timer.publish(every: 0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            
            Label(task.name ?? "", systemImage: "list.triangle")
                .font(.system(size: 18))
                .padding()
                .frame(minHeight: 50)
                .foregroundColor(.black)
                .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                .background(Color.yellow)
            if isExpanded {
                ForEach((task.links?.allObjects as? [TipLink] ?? [])) { item in
                    Text(item.text!).foregroundColor(.primary).font(.system(size: 16))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                    if item.link != "" {
                        Link("Open the resource", destination: URL(string: item.link!)!)
                            .frame( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.yellow)
                            .cornerRadius(40).buttonStyle(BorderlessButtonStyle())
                    }
                    Divider().background(Color.yellow)
                }.padding(.horizontal, 7)
            }
            PomodoroButtons(task: task, isColored: false, completeTask: $completeTask, runTask: $runTask, isNewTimer: $isNewTimer).padding(2).background(Color.yellow)

        }.fullScreenCover(isPresented: $runTask) {
            CurrentTaskView(task: task, settings: PomodoroSettings.loadPomodoroSettings(), isNewTimer: isNewTimer)
        }.background((!completeTask && !task.isCompleted) ? Color.clear: Color.yellow)
        .opacity((!completeTask && !task.isCompleted) ? 1.0: 0.8).cornerRadius(5)
        .onReceive(timer) { _ in
//            if !isNewTimer {
//                let TasksStatus = UserDefaults.standard.object(forKey: "TaskSettings") as? [String:Bool] ?? [:]
//                let key = "\(task.name ?? "")_\(task.timestamp ?? Date())"
//                self.runTask = TasksStatus[key] != nil ? TasksStatus[key]! : false
//            if !isNewTimer {
                self.runTask = isTaskRunning(name: task.name, timestamp: task.timestamp)
//            }
            isNewTimer = false
            timer.upstream.connect().cancel()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isNewTimer = false
        }
    }
}


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
                            .padding()
                            .foregroundColor(Color.black)
                            .background(Color.yellow)
                            .cornerRadius(40)
                            .padding(5)
                        Spacer()
                    }
                }.onAppear(perform: loadAdvices)
                if (isLoading) {
                    ProgressView("Loading").foregroundColor(.yellow)
                        .scaleEffect(1.5, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
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

struct ListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            content
            Divider()
        }.offset(x: 20)
    }
}

struct ReadyMadePlanDetails: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var adviceDetails = [TopicTaskDetails]()
    @State private var selection: String = ""
    
    private let topic: Topic
    
    enum PlanStatus {
        case added, unloaded, outdated
    }
    
    @State private var currentStatus: PlanStatus? = nil
    
    init(topic: Topic) {
        self.topic = topic
    }
    
    var body: some View {
        VStack{
            VStack{
                Text(self.topic.title).font(.system(size: 20))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                    .padding(15)
                    .onAppear(perform: loadData)
                
                ScrollView {
                    ForEach(adviceDetails, id: \.title) { item in
                        ReadyMadeTaskDetails(task: item, isExpanded: self.selection == item.title)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.yellow, lineWidth: 4)
                            )
                            
                            .cornerRadius(15)
                            
                            .padding(1)
                            .onTapGesture { self.selectDeselect(item) }
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
                    Text(
                        (self.currentStatus == PlanStatus.unloaded ?
                            "Add these tips" : (self.currentStatus == PlanStatus.added ?
                                                    "Delete these tips" : "Update these tips")
                        )
                    )
                    
                    .frame(minWidth: 10, idealWidth: 100, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 10, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding()
                    .foregroundColor(Color.white)
                    .background(self.currentStatus == PlanStatus.added ? Color.red : Color.blue)
                    .cornerRadius(40)
                    .onAppear() {
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
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(40)
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
        selection = task.title
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


struct ReadyMadeTaskDetails: View {
    let task: TopicTaskDetails
    let isExpanded: Bool
    
    var body: some View {
        VStack {
            Text(task.title)
                .font(.system(size: 18))
                .fontWeight(.medium)
                .padding()
                .frame(minHeight: 50)
                .foregroundColor(.black)
                .multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center)
                .background(Color.yellow)
            
            if isExpanded {
                ForEach(task.references.links, id: \.description) { item in
                    Text(item.description).foregroundColor(.primary).font(.system(size: 16))
                        .fontWeight(.medium)
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


struct Adviser_Previews: PreviewProvider {
    static var previews: some View {
        Adviser()
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

private func getAllReadyMadePlanVersions() -> [String:String] {
    let userDefaults = UserDefaults.standard
    let versions = userDefaults.object(forKey: "ReadyMadePlanVersion") as? [String:String] ?? [:]
    return versions
}


private func setReadyMadePlanVersion(link: String? = nil, version: String? = nil, topic: Topic? = nil) {
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
