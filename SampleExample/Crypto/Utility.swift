//
//  Utility.swift
//  Crypto
//
//  Created by Deepak Badiger on 12/19/18.
//  Copyright © 2018 Deepak Badiger. All rights reserved.
//

import Foundation

class Utility {
    
    class func callOpenSSLMethods() {
        var Key1:DES_cblock = (0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11)
        var Key2:DES_cblock = (0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22)
        var Key3:DES_cblock = (0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33)
        
        var ks1 = DES_key_schedule()
        var ks2 = DES_key_schedule()
        var ks3 = DES_key_schedule()
        
        /* Input data to encrypt */
        let input_data:[UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05]
        
        /* Init vector */
        var iv:DES_cblock = (0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
        DES_set_odd_parity(&iv);
        
        print("DES_set_key_checked")
        print(DES_set_key_checked(&Key1, &ks1))
        print(DES_set_key_checked(&Key2, &ks2))
        print(DES_set_key_checked(&Key3, &ks3))
        
        print("DES_key_schedule")
        print(ks1, ks2, ks3)
        
        /* Buffers for Encryption and Decryption */
        var cipher:[UInt8] = [UInt8](repeating: 0, count: input_data.count)
        var text:[UInt8] = [UInt8](repeating: 0, count: input_data.count)
        
        /* Triple-DES CBC Encryption */
        DES_ede3_cbc_encrypt(input_data, &cipher, MemoryLayout.size(ofValue: input_data), &ks1, &ks2, &ks3, &iv, DES_ENCRYPT)
        print("Cipher")
        print(cipher)
        let cipherNonMutable = cipher
        
        /* Triple-DES CBC Decryption */
        memset(&iv, 0, MemoryLayout.size(ofValue: input_data))
        DES_set_odd_parity(&iv)
        DES_ede3_cbc_encrypt(cipherNonMutable, &text, MemoryLayout.size(ofValue: input_data), &ks1, &ks2, &ks3, &iv, DES_DECRYPT)
        
        print("Decrypt")
        print(text)
    }
    
    class func callElipticalCurve() {
        let group = EC_GROUP_new_by_curve_name(NID_X9_62_prime256v1)
        let bignum = BN_new()!
        
        let cofactorReturnCode = EC_GROUP_get_cofactor(group, bignum, nil)
        let cString = BN_bn2dec(bignum)!
        
        let cofactor = String.init(cString: cString)
        let expectedNumber = "1"
        let expectedCode: Int32 = 1
        
        print(cofactorReturnCode, expectedCode)
        print(cofactor, expectedNumber)
    }
}
