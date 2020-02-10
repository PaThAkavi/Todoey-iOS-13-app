//
//  Category.swift
//  Todoey
//
//  Created by Avaneesh Pathak on 09/02/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cellColor: String = ""
    let items = List<Item>() // one-many
}
