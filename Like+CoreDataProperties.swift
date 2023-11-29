//
//  Like+CoreDataProperties.swift
//  MySuomiApp
//
//  Created by iosdev on 28.11.2023.
//
//

import Foundation
import CoreData


extension Like {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Like> {
        return NSFetchRequest<Like>(entityName: "Like")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: String?

}

extension Like : Identifiable {

}
