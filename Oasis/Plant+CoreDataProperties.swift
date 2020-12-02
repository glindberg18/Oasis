//
//  Plant+CoreDataProperties.swift
//  Oasis
//
//  Created by Greeley Lindberg on 12/2/20.
//
//

import Foundation
import CoreData


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var dateCompleted: Date?
    @NSManaged public var dateLastWatered: Date?
    @NSManaged public var datePlanted: Date?
    @NSManaged public var imageName: String
    @NSManaged public var phase: Int32
    @NSManaged public var phase1WaterNeeded: Int32
    @NSManaged public var phase2WaterNeeded: Int32
    @NSManaged public var plantName: String?
    @NSManaged public var totalWaterNeeded: Int32
    @NSManaged public var waterLevel: Int32
    @NSManaged public var isCurrent: Bool

}

extension Plant : Identifiable {

}
