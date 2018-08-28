//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import CommonCrypto

protocol Signer {
    
    func sign(data: Data) -> Data
    func sing(data: Data) -> String
}

struct HMACSigner: Signer {
    let apiKey: Data
    
    func sign(data: Data) -> Data {
        
        var signedData = Data()
        apiKey.withUnsafeBytes { (buffer: UnsafePointer<Int8>)  in
            
            
            let dataLen = data.count
            data.withUnsafeBytes { (rawData: UnsafePointer<Int8>) in
                let digestLen = Int(CC_SHA512_DIGEST_LENGTH)
                
                let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512), buffer, apiKey.count, rawData, dataLen, result)
                signedData = NSData(bytes: result, length: digestLen) as Data
            }
            
        }
        return signedData
    }
    
    func sing(data: Data) -> String {
        return sign(data: data).base64EncodedString()
    }
}
