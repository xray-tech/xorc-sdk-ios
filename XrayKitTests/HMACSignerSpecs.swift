//
//  HMACSignerSpecs.swift
//  XrayKit
//
//  Created by Jan Chaloupecky on 28.08.18.
//  Copyright © 2018 360dialog. All rights reserved.
//

import Quick
import Nimble
@testable import XrayKit

class HMACSignerSpecs: QuickSpec {
    
    
    
    override func spec() {
        
        fdescribe("HMACSigner") {
            
            var sut: HMACSigner!
            
            context("given a signer with a valid key") {
                var expected: String!
                var sign: String!
                var signature: String!
                
                beforeEach {
                    sut = HMACSigner(apiKey: "4f148164dc526beb3f913336833bd032265e2c1a0a4a629a8838ede3e5589a61".dataFromHexString())
                }
                
                context("and signing 'Hello world' data") {
                    
                    beforeEach {
                        sign = "Hello world"
                        expected = "GeV/idKpqn8bVkLGkOoEZrUus0VoY2/4ixpgUITHn2UwZmQzYssKM9mvnPCz9dlHrSpoe1E6cGAiiWQxooApcA=="
                        signature = sut.sign(data: sign.data(using: .utf8)!).base64EncodedString()
                    }
                    
                    it("generates a valid signature") {
                        expect(signature).to(equal(expected))
                    }
                }
            }
        }
    }
}
