//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import Nimble
import Quick
@testable import XrayKit

class SQLEventSpecs: QuickSpec {
    override func spec() {
        
        describe("SQL event") {
            context("without paramaters") {
                let sut = Event(name: "my_event")
                
                describe("binds") {
                    it("contains name") {
                        expect(sut.binds["name"] as? String).to(equal("my_event"))
                    }
                    
                    it("contains createdAt") {
                        expect(sut.binds["createdAt"] as? NSNumber).notTo(equal(0))
                    }
                    
                    it("contains updatedAt") {
                        expect(sut.binds["updatedAt"] as? NSNumber).notTo(equal(0))
                    }
                }
            }
        }
    }
}
