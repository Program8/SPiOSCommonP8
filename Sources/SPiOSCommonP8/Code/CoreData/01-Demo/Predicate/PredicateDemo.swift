//
//  FWCDManager+Test+Predicate.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 24/11/26.
//

import Foundation
extension FWCDManager.Demo{
    class PredicateDemo{
        func demo(){
            ComparisonOperator().demo()
        }
    }
}
extension FWCDManager.Demo.PredicateDemo{
    class ComparisonOperator:FWLoggerDelegate{
        func demo(){
            like()
            equalTo()
        }
    }
}
extension FWCDManager.Demo.PredicateDemo.ComparisonOperator{
    func equalTo() {
        mLogInfo(msg: "")
        let createPredicateWithFormatString={
            self.mLogInfo(msg: "")
            let keyFirstName: String = "mFirstName"
            let valueFirstName: String = "John"
            // 1. Default behavior: "%K == %@“ : `==` is case-sensitive and diacritic-sensitive by default. "Jóhn","John","john" are all different.
            let predicate1 = NSPredicate(format: "%K == %@", keyFirstName, valueFirstName)
            print(predicate1.predicateFormat) // mFirstName == "John"
            var isMatch = predicate1.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // false
            isMatch = predicate1.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = predicate1.evaluate(with: [keyFirstName: "john"]); print(isMatch) // false
            // 2. Add comparison modifiers : "%K ==[cd] %@“ Now it is both case and diacritic insensitive. "Jóhn","John","john" are all same.
            let predicate2 = NSPredicate(format: "%K ==[cd] %@", keyFirstName, valueFirstName)
            print(predicate2.predicateFormat) // mFirstName ==[cd] "John"
            isMatch = predicate2.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // true
            isMatch = predicate2.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = predicate2.evaluate(with: [keyFirstName: "john"]); print(isMatch) // true
        }
        let createPredicateDirectlyInCode={
            
        }
        let createPredicateWithTemplate = {
            self.mLogInfo(msg: "")
            let keyFirstName: String = "mFirstName"
            let valueFirstName: String = "John"
            
            let template1 = NSPredicate(format: "%K == $firstName", keyFirstName)
            let predicate1 = template1.withSubstitutionVariables(["firstName": valueFirstName])
            print(predicate1.predicateFormat) // mFirstName == "John"
            
            var isMatch = predicate1.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // false
            isMatch = predicate1.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = predicate1.evaluate(with: [keyFirstName: "john"]); print(isMatch) // false
        }
        createPredicateWithFormatString()
        createPredicateDirectlyInCode()
        createPredicateWithTemplate()
    }
    func like() {
        mLogInfo(msg: "")
        let createPredicateWithFormatString = {
            self.mLogInfo(msg: "")
            let keyFirstName: String = "mFirstName"
            let valueFirstName: String = "John"
            
            // 1. Default behavior: "%K LIKE %@" is case-sensitive and diacritic-sensitive by default.Without wildcard characters (* or ?), LIKE requires an exact full-string match.
            let predicate1 = NSPredicate(format: "%K LIKE %@", keyFirstName, valueFirstName)
            print(predicate1.predicateFormat) // mFirstName LIKE "John"
            var isMatch = predicate1.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // false
            isMatch = predicate1.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = predicate1.evaluate(with: [keyFirstName: "john"]); print(isMatch) // false
            
            // 2. Comparison modifiers: "%K LIKE[cd] %@" is both case- and diacritic-insensitive.
            let predicate2 = NSPredicate(format: "%K LIKE[cd] %@", keyFirstName, valueFirstName)
            print(predicate2.predicateFormat) // mFirstName LIKE[cd] "John"
            isMatch = predicate2.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // true
            isMatch = predicate2.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = predicate2.evaluate(with: [keyFirstName: "john"]); print(isMatch) // true
            
            // 3. Multi-character wildcard (*): matches zero or more characters. Equivalent to BEGINSWITH ("Jo*"), ENDSWITH ("*hn"), or CONTAINS ("*oh*"). Where ("Jo*"), ("*hn"), ("*oh*") are search query string
            let beginsWithPredicate = NSPredicate(format: "%K LIKE[c] %@", keyFirstName, "Jo*")
            print(beginsWithPredicate.predicateFormat) // mFirstName LIKE[c] "Jo*"
            isMatch = beginsWithPredicate.evaluate(with: [keyFirstName: "Jo"]); print(isMatch) // true (0 chars after Jo)
            isMatch = beginsWithPredicate.evaluate(with: [keyFirstName: "Jonathan"]); print(isMatch) // true
            
            let endsWithPredicate = NSPredicate(format: "%K LIKE[c] %@", keyFirstName, "*hn")
            print(endsWithPredicate.predicateFormat) // mFirstName LIKE[c] "*hn"
            isMatch = endsWithPredicate.evaluate(with: [keyFirstName: "hn"]); print(isMatch) // true (0 chars before hn)
            isMatch = endsWithPredicate.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = endsWithPredicate.evaluate(with: [keyFirstName: "ROSHAN"]); print(isMatch) // false
            isMatch = endsWithPredicate.evaluate(with: [keyFirstName: "Aarav"]); print(isMatch) // false
            
            let containsPredicate = NSPredicate(format: "%K LIKE[c] %@", keyFirstName, "*oh*")
            print(containsPredicate.predicateFormat) // mFirstName LIKE[c] "*oh*"
            isMatch = containsPredicate.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true (0 chars before "oh", "n" after)
            isMatch = containsPredicate.evaluate(with: [keyFirstName: "MOHAN"]); print(isMatch) // true (case-insensitive [c])
            isMatch = containsPredicate.evaluate(with: [keyFirstName: "Aarav"]); print(isMatch) // false
            
            // 4. Single-character wildcard (?): matches exactly one character
            let singleCharPredicate = NSPredicate(format: "%K LIKE[c] %@", keyFirstName, "J?hn")
            print(singleCharPredicate.predicateFormat)// mFirstName LIKE[c] "J?hn"
            isMatch = singleCharPredicate.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = singleCharPredicate.evaluate(with: [keyFirstName: "Jahn"]); print(isMatch) // true
            isMatch = singleCharPredicate.evaluate(with: [keyFirstName: "Jhn"]); print(isMatch) // false (0 chars)
            isMatch = singleCharPredicate.evaluate(with: [keyFirstName: "Joohn"]); print(isMatch) // false (2 chars)
            
            // 5. Escaping literal * or ? in patterns using backslash (\).Useful when user input contains literal wildcard characters
            let escapedPattern = NSRegularExpression.escapedPattern(for: "John*") // or manual escaping: "John\\*"
            let literalWildcardPredicate = NSPredicate(format: "%K LIKE %@", keyFirstName, "John\\*")
            print(literalWildcardPredicate.predicateFormat)// mFirstName LIKE "John\\*"
            isMatch = literalWildcardPredicate.evaluate(with: [keyFirstName: "John*"]); print(isMatch) // true
            isMatch = literalWildcardPredicate.evaluate(with: [keyFirstName: "Johnny"]); print(isMatch) // false
            
            // 6. Nil / NSNull behavior: evaluating LIKE against nil returns false
            print("Nil / NSNull behavior")
            isMatch = predicate1.evaluate(with: [keyFirstName: NSNull()]); print(isMatch) // false
            isMatch = predicate1.evaluate(with: [:]); print(isMatch) // false
        }
        createPredicateWithFormatString()
    }
}
