//
//  Todo.swift
//  Todoey
//
//  Created by Mantas Paškevičius on 2020-04-24.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

class Todo : Codable {
    var title: String
    var done: Bool
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
