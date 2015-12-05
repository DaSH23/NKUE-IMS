//
//  Convertion.swift
//  Login_RSA
//
//  Created by 苏翔宇 on 12/2/15.
//  Copyright © 2015 苏翔宇. All rights reserved.
//

import Foundation

//HexString_BigInt_Convertion_Helper_Func
class Converter {
    //Lowest_Index_NotEqualZero_Which_Means_LargestLiteral_In_Array
    func BILowIndexNZero(BI: BigInt) -> Int {
        var result: Int = BI.digits.count - 1
        while result > 0 && BI.digits[result] == 0 {
            --result
        }
        
        return result
    }
    //BigInt_Digits_Not_Zero_Bits
    func BINZeroBits(BI: BigInt) -> Int {
        var result: Int
        
        let notZeroIndex: Int = BILowIndexNZero(BI)
        var notZeroDigit: Int = BI.digits[notZeroIndex] //At_Least_One
        let m: Int = (notZeroIndex + 1) * BigInt.bitsPerDigit
        for result = m; ; --result {
            if (notZeroDigit & 0x8000) != 0 {
                break
            }
            notZeroDigit <<= 1
        }
        
        return result
    }
    
    //SingleString(Char)_Hex(Num)_Convertion
    let hexToChar = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
    func charToHex(ch: Int) -> Int {
        var result: Int
        
        let ZERO: Int = 48
        let NINE: Int = ZERO + 9
        let littleA: Int = 97
        let littleZ: Int = littleA + 25
        let bigA: Int = 65
        let bigZ: Int = 65 + 25
        
        if ch >= ZERO && ch <= NINE {
            result = ch - ZERO
        } else if ch >= bigA && ch <= bigZ {
            result = 10 + ch - bigA
        } else if ch >= littleA && ch <= littleZ {
            result = 10 + ch - littleA
        } else {
            result = 0
        }
        
        return result
    }
    
    //BigInt_To_HexString
    func BIToHexString(BI: BigInt) -> String {
        var result: String = ""
        
        let notZeroIndex = BILowIndexNZero(BI)
        for (var index = notZeroIndex; index > -1; --index) {
            result += digitToHexString(BI.digits[index])
        }
        
        return result
    }
    
    //SingleDigit_To_HexStringBlock
    func digitToHexString(var digit: Int) -> String {
        let mask: Int = 0xf
        var result = ""
        for _ in 0...3{
            result += hexToChar[digit & mask]
            digit >>= 4
        }
//        print(result)
        return result.reverse()
    }
    
    //HexStringBlock_To_SingleDigit
    func hexStringToDigit(hexStr: String) -> Int {
        var result: Int = 0
        
        let strLength: Int = min(hexStr.characters.count, 4)
        for (var i = 0; i < strLength; ++i) {
            result <<= 4
            result |= charToHex(hexStr[hexStr.startIndex.advancedBy(i)].toInt())
        }
        
        return result
    }
    
    //Generate_BigInt_From_HexString
    func BIFromHexString(hexStr: String) -> BigInt {
        let result = BigInt(maxDigits: MAXDIGITS)
        
        let strLength: Int = hexStr.characters.count
        for (var index = strLength, i = 0; index > 0; index -= 4, ++i) {
            let subStrFromIndex: Int = max(index - 4, 0)
            let subStrLength: Int = min(index, 4)
            let subStr: String = hexStr.substringWithRange(Range<String.Index>(start: hexStr.startIndex.advancedBy(subStrFromIndex), end: hexStr.startIndex.advancedBy(subStrFromIndex + subStrLength)))
            
            result.digits[i] = hexStringToDigit(subStr)
        }
        
        return result
    }
}
