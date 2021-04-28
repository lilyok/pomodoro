//
//  TipLink+CoreDataProperties.swift
//  pomodoro
//
//  Created by Liliia Ivanova on 28.04.2021.
//
//

import Foundation
import CoreData


extension TipLink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TipLink> {
        return NSFetchRequest<TipLink>(entityName: "TipLink")
    }

    @NSManaged public var link: String?
    @NSManaged public var text: String?
    @NSManaged public var tip: GoalTip?

}

extension TipLink : Identifiable {

}
