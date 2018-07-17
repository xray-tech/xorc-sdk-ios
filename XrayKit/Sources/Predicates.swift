//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import Foundation

enum PredicateError: Error {
    case operandNotFound(String)
    case invalidFilter(String)
    case invalidLogicalType(String)
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

    static func makePredicate(filters: [String: Any]) throws  -> NSPredicate {
        let predicates = try makePredicates(filters: filters)
        if predicates.count > 1 {
            // todo + tests
        }
        guard let predicate = predicates.first else {
            // throw
            fatalError()
        }
        return predicate
    }

    private static func makePredicates(filters: [String: Any]) throws  -> [NSPredicate]  {
        var predicates = [NSPredicate]()
        try cumulate(predicates: &predicates, filters: filters)
        return predicates
    }

    private static func cumulate(predicates: inout [NSPredicate], filters: Any?) throws {
        guard let filters = filters else {
            // end of recursion
            return
        }

        // list of filters, we cumulate them
        if let filters = filters as? [Any] {
            var arrayPredicates = [NSPredicate]()
            for filter in filters {
                try cumulate(predicates: &arrayPredicates, filters: filter)
            }
            predicates.append(contentsOf: arrayPredicates)

            return
        }

        // dictionary of predicates
        if let filters = filters as? [String: Any] {

            guard let xoperator = filters.keys.first else {
                // todo throw
                fatalError()
            }

            // simple filter e.g. {"event.properties.item_name":{"eq":"iPhone"}}
            // create and end recursion
            if xoperator.isSimpleOperator() {
                let predicate = try makePredicate(simpleFilter: filters)
                predicates.append(predicate)
                return
            }

            // logical operator AND or OR must have an array as unique child
            // {"AND":[{"event.properties.item_name":{"eq":"iPhone"}},{"event.properties.item_description":{"eq":"Apple"}}]}
            guard let childArguments = filters[xoperator] as? [Any] else {
                throw PredicateError.invalidFilter("Operator \(xoperator) must have an array as child")
            }

            let logicalType = try xoperator.logicalType()

            // recursively cumulate the child predicates and combine them either with AND or OR
            var children = [NSPredicate]()
            try cumulate(predicates: &children, filters: childArguments)
            let combinedLogicalPredicate = NSCompoundPredicate(type: logicalType, subpredicates: children)
            predicates.append(combinedLogicalPredicate)
        }
    }

    /**
    Creates a simple leaf predicate from a simple dictionary predicate. For instance
    { "event.properties.item_description": { "eq": "Apple" } }

    The dictionary must have a single key entry
    - parameter simpleFilter: The dictionary definition of a simple filter

*/
    private static func makePredicate(simpleFilter: [String: Any]) throws -> NSPredicate {

        // the first dictionary entry is the key path of our value. e.g "event.properties.item_description"
        guard let valueKeyPath = simpleFilter.keys.first, simpleFilter.count == 1 else {
            throw PredicateError.invalidFilter("Expected 1 key/value got \(simpleFilter.count): \(simpleFilter)")
        }
        // get the content of the simple filter: { "eq": "Apple" }
        guard let filterContent = simpleFilter[valueKeyPath] as? [String: Any] else {
            throw PredicateError.invalidFilter("Expected a filter content at key \(valueKeyPath), got:")
        }

        // get the operand for this value key path, e.g. "eq"
        guard let xoperator = filterContent.keys.first, filterContent.count == 1 else {
            throw PredicateError.invalidFilter("Expected a filter operator at 1st key \(valueKeyPath)")
        }

        // and the arguments, e.g. "Apple"
        guard let operand = filterContent.values.first  else {
            throw PredicateError.invalidFilter("Expected a filter operand at 1st key \(valueKeyPath).\(xoperator)")
        }
        return makePredicate(valueKeyPath: valueKeyPath, xoperator: xoperator, arguments: operand)
    }

    /**
        Creates a predicate with an key path, operators from the backend and values.
        The supported operators are: `contains`, `in`, `eq`, `gt`, `gte`, `lt`, `lte` and are translated to their NSPredicate counterparts.
        Each operator can be prefixed with `not_`

        If an operator does not have a NSPredicate counterpart, it will be used as it is in the NSPredicate

        - parameter valueKeyPath: The key path to look for the value. E.g `event.properties.item_name`
        - parameter xoperator: The xray operator from the xray backend.
        - parameter arguments: The arguments to be matched against the values
    */
    static func makePredicate(valueKeyPath: String, xoperator: String, arguments: Any) -> NSPredicate {
        var operand = xoperator
        var negate = false
        if operand.hasPrefix("not_") {
            negate = true
            operand = operand.replacingOccurrences(of: "not_", with: "")
        }

        let predicateOperand = operatorMap[operand] ?? operand

        var predicate = NSPredicate(format: "%K \(predicateOperand) %@", argumentArray: [valueKeyPath, arguments])

        if negate {
            predicate = NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
        }
        return predicate
    }



}

private extension String {

    /// returns true when the string is a key path such as  "event.properties.item_name"
    func isSimpleOperator() -> Bool {
        return !isANDOperator() && !isOROperator()
    }

    func isANDOperator() -> Bool {
        return self.uppercased() == "AND"
    }

    func isOROperator() -> Bool {
        return self.uppercased() == "OR"
    }

    func logicalType() throws -> NSCompoundPredicate.LogicalType {
        if isANDOperator() {
            return .and
        }
        if isOROperator() {
            return .or
        }
        throw  PredicateError.invalidLogicalType("The logical type must be either AND or OR")
    }
}
