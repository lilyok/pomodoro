//
//  Task+CoreDataProperties.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 23.02.2021.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var name: String?
    @NSManaged public var completedPomodoros: Int64
    @NSManaged public var spoiledPomodoros: Int64
    @NSManaged public var isCompleted: Bool

}

extension Task : Identifiable {

}
