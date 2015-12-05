//
//  BigInt.swift
//  Login_RSA
//
//  Created by 苏翔宇 on 12/1/15.
//  Copyright © 2015 苏翔宇. All rights reserved.
//

import Foundation

//Class_BigInt_For_0xffffRadixNumber_Restore
class BigInt {
    //BigInt_Base_0xffff
    static let BIRadixBits: Int = 16
    static var bitsPerDigit: Int {
        return BigInt.BIRadixBits
    }
    static let BIRadix: Int = 1 << 16
    static let BIHalfRadix: Int = 1 << 15
    static let maxDigitVal: Int = 0xffff
    static var BIRadixSquare: Int {
        return BigInt.BIRadix * BigInt.BIRadix
    }

    //BigInt_Digit_Array
    var maxDigits: Int
    var isNeg: Bool
    var digits = [Int]()
    init(maxDigits: Int) {
        self.maxDigits = maxDigits
        self.isNeg = false
        digits = [Int](count: self.maxDigits, repeatedValue: 0)
    }
    
    static func BICopy(Ori_BI: BigInt) -> BigInt {
        let result = BigInt(maxDigits: Ori_BI.maxDigits)
        result.digits = Ori_BI.digits
        result.isNeg = Ori_BI.isNeg
        
        return result
    }
    
    static func BICompare(x: BigInt, y: BigInt) -> Int {
        if x.isNeg != y.isNeg {
            return 1 - 2 * (x.isNeg ? 1 : 0)
        } else {
            for var index = x.digits.count - 1; index >= 0; --index {
                if x.digits[index] != y.digits[index] {
                    if x.isNeg {
                        return 1 - 2 * (x.digits[index] > y.digits[index] ? 1 : 0)
                    } else {
                        return 1 - 2 * (x.digits[index] < y.digits[index] ? 1 : 0)
                    }
                } else {
                    continue
                }
            }
        }
        
        return 0
    }
    
    static func BIOne() -> BigInt {
        let result = BigInt(maxDigits: MAXDIGITS)
        result.digits[0] = 1
        
        return result
    }
    static func BIZero() -> BigInt {
        return BigInt(maxDigits: MAXDIGITS)
    }
}
