//
//  Encryptor.swift
//  Login_RSA
//
//  Created by 苏翔宇 on 12/4/15.
//  Copyright © 2015 苏翔宇. All rights reserved.
//

import Foundation

class Encryptor {
    
    var message: String
    var exponentStr: String
    var modulusStr: String
    
    init(message: String, exponentStr: String, modulusStr: String) {
        self.message = message
        self.exponentStr = exponentStr
        self.modulusStr = modulusStr
    }
    
    init(message: String) {
        self.message = message
        self.exponentStr = "010001"
        self.modulusStr = "00b6b7f8531b19980c66ae08e3061c6295a1dfd9406b32b202a59737818d75dea03de45d44271a1473af8062e8a4df927f031668ba0b1ec80127ff323a24cd0100bef4d524fdabef56271b93146d64589c9a988b67bc1d7a62faa6c378362cfd0a875361ddc7253aa0c0085dd5b17029e179d64294842862e6b0981ca1bde29979"
    }
    
    func generateKeyPair(exponentStr: String, modulusStr: String) -> (exponent: BigInt, modulus: BigInt, keySize: Int){
        let converter = Converter()
        
        let exponent: BigInt = converter.BIFromHexString(exponentStr)
        let modulus: BigInt = converter.BIFromHexString(modulusStr)
        let keySize: Int = 2 * converter.BILowIndexNZero(modulus)
        
        return (exponent, modulus, keySize)
    }

    func encrypt() -> String {
        let converter = Converter()
        let calculator = Calculator()
        
        let exponent: BigInt = generateKeyPair(self.exponentStr, modulusStr: self.modulusStr).exponent
        let modulus: BigInt = generateKeyPair(self.exponentStr, modulusStr: self.modulusStr).modulus
        let keySize: Int = generateKeyPair(self.exponentStr, modulusStr: self.modulusStr).keySize
        
        var result: String = ""
        
        var messageInArray = [Int]()
        var indexInArray: Int = 0
        while indexInArray < message.characters.count {
            messageInArray.append(message[message.startIndex.advancedBy(indexInArray)].toInt())
            indexInArray++
        }
        while messageInArray.count % keySize != 0 {
            messageInArray.append(0)
        }
        
        var i: Int; var j: Int; var k: Int
        for i = 0; i < messageInArray.count; i += keySize {
            let block = BigInt(maxDigits: MAXDIGITS)
            j = 0
            for k = i; k < i + keySize; ++j {
                block.digits[j] = messageInArray[k++]
                block.digits[j] += messageInArray[k++] << 8
            }
            
            let crypt: BigInt = calculator.BIPowMod(block, y: exponent, modulus: modulus)
            let text: String = converter.BIToHexString(crypt)
            result += text + " "
        }
        
        let subStrToIndex: Int = result.characters.count - 1
        
        return result.substringWithRange(Range<String.Index>(start: result.startIndex, end: result.startIndex.advancedBy(subStrToIndex)))
    }
}
