//
//  Extension.swift
//  Login_RSA
//
//  Created by 苏翔宇 on 12/2/15.
//  Copyright © 2015 苏翔宇. All rights reserved.
//

import Foundation

let MAXDIGITS: Int = 130

//Entend_Class_Character_With_toInt_Func
extension Character {
    func toInt() -> Int {
        var intFromCharater: Int = 0
        for scalar in String(self).unicodeScalars {
            intFromCharater = Int(scalar.value)
        }
        
        return intFromCharater
    }
}
//Extend_Class_String_With_reverse_Func
extension String {
    mutating func reverse() -> String {
        return String(self.characters.reverse())
    }
}
