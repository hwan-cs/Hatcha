//
//  SubwayData.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/23.
//

import Foundation
import RealmSwift

class SubwayAlarmData: Object
{
    @objc dynamic var destination: String?
    @objc dynamic var line: String?
    @objc dynamic var compoundKey = ""

    override static func primaryKey() -> String?
    {
        return "compoundKey"
    }

    func setup(destination: String, line: String)
    {
        self.destination = destination
        self.line = line
        self.compoundKey = compoundKeyValue()
    }

    func compoundKeyValue() -> String
    {
        return "\(destination!)\(line!)"
    }
}

