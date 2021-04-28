//
//  GoalTip+CoreDataProperties.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 28.04.2021.
//
//

import Foundation
import CoreData


extension GoalTip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalTip> {
        return NSFetchRequest<GoalTip>(entityName: "GoalTip")
    }

    @NSManaged public var goal: GoalTips?
    @NSManaged public var links: NSSet?

}

// MARK: Generated accessors for links
extension GoalTip {

    @objc(addLinksObject:)
    @NSManaged public func addToLinks(_ value: TipLink)

    @objc(removeLinksObject:)
    @NSManaged public func removeFromLinks(_ value: TipLink)

    @objc(addLinks:)
    @NSManaged public func addToLinks(_ values: NSSet)

    @objc(removeLinks:)
    @NSManaged public func removeFromLinks(_ values: NSSet)

}
