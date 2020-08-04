//
//  Category.swift
//  Todoey
//
//  Created by Mantas Paškevičius on 2020-05-02.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
