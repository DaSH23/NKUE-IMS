//
//  BigInt_Calculation.swift
//  Login_RSA
//
//  Created by 苏翔宇 on 12/1/15.
//  Copyright © 2015 苏翔宇. All rights reserved.
//

import Foundation

//BigInt_Calculator
class Calculator: Converter {
    
    func BIAdd(x: BigInt, y: BigInt) -> BigInt {
        var result = BigInt(maxDigits: MAXDIGITS)
        
        if x.isNeg != y.isNeg {
            y.isNeg = !y.isNeg
            result = BISubtract(x, y: y)
            y.isNeg = !y.isNeg
        } else {
            var carry: Int = 0
            var ithDigit: Int
            
            for var i = 0; i < x.digits.count; ++i {
                ithDigit = x.digits[i] + y.digits[i] + carry
                result.digits[i] = ithDigit % BigInt.BIRadix
                carry = ithDigit >= BigInt.BIRadix ? 1 : 0
            }
            result.isNeg = x.isNeg
        }
        
        return result
    }
    
    func BISubtract(x: BigInt, y: BigInt) ->BigInt {
        var result = BigInt(maxDigits: MAXDIGITS)
        
        if x.isNeg != y.isNeg {
            y.isNeg = !y.isNeg
            result = BIAdd(x, y: y)
            y.isNeg = !y.isNeg
        } else {
            result = BigInt.BIZero()
            var carry: Int = 0
            var ithDigit: Int = 0
            
            for var i = 0; i < x.digits.count; ++i {
                ithDigit = x.digits[i] - y.digits[i] + carry
                result.digits[i] = ithDigit % BigInt.BIRadix
                
                //From_Original_JS_Code-----Donot_Know_UseOrUseless
                if result.digits[i] < 0 {
                    result.digits[i] += BigInt.BIRadix
                }
                carry = 0 - (ithDigit < 0 ? 1 : 0)
            }
            
            //The_Last_Carry_isNeg
            if carry == -1 {
                carry = 0
                for var i = 0; i < x.digits.count; ++i {
                    ithDigit = 0 - result.digits[i] + carry
                    result.digits[i] = ithDigit % BigInt.BIRadix
                    
                    //From_Original_JS_Code-----Donot_Know_UseOrUseless
                    if result.digits[i] < 0 {
                        result.digits[i] += BigInt.BIRadix
                    }
                    carry = 0 - (ithDigit < 0 ? 1 : 0)
                }
                result.isNeg = !x.isNeg
            } else {
                result.isNeg = x.isNeg
            }
        }
        
        return result
    }
    
//----Two_Kinds_Of_BigInt_Multiplication_From_Here----
    //    BigIntX_Multiply_BigIntY
    func BIMultiply(x: BigInt, y: BigInt) -> BigInt {
        let result = BigInt(maxDigits: MAXDIGITS)
        
        let xNotZeroIndex: Int = BILowIndexNZero(x)
        let yNotZeroIndex: Int = BILowIndexNZero(y)
        
        var carry: Int = 0
        var indexInCal: Int = 0 //Index_In_Calculation
        var digitInCal: Int = 0 //Multiply_Result_For_DigitAtIndex
        
        for var indexInY = 0; indexInY <= yNotZeroIndex; ++indexInY {
            carry = 0
            indexInCal = indexInY
            
            for var indexInX = 0; indexInX <= xNotZeroIndex; ++indexInX, ++indexInCal {
                digitInCal = result.digits[indexInCal] + x.digits[indexInX] * y.digits[indexInY] + carry
                result.digits[indexInCal] = digitInCal & BigInt.maxDigitVal
                carry = digitInCal >> BigInt.BIRadixBits
            }
            result.digits[indexInY + xNotZeroIndex + 1] = carry
        }
        result.isNeg = x.isNeg != y.isNeg
        
        return result
    }
    //    BigIntX_Multiply_DigitInBigInt
    func BIMultiplyDigit(x: BigInt, y: Int) -> BigInt {
        let result = BigInt(maxDigits: MAXDIGITS)
        
        let xNotZeroIndex: Int = BILowIndexNZero(x)
        
        var carry: Int = 0
        var digitInCal: Int = 0 //Multiply_Result_For_DigitAtIndex
        for var indexInX = 0; indexInX <= xNotZeroIndex; ++indexInX {
            digitInCal = result.digits[indexInX] + x.digits[indexInX] * y + carry
            result.digits[indexInX] = digitInCal & BigInt.maxDigitVal
            carry = digitInCal >> BigInt.BIRadixBits
        }
        result.digits[xNotZeroIndex + 1] = carry
        
        return result
    }
//----Two_Kinds_Of_BigInt_Multiplication_To_Here----
    
    
//----BigInt_BitBaseShift_Functions_From_Here----
    //    Copy_BigIntDigitsArray
    func arrayCopy(srcArr: [Int], srcStart: Int, var destArr: [Int], destStart: Int, hopeLength: Int) -> [Int] {
        let copyLength = min(srcStart + hopeLength, srcArr.count)
        for var indexInSrc = srcStart, indexInDest = destStart; indexInSrc < copyLength; ++indexInSrc, ++indexInDest {
            destArr[indexInDest] = srcArr[indexInSrc]
        }
        
        return destArr
    }
    //   LeftShift_With_DigitsAndBits
    func BIShiftLeft(x: BigInt, shiftLength: Int) -> BigInt {
        let result = BigInt(maxDigits: MAXDIGITS)
        
        let highBitMasks: [Int] = [0x0000,
            0x8000, 0xC000, 0xE000, 0xF000,
            0xF800, 0xFC00, 0xFE00, 0xFF00,
            0xFF80, 0xFFC0, 0xFFE0, 0xFFF0,
            0xFFF8, 0xFFFC, 0xFFFE, 0xFFFF]
        
        let digitCount = shiftLength / BigInt.bitsPerDigit
        result.digits = arrayCopy(x.digits, srcStart: 0, destArr: result.digits, destStart: digitCount, hopeLength: result.digits.count - digitCount)
        
        let bits = shiftLength % BigInt.bitsPerDigit
        let rightBits = BigInt.bitsPerDigit - bits
        
        var lowIndex = result.digits.count - 1
        var leftIndex = lowIndex - 1
        for ; lowIndex > 0; --lowIndex, --leftIndex {
            result.digits[lowIndex] = ((result.digits[lowIndex] << bits) & BigInt.maxDigitVal) | ((result.digits[leftIndex] & highBitMasks[bits]) >> rightBits)
        }
        result.digits[0] = (result.digits[lowIndex] << bits) & BigInt.maxDigitVal
        result.isNeg = x.isNeg
        
        return result
    }
    //   RightShift_With_DigitsAndBits
    func BIShiftRight(x: BigInt, shiftLength: Int) -> BigInt {
        let result = BigInt(maxDigits: MAXDIGITS)
        
        let lowBitMasks: [Int] = [0x0000,
            0x0001, 0x0003, 0x0007, 0x000F,
            0x001F, 0x003F, 0x007F, 0x00FF,
            0x01FF, 0x03FF, 0x07FF, 0x0FFF,
            0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF]
        
        let digitCount = shiftLength / BigInt.bitsPerDigit
        result.digits = arrayCopy(x.digits, srcStart: digitCount, destArr: result.digits, destStart: 0, hopeLength: x.digits.count - digitCount)
        
        let bits = shiftLength % BigInt.bitsPerDigit
        let leftBits = BigInt.bitsPerDigit - bits
        
        var highIndex = 0
        var rightIndex = highIndex + 1
        for ; highIndex < result.digits.count - 1; ++highIndex, ++rightIndex {
            result.digits[highIndex] = (result.digits[highIndex] >> bits) | ((result.digits[rightIndex] & lowBitMasks[bits]) << leftBits)
        }
        result.digits[result.digits.count - 1] >>= bits
        result.isNeg = x.isNeg
        
        return result
    }
    //    LeftShift_Digitally
    func BIMultiplyByRadixPower(x: BigInt, powN: Int) -> BigInt {
        var result = BigInt(maxDigits: MAXDIGITS)
        result = BIShiftLeft(x, shiftLength: BigInt.BIRadixBits * powN)
        
        return result
    }
    //    RightShift_Digitally
    func BIDivideByRadixPower(x: BigInt, powN: Int) -> BigInt {
        var result = BigInt(maxDigits: MAXDIGITS)
        result = BIShiftRight(x, shiftLength: BigInt.BIRadixBits * powN)
        
        return result
    }
    //    Cut_BigIntDigitsArray_Digitally
    func BIModuloByRadixPower(x: BigInt, powN: Int) -> BigInt {
        let result = BigInt(maxDigits: MAXDIGITS)
        result.digits = arrayCopy(x.digits, srcStart: 0, destArr: result.digits, destStart: 0, hopeLength: powN)
//        result.isNeg = x.isNeg
        
        return result
    }
//----BigInt_BitBaseShift_Functions_To_Here----
    
//!!!!Here_Is_The_Divide_And_Modulo_Func!!!!____(x / y and x % y)
    func BIDivideModulo(x: BigInt, var y: BigInt) -> (q: BigInt, r: BigInt) {
        var q = BigInt(maxDigits: MAXDIGITS)
        var r = BigInt(maxDigits: MAXDIGITS)
        
        var xNZeroBits: Int = BINZeroBits(x)
        var yNZeroBits: Int = BINZeroBits(y)
        let ySign: Bool = y.isNeg

        //|x| < |y|
        if xNZeroBits < yNZeroBits {
            if x.isNeg {
                //kanbudongzhegeshihoudeyunsuana
                q = BigInt.BIOne()
                q.isNeg = !y.isNeg
                x.isNeg = false
                y.isNeg = false
                r = BISubtract(y, y: x)
                x.isNeg = true
                y.isNeg = ySign
            } else {
                q = BigInt.BIZero()
                r = BigInt.BICopy(x)
            }
            return (q, r)
        }
        
        q = BigInt.BIZero()
        r = x
        var xDigits: Int
        var yDigits: Int = Int(ceil(Double(yNZeroBits / BigInt.bitsPerDigit))) - 1 //Equals_To_BILowIndexNZero(y)
        var shiftCount: Int = 0
        while y.digits[yDigits] < BigInt.BIHalfRadix {
            y = BIShiftLeft(y, shiftLength: 1)
            ++shiftCount
            ++yNZeroBits
            yDigits = Int(ceil(Double(yNZeroBits) / Double(BigInt.bitsPerDigit))) - 1
        }
        
        r = BIShiftLeft(r, shiftLength: shiftCount)
        xNZeroBits += shiftCount
        xDigits = Int(ceil(Double(xNZeroBits) / Double(BigInt.bitsPerDigit))) - 1
        
        var temp = BigInt(maxDigits: MAXDIGITS)
        temp = BIMultiplyByRadixPower(y, powN: xDigits - yDigits)
        while BigInt.BICompare(r, y: temp) != -1 {
            ++q.digits[xDigits - yDigits]
            r = BISubtract(r, y: temp)
        }
        
        for var i = xDigits; i > yDigits; --i {
            let rAt_i: Int = (i >= r.digits.count) ? 0 : r.digits[i]
            let rAt_i_1: Int = (i - 1 >= r.digits.count) ? 0 : r.digits[i - 1]
            let rAt_i_2: Int = (i - 2 >= r.digits.count) ? 0 : r.digits[i - 2]
            let yAt_yDigits: Int = (yDigits >= y.digits.count) ? 0 : y.digits[yDigits]
            let yAt_yDigits_1: Int = (yDigits - 1 >= y.digits.count) ? 0 : y.digits[yDigits - 1]
            if rAt_i == yAt_yDigits {
                q.digits[i - yDigits - 1] = BigInt.maxDigitVal
            } else {
                q.digits[i - yDigits - 1] = (rAt_i * BigInt.BIRadix + rAt_i_1) / yAt_yDigits
            }
            
            var temp1: Int = q.digits[i - yDigits - 1] * (yAt_yDigits * BigInt.BIRadix + yAt_yDigits_1)
            var temp2: Int = rAt_i * BigInt.BIRadixSquare + rAt_i_1 * BigInt.BIRadix + rAt_i_2
            while temp1 > temp2 {
                --q.digits[i - yDigits - 1]
                temp1 = q.digits[i - yDigits - 1] * ((yAt_yDigits * BigInt.BIRadix) | yAt_yDigits_1)
                temp2 = rAt_i * BigInt.BIRadixSquare + rAt_i_1 * BigInt.BIRadix + rAt_i_2
            }
            
            temp = BIMultiplyByRadixPower(y, powN: i - yDigits - 1)
            r = BISubtract(r, y: BIMultiplyDigit(temp, y: q.digits[i - yDigits - 1]))
            if r.isNeg {
                r = BIAdd(r, y: temp)
                --q.digits[i - yDigits - 1]
            }
        }
        
        r = BIShiftRight(r, shiftLength: shiftCount)
        q.isNeg = x.isNeg != ySign
        if x.isNeg {
            if ySign {
                q = BIAdd(q, y: BigInt.BIOne())
            } else {
                q = BISubtract(q, y: BigInt.BIOne())
            }
            y = BIShiftRight(y, shiftLength: shiftCount)
            r = BISubtract(y, y: r)
        }
        
        if r.digits[0] == 0 && BILowIndexNZero(r) == 0 {
            r.isNeg = false
        }
        
        return (q, r)
    }
    
    func BIDivide(x: BigInt, y: BigInt) -> BigInt {
        return BIDivideModulo(x, y: y).q
    }
    
    func BIModulo(x: BigInt, y: BigInt) -> BigInt {
        return BIDivideModulo(x, y: y).r
    }
    
    func BIMultiplyMod(x: BigInt, y: BigInt, modulus: BigInt) -> BigInt {
        return BIModulo(BIMultiply(x, y: y), y: modulus)
    }
    
    func BIPowMod(x: BigInt, y: BigInt, modulus: BigInt) -> BigInt {
        var result = BigInt(maxDigits: MAXDIGITS)
        result = BigInt.BIOne()
        
        var xTemp: BigInt = x
        var yTemp: BigInt = y
        while true {
            if (yTemp.digits[0] & 1) != 0 {
                result = BIMultiplyMod(result, y: xTemp, modulus: modulus)
            }
            yTemp = BIShiftRight(yTemp, shiftLength: 1)
            if yTemp.digits[0] == 0 && BILowIndexNZero(yTemp) == 0 {
                break
            }
            xTemp = BIMultiplyMod(xTemp, y: xTemp, modulus: modulus)
        }
        
        return result
    }
}

