//
//  main.swift
//  Login_RSA
//
//  Created by 苏翔宇 on 12/1/15.
//  Copyright © 2015 苏翔宇. All rights reserved.
//

import Foundation

let modulus: String = "00b6b7f8531b19980c66ae08e3061c6295a1dfd9406b32b202a59737818d75dea03de45d44271a1473af8062e8a4df927f031668ba0b1ec80127ff323a24cd0100bef4d524fdabef56271b93146d64589c9a988b67bc1d7a62faa6c378362cfd0a875361ddc7253aa0c0085dd5b17029e179d64294842862e6b0981ca1bde29979"

let exponent: String = "010001"

let encryptor = Encryptor(message: "111111")

let passwd: String = encryptor.encrypt()

print("passwd:", passwd)
