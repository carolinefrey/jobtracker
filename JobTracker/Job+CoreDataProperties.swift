//
//  Job+CoreDataProperties.swift
//  JobTracker
//
//  Created by Caroline Frey on 11/30/22.
//
//

import Foundation
import CoreData


extension Job {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Job> {
        return NSFetchRequest<Job>(entityName: "Job")
    }

    @NSManaged public var company: String?
    @NSManaged public var role: String?
    @NSManaged public var location: String?
    @NSManaged public var link: String?
    @NSManaged public var notes: String?
    @NSManaged public var status: JobStatus.RawValue?
}

extension Job : Identifiable {

}
