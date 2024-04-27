//
//  User.swift
//  FinalCookBook291
//
//  Created by Kenzie on 4/26/24.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    
    let recipes = LinkingObjects(fromType: Recipe.self, property: "owner")

    override static func primaryKey() -> String? {
        return "id"
    }
}
