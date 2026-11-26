//
//  Demoable.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 26/11/26.
//

// Using Composite Design Pattern
// 1. Component or Node
public protocol Demoable{func demo()}
// 2. Leaf : All Demo Examples like Struct (CRUD Operation)

// 3. Composite
public struct SwiftDemo: Demoable {
    public let arr : [Demoable]
    public init(arr: [Demoable]) {
        self.arr = arr
    }
    public func demo() {
        arr.forEach{$0.demo()}
    }
}
