//
//  FWPredicateBuilder.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 21/11/26.
//
import CoreData
import Foundation

public enum FWStringMatchOptions {
    case exact
    case caseInsensitive
    case diacriticInsensitive
    case caseAndDiacriticInsensitive

    public var modifierSuffix: String {
        switch self {
        case .exact:
            return ""
        case .caseInsensitive:
            return "[c]"
        case .diacriticInsensitive:
            return "[d]"
        case .caseAndDiacriticInsensitive:
            return "[cd]"
        }
    }
}

/// A predicate builder designed to support three predicate-building approaches:
/// 1. **Format strings** (`NSPredicate(format:_:)` with `%K` and `%@`) — implemented first.
/// 2. **Direct programmatic construction** (`NSExpression` and `NSComparisonPredicate`) — planned next.
/// 3. **Predicate templates** (`$VARIABLE` expressions resolved via `withSubstitutionVariables(_:)`) — planned third.
///
/// Designed for use across in-memory evaluation (`evaluate(with:)`) and Core Data fetches while keeping
/// string modifiers (`[c]`, `[d]`, `[cd]`), wildcard escaping, and store compatibility consistent.
public final class FWPredicateBuilder {
    private var subpredicates: [NSPredicate] = []

    public init() {}

    // MARK: - Wildcard & Escaping Helpers

    /// Escapes `\`, `*`, and `?` so user input is treated literally inside `LIKE` patterns.
    public static func escapeLikePattern(_ input: String) -> String {
        return input
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "*", with: "\\*")
            .replacingOccurrences(of: "?", with: "\\?")
    }

    // MARK: - Format-String Builders

    @discardableResult
    public func equalTo(
        key: String,
        value: CVarArg,
        options: FWStringMatchOptions = .exact
    ) -> Self {
        let format = "%K ==\(options.modifierSuffix) %@"
        subpredicates.append(NSPredicate(format: format, key, value))
        return self
    }

    @discardableResult
    public func notEqualTo(
        key: String,
        value: CVarArg,
        options: FWStringMatchOptions = .exact
    ) -> Self {
        let format = "%K !=\(options.modifierSuffix) %@"
        subpredicates.append(NSPredicate(format: format, key, value))
        return self
    }

    @discardableResult
    public func beginsWith(
        key: String,
        searchText: String,
        options: FWStringMatchOptions = .caseAndDiacriticInsensitive,
        ignoreEmptyQuery: Bool = true
    ) -> Self {
        if ignoreEmptyQuery && searchText.isEmpty {
            return self
        }
        let format = "%K BEGINSWITH\(options.modifierSuffix) %@"
        subpredicates.append(NSPredicate(format: format, key, searchText))
        return self
    }

    @discardableResult
    public func endsWith(
        key: String,
        searchText: String,
        options: FWStringMatchOptions = .caseAndDiacriticInsensitive,
        ignoreEmptyQuery: Bool = true
    ) -> Self {
        if ignoreEmptyQuery && searchText.isEmpty {
            return self
        }
        let format = "%K ENDSWITH\(options.modifierSuffix) %@"
        subpredicates.append(NSPredicate(format: format, key, searchText))
        return self
    }

    @discardableResult
    public func contains(
        key: String,
        searchText: String,
        options: FWStringMatchOptions = .caseAndDiacriticInsensitive,
        ignoreEmptyQuery: Bool = true
    ) -> Self {
        if ignoreEmptyQuery && searchText.isEmpty {
            return self
        }
        let format = "%K CONTAINS\(options.modifierSuffix) %@"
        subpredicates.append(NSPredicate(format: format, key, searchText))
        return self
    }

    /// Passes a pre-built `LIKE` pattern (e.g., `"Jo*"`, `"*oh*"`, `"J?hn"`) directly.
    @discardableResult
    public func like(
        key: String,
        pattern: String,
        options: FWStringMatchOptions = .caseAndDiacriticInsensitive
    ) -> Self {
        let format = "%K LIKE\(options.modifierSuffix) %@"
        subpredicates.append(NSPredicate(format: format, key, pattern))
        return self
    }

    /// Escapes literal `\`, `*`, and `?` in `searchText` before wrapping with `*` wildcards.
    @discardableResult
    public func likeLiteralContains(
        key: String,
        searchText: String,
        options: FWStringMatchOptions = .caseAndDiacriticInsensitive,
        ignoreEmptyQuery: Bool = true
    ) -> Self {
        if ignoreEmptyQuery && searchText.isEmpty {
            return self
        }
        let escaped = Self.escapeLikePattern(searchText)
        return like(key: key, pattern: "*\(escaped)*", options: options)
    }

    @discardableResult
    public func greaterThan(key: String, value: CVarArg) -> Self {
        subpredicates.append(NSPredicate(format: "%K > %@", key, value))
        return self
    }

    @discardableResult
    public func lessThan(key: String, value: CVarArg) -> Self {
        subpredicates.append(NSPredicate(format: "%K < %@", key, value))
        return self
    }

    @discardableResult
    public func between(key: String, lower: CVarArg, upper: CVarArg) -> Self {
        subpredicates.append(NSPredicate(format: "%K BETWEEN %@", key, [lower, upper]))
        return self
    }

    @discardableResult
    public func `in`(key: String, values: [CVarArg]) -> Self {
        subpredicates.append(NSPredicate(format: "%K IN %@", key, values))
        return self
    }

    @discardableResult
    public func addFormat(_ format: String, _ args: CVarArg...) -> Self {
        subpredicates.append(NSPredicate(format: format, argumentArray: args))
        return self
    }

    // MARK: - Compound Output

    public func buildAnd() -> NSPredicate {
        guard !subpredicates.isEmpty else { return NSPredicate(value: true) }
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }

    public func buildOr() -> NSPredicate {
        guard !subpredicates.isEmpty else { return NSPredicate(value: false) }
        return NSCompoundPredicate(orPredicateWithSubpredicates: subpredicates)
    }
}
