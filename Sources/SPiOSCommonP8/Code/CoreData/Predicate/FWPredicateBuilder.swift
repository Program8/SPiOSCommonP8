//
//  FWPredicateBuilder.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 21/11/26.
//
import CoreData
import Foundation

public final class FWPredicateBuilder<Entity: NSManagedObject> {
    private var predicates: [NSPredicate] = []

    public init(_ predicates: [NSPredicate] = []) {
        self.predicates = predicates
    }

    // MARK: - Equality & Comparisons

    @discardableResult
    public func equals<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, _ value: Value) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K == %@", key, value))
        return self
    }

    @discardableResult
    public func equals<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value?>, _ value: Value?) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        if let value {
            predicates.append(NSPredicate(format: "%K == %@", key, value))
        } else {
            predicates.append(NSPredicate(format: "%K == nil", key))
        }
        return self
    }

    @discardableResult
    public func notEquals<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, _ value: Value) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K != %@", key, value))
        return self
    }

    @discardableResult
    public func greaterThan<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, _ value: Value) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K > %@", key, value))
        return self
    }

    @discardableResult
    public func greaterThanOrEqual<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, _ value: Value) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K >= %@", key, value))
        return self
    }

    @discardableResult
    public func lessThan<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, _ value: Value) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K < %@", key, value))
        return self
    }

    @discardableResult
    public func lessThanOrEqual<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, _ value: Value) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K <= %@", key, value))
        return self
    }

    @discardableResult
    public func between<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, min: Value, max: Value) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K BETWEEN {%@, %@}", key, min, max))
        return self
    }

    @discardableResult
    public func isIn<Value: CVarArg>(_ keyPath: KeyPath<Entity, Value>, values: [Value]) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        predicates.append(NSPredicate(format: "%K IN %@", key, values))
        return self
    }

    // MARK: - String Helpers

    @discardableResult
    public func contains(
        _ keyPath: KeyPath<Entity, String?>,
        _ substring: String,
        caseInsensitive: Bool = true
    ) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        let modifier = caseInsensitive ? "[c]" : ""
        predicates.append(NSPredicate(format: "%K CONTAINS%@ %@", key, modifier, substring))
        return self
    }

    @discardableResult
    public func beginsWith(
        _ keyPath: KeyPath<Entity, String?>,
        _ prefix: String,
        caseInsensitive: Bool = true
    ) -> Self {
        let key = NSExpression(forKeyPath: keyPath).keyPath
        let modifier = caseInsensitive ? "[c]" : ""
        predicates.append(NSPredicate(format: "%K BEGINSWITH%@ %@", key, modifier, prefix))
        return self
    }

    // MARK: - Escape Hatches & Reset

    @discardableResult
    public func add(_ predicate: NSPredicate) -> Self {
        predicates.append(predicate)
        return self
    }

    @discardableResult
    public func add(
        leftExpression: NSExpression,
        rightExpression: NSExpression,
        operatorType: NSComparisonPredicate.Operator,
        modifier: NSComparisonPredicate.Modifier = .direct,
        options: NSComparisonPredicate.Options = []
    ) -> Self {
        let comparison = NSComparisonPredicate(
            leftExpression: leftExpression,
            rightExpression: rightExpression,
            modifier: modifier,
            type: operatorType,
            options: options
        )
        predicates.append(comparison)
        return self
    }

    @discardableResult
    public func reset() -> Self {
        predicates.removeAll()
        return self
    }

    // MARK: - Build

    public func buildAnd() -> NSPredicate? {
        guard !predicates.isEmpty else { return nil }
        return NSCompoundPredicate(type: .and, subpredicates: predicates)
    }

    public func buildOr() -> NSPredicate? {
        guard !predicates.isEmpty else { return nil }
        return NSCompoundPredicate(type: .or, subpredicates: predicates)
    }
}
