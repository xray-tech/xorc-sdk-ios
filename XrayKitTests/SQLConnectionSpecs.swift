//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation
import Quick
import Nimble
@testable import XrayKit


class SQLConnectionSpecs: QuickSpec {
    
    override func spec() {
        
        describe("SQLConnection") {
            
            beforeEach {
                
            }
            
            context("when executing a plain request") {
                it("works") {
                      expect(1).to(equal(1))
                }
            }
        }
    }
}
