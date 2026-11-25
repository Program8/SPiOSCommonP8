//
//  FWCDManager+Demo+PredicateDemo+ComparisonOperatorDemo.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 25/11/26.
//

import Foundation
extension FWCDManager.Demo.PredicateDemo{
    class ComparisonOperatorDemo:FWLoggerDelegate{
        func demo(){
            beginsWith()
//            like()
//            equalTo()
        }
    }
}
extension FWCDManager.Demo.PredicateDemo.ComparisonOperatorDemo{
    func equalTo() {
        mLogInfo(msg: "")
        let createPredicateWithFormatString={
            self.mLogInfo(msg: "")
            let keyFirstName: String = "mFirstName"
            let firstNameSearchText: String = "John"
            // 1. Default behavior: "%K == %@“ : `==` is case-sensitive and diacritic-sensitive by default. "Jóhn","John","john" are all different.
            let predicate1 = NSPredicate(format: "%K == %@", keyFirstName, firstNameSearchText)
            print(predicate1.predicateFormat) // mFirstName == "John"
            var isMatch = predicate1.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // false
            isMatch = predicate1.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = predicate1.evaluate(with: [keyFirstName: "john"]); print(isMatch) // false
            // 2. Add comparison modifiers : "%K ==[cd] %@“ Now it is both case and diacritic insensitive. "Jóhn","John","john" are all same.
            let predicate2 = NSPredicate(format: "%K ==[cd] %@", keyFirstName, firstNameSearchText)
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
            let firstNameSearchText: String = "John"
            
            let template1 = NSPredicate(format: "%K == $firstName", keyFirstName)
            let predicate1 = template1.withSubstitutionVariables(["firstName": firstNameSearchText])
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
            let firstNameSearchText: String = "John"
            
            // 1. Default behavior: "%K LIKE %@" is case-sensitive and diacritic-sensitive by default.Without wildcard characters (* or ?), LIKE requires an exact full-string match.
            let predicate1 = NSPredicate(format: "%K LIKE %@", keyFirstName, firstNameSearchText)
            print(predicate1.predicateFormat) // mFirstName LIKE "John"
            var isMatch = predicate1.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // false
            isMatch = predicate1.evaluate(with: [keyFirstName: "John"]); print(isMatch) // true
            isMatch = predicate1.evaluate(with: [keyFirstName: "john"]); print(isMatch) // false
            
            // 2. Comparison modifiers: "%K LIKE[cd] %@" is both case- and diacritic-insensitive.
            let predicate2 = NSPredicate(format: "%K LIKE[cd] %@", keyFirstName, firstNameSearchText)
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
    func beginsWith() {
        mLogInfo(msg: "")
        let createPredicateWithFormatString = {
            self.mLogInfo(msg: "")
            let keyFirstName: String = "mFirstName"
            let firstNameSearchText: String = "John"

            // 1. Default behavior: "%K BEGINSWITH %@" is case-sensitive and diacritic-sensitive by default."Jóhn", "John", "john", and "Johnny" are evaluated strictly according to case & diacritics.
            let predicate1 = NSPredicate(format: "%K BEGINSWITH %@", keyFirstName, firstNameSearchText)
            print(predicate1.predicateFormat) // mFirstName BEGINSWITH "John"
            var isMatch = predicate1.evaluate(with: [keyFirstName: "John"]); print(isMatch)   // true (exact full match also counts as beginning with "John")
            isMatch = predicate1.evaluate(with: [keyFirstName: "Johnny"]); print(isMatch) // true
            isMatch = predicate1.evaluate(with: [keyFirstName: "john"]); print(isMatch)   // false
            isMatch = predicate1.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch)   // false
            isMatch = predicate1.evaluate(with: [keyFirstName: "Aarav John"]); print(isMatch) // false (substring in middle/end does not match)

            // 2. Case-insensitive only: "%K BEGINSWITH[c] %@" ignores case, still sensitive to diacritics.
            let caseInsensitivePredicate = NSPredicate(format: "%K BEGINSWITH[c] %@", keyFirstName, firstNameSearchText)
            print(caseInsensitivePredicate.predicateFormat) // mFirstName BEGINSWITH[c] "John"
            isMatch = caseInsensitivePredicate.evaluate(with: [keyFirstName: "johnny"]); print(isMatch) // true
            isMatch = caseInsensitivePredicate.evaluate(with: [keyFirstName: "JOHN"]); print(isMatch)   // true
            isMatch = caseInsensitivePredicate.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch)   // false

            // 3. Diacritic-insensitive only: "%K BEGINSWITH[d] %@" ignores diacritics, still sensitive to case.
            let diacriticInsensitivePredicate = NSPredicate(format: "%K BEGINSWITH[d] %@", keyFirstName, firstNameSearchText)
            print(diacriticInsensitivePredicate.predicateFormat) // mFirstName BEGINSWITH[d] "John"
            isMatch = diacriticInsensitivePredicate.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch)   // true
            isMatch = diacriticInsensitivePredicate.evaluate(with: [keyFirstName: "Jóhnny"]); print(isMatch) // true
            isMatch = diacriticInsensitivePredicate.evaluate(with: [keyFirstName: "jóhn"]); print(isMatch)   // false

            // 4. Case- and diacritic-insensitive: "%K BEGINSWITH[cd] %@" ignores both case and diacritics.
            let cdPredicate = NSPredicate(format: "%K BEGINSWITH[cd] %@", keyFirstName, firstNameSearchText)
            print(cdPredicate.predicateFormat) // mFirstName BEGINSWITH[cd] "John"
            isMatch = cdPredicate.evaluate(with: [keyFirstName: "Jóhn"]); print(isMatch) // true
            isMatch = cdPredicate.evaluate(with: [keyFirstName: "john"]); print(isMatch) // true
            isMatch = cdPredicate.evaluate(with: [keyFirstName: "jóhnny"]); print(isMatch) // true

            // 5. Literal characters (* and ?): BEGINSWITH does NOT treat * or ? as wildcards.No escaping is needed or helpful for * or ? because they match literally.
            let literalWildcardCharPredicate = NSPredicate(format: "%K BEGINSWITH[c] %@", keyFirstName, "Jo*")
            print(literalWildcardCharPredicate.predicateFormat) // mFirstName BEGINSWITH[c] "Jo*"
            isMatch = literalWildcardCharPredicate.evaluate(with: [keyFirstName: "Jo*nathan"]); print(isMatch) // true
            isMatch = literalWildcardCharPredicate.evaluate(with: [keyFirstName: "Jonathan"]); print(isMatch)   // false

            let literalQuestionCharPredicate = NSPredicate(format: "%K BEGINSWITH[c] %@", keyFirstName, "J?hn")
            print(literalQuestionCharPredicate.predicateFormat) // mFirstName BEGINSWITH[c] "J?hn"
            isMatch = literalQuestionCharPredicate.evaluate(with: [keyFirstName: "J?hnDoe"]); print(isMatch) // true
            isMatch = literalQuestionCharPredicate.evaluate(with: [keyFirstName: "JohnDoe"]); print(isMatch)  // false

            // 6. Empty prefix & whitespace edge cases
            let emptyPrefixPredicate = NSPredicate(format: "%K BEGINSWITH %@", keyFirstName, "")
            print(emptyPrefixPredicate.predicateFormat) // mFirstName BEGINSWITH ""
            isMatch = emptyPrefixPredicate.evaluate(with: [keyFirstName: "John"]); print(isMatch) // false
            isMatch = emptyPrefixPredicate.evaluate(with: [keyFirstName: ""]); print(isMatch)     // false

            // 7. Nil / NSNull / missing key behavior
            print("Nil / NSNull / missing key behavior")
            isMatch = predicate1.evaluate(with: [keyFirstName: NSNull()]); print(isMatch) // false
            isMatch = predicate1.evaluate(with: [:]); print(isMatch)                      // false
        }
        createPredicateWithFormatString()
    }
}
