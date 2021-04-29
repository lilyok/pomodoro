//
//  GoalTips+CoreDataProperties.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 29.04.2021.
//
//

import Foundation
import CoreData


extension GoalTips {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalTips> {
        return NSFetchRequest<GoalTips>(entityName: "GoalTips")
    }

    @NSManaged public var link: String?
    @NSManaged public var title: String?
    @NSManaged public var version: String?
    @NSManaged public var goalTips: NSSet?

}

// MARK: Generated accessors for goalTips
extension GoalTips {

    @objc(addGoalTipsObject:)
    @NSManaged public func addToGoalTips(_ value: GoalTip)

    @objc(removeGoalTipsObject:)
    @NSManaged public func removeFromGoalTips(_ value: GoalTip)

    @objc(addGoalTips:)
    @NSManaged public func addToGoalTips(_ values: NSSet)

    @objc(removeGoalTips:)
    @NSManaged public func removeFromGoalTips(_ values: NSSet)

}

extension GoalTips : Identifiable {

}
