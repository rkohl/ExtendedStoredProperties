//
//  ExtendedStoredPropertyKey.swift
//  
//
//  Created by Thomas on 09/07/2020.
//

import Foundation

@propertyWrapper
internal struct ExtendedStoredPropertyKey<Wrapped: AnyObject> {
    private weak var object: AnyObject?
    private var value: Wrapped? {
        get { object as? Wrapped }
        set { object = newValue as AnyObject? }
    }
    private var key: Int
    
    public init<T: Hashable>(_ object: Wrapped? = nil, key: T) {
        self.key = key.hashValue
        self.value = object
    }
    
    public var wrappedValue: Wrapped? {
        get { value is NSNull ? nil : value }
        set { value = newValue }
    }
}

extension ExtendedStoredPropertyKey: Hashable {
    public static func == (lhs: ExtendedStoredPropertyKey<Wrapped>,
                           rhs: ExtendedStoredPropertyKey<Wrapped>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(unsafeBitCast(value, to: Int.self))
        hasher.combine(key)
    }
}
