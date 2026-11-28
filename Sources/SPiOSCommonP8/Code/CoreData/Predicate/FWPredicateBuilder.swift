//
//  FWPredicateBuilder.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 21/11/26.
//

import CoreData

public protocol EntityKey {
    var keyPath: String { get }
}

public protocol EntityKeysProvider {
    associatedtype Key: RawRepresentable & EntityKey where Key.RawValue == String
}

/// A predicate builder designed to support three predicate-building approaches:
/// 1. **Format strings** (`NSPredicate(format:_:)` with `%K` and `%@`) — implemented first.
/// 2. **Direct programmatic construction** (`NSExpression` and `NSComparisonPredicate`) — active below.
/// 3. **Predicate templates** (`$VARIABLE` expressions resolved via `withSubstitutionVariables(_:)`) — planned third.
///
/// - Parameter Root: The Core Data entity class (`NSManagedObject` subclass) that
///   owns the attributes referenced in each predicate clause. Constraining `Root`
///   to `NSManagedObject` ensures the generated `NSPredicate` targets a Core Data
///   managed object model/fetch request rather than an arbitrary non-Core Data
///   Swift struct or plain class, and aligns with KVC / `#keyPath` attribute lookups.
public final class FWPredicateBuilder<Root: NSManagedObject> {

    /// Shorthand alias for `NSComparisonPredicate`.
    public typealias CP = NSComparisonPredicate

    // Constraining `Root: NSManagedObject` scopes this builder to Core Data entities,
    // which support KVC/SQLite `NSPredicate` evaluation and `#keyPath(Entity.property)`
    // references—unlike pure Swift value types or non-`NSManagedObject` classes.
    private var currentPredicate: NSPredicate?
    private var pendingJoin: NSCompoundPredicate.LogicalType?

    public init() {}

    /// Clears any accumulated predicates and pending logical operators so the
    /// builder instance can be reused for a new query.
    @discardableResult
    public func reset() -> Self {
        currentPredicate = nil
        pendingJoin = nil
        return self
    }

    /// Appends a comparison predicate clause using an Objective-C key path string
    /// such as `#keyPath(CDUser.age)` to avoid hardcoded attribute strings.
    ///
    /// - Parameters:
    ///   - not: When `true`, wraps this clause in `NSCompoundPredicate(type: .not, ...)`.
    ///     Defaults to `false`.
    ///   - keyPath: Attribute key path (e.g., `#keyPath(User.age)`).
    ///   - operator: Comparison operator to apply.
    ///   - value: Constant right-hand value to compare against.
    ///   - options: Comparison options such as `.caseInsensitive`. Defaults to `[]`.
    ///   - modifier: Comparison modifier such as `.direct` or `.any`. Defaults to `.direct`.
    /// - Returns: `self` for fluent method chaining.
    @discardableResult
    public func q(
        not: Bool = false,
        _ keyPath: String,
        _ operator: CP.Operator,
        _ value: Any?,
        options: CP.Options = [],
        modifier: CP.Modifier = .direct
    ) throws -> Self {
        let left = NSExpression(forKeyPath: keyPath)
        let right = NSExpression(forConstantValue: value)

        var nextPredicate: NSPredicate = CP(
            leftExpression: left,
            rightExpression: right,
            modifier: modifier,
            type: `operator`,
            options: options
        )

        // Wrap only this comparison clause in NOT when requested. (NSCompoundPredicate.LogicalType)
        if not {
            nextPredicate = NSCompoundPredicate(type: .not, subpredicates: [nextPredicate])
        }

        if let existing = currentPredicate {
            guard let joinType = pendingJoin else {
                throw Error.missingPredicate(
                    message: "Cannot append a predicate clause without calling 'and()' or 'or()' after the previous clause."
                )
            }
            currentPredicate = NSCompoundPredicate(
                type: joinType,
                subpredicates: [existing, nextPredicate]
            )
            pendingJoin = nil
        } else {
            currentPredicate = nextPredicate
        }

        return self
    }

    /// Joins the existing predicate with the next clause using logical `AND`.
    @discardableResult
    public func and() throws -> Self {
        guard currentPredicate != nil else {
            throw Error.missingPredicate(message: "Cannot apply 'and()' before adding a predicate")
        }
        pendingJoin = .and
        return self
    }

    /// Joins the existing predicate with the next clause using logical `OR`.
    @discardableResult
    public func or() throws -> Self {
        guard currentPredicate != nil else {
            throw Error.missingPredicate(message: "Cannot apply 'or()' before adding a predicate")
        }
        pendingJoin = .or
        return self
    }

    /// Finalizes and returns the composed `NSPredicate`, or `nil` if no clauses were added.
    public func build() -> NSPredicate? {
        currentPredicate
    }
}

//══════════════════════════════════════
// MARK: - Ext 1 - Error
//══════════════════════════════════════

public extension FWPredicateBuilder {
    enum Error: Swift.Error {
        case missingPredicate(message: String)
    }
}

//══════════════════════════════════════
// MARK: - Ext 2 - EntityKeysProvider
//══════════════════════════════════════

public extension FWPredicateBuilder where Root: EntityKeysProvider {
    @discardableResult
    func q(
        not: Bool = false,
        _ key: Root.Key,
        _ operator: CP.Operator,
        _ value: Any?,
        options: CP.Options = [],
        modifier: CP.Modifier = .direct
    ) throws -> Self {
        try q(
            not: not,
            key.keyPath,
            `operator`,
            value,
            options: options,
            modifier: modifier
        )
    }
}

//══════════════════════════════════════
// MARK: - Ext 3 - Demo
//══════════════════════════════════════

private final class DemoUser: NSManagedObject, EntityKeysProvider {
    @NSManaged var name: String
    @NSManaged var age: Int
    @NSManaged var isStudent: Bool

    enum Key: String, CaseIterable, EntityKey {
        case name
        case age
        case isStudent

        var keyPath: String {
            switch self {
            case .name: return #keyPath(DemoUser.name)
            case .age: return #keyPath(DemoUser.age)
            case .isStudent: return #keyPath(DemoUser.isStudent)
            }
        }
    }
}

extension FWPredicateBuilder: Demoable {
    public func demo() {
        let builder = FWPredicateBuilder<DemoUser>()

        // Single NOT clause
        _ = try? builder
            .reset()
            .q(not: true, .isStudent, .equalTo, true)
            .build()

        // Combined with AND
        _ = try? builder
            .reset()
            .q(.age, .greaterThanOrEqualTo, 18)
            .and()
            .q(not: true, .isStudent, .equalTo, true)
            .build()
    }
}
