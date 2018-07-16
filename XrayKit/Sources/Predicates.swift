//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

enum PredicateError: Error {
    case operandNotFound(String)
}

extension NSPredicate {

    static var operatorMap = [
        "contains": "CONTAINS",
        "in": "IN",
        "eq": "=",
        "gt": ">",
        "gte": ">=",
        "lt": "<",
        "lte": "<="
    ]

    /**
        Creates a predicate with an key path, operators from the backend and values.
        The supported operators are: `contains`, `in`, `eq`, `gt`, `gte`, `lt`, `lte` and are translated to their NSPredicate counterparts.
        Each operator can be prefixed with `not_`

        If an operator does not have a NSPredicate counterpart, it will be used as it is in the NSPredicate

        - parameter valueKeyPath: The key path to look for the value. E.g `event.properties.item_name`
        - parameter xoperator: The xray operator from the xray backend.
        - parameter arguments: The arguments to be matched against the values
    */
    static func predicateWithValueKeyPath(valueKeyPath: String, xoperator: String, arguments: Any) -> NSPredicate {
        var operand = xoperator
        var negate = false
        if operand.hasPrefix("not_") {
            negate = true
            operand = operand.replacingOccurrences(of: "not_", with: "")
        }

        let predicateOperand = operatorMap[operand] ?? operand

        var predicate = NSPredicate(format: "%K \(predicateOperand) %@", argumentArray: [valueKeyPath, arguments])

        if negate {
            predicate = NSCompoundPredicate.init(notPredicateWithSubpredicate: predicate)
        }
        return predicate
    }
}
