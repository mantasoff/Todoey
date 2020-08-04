//
//  Item.swift
//  Todoey
//
//  Created by Mantas Paškevičius on 2020-05-02.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Double = 0
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
