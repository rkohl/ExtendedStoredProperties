//
// ExtendedStoredPropertiesObjects.swift
// Extended Stored Properties
//
// Created by Ryan Kohl on 3/13/21.
// Copyright (c) 2021 Kohl Development Group LLC
//
// The MIT License (MIT)
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

@propertyWrapper
private struct WeakExtendedStoredProperty<Wrapped> {
    private weak var storage: AnyObject?
    private var value: Wrapped? {
        get { storage as? Wrapped }
        set {
            storage = newValue.map {
                let asObject = $0 as AnyObject
                assert(asObject === $0 as AnyObject)
                return asObject
            }
        }
    }
    
    public init(_ value: Wrapped? = nil) {
        self.value = value
    }
    
    public var wrappedValue: Wrapped? {
        get { value is NSNull ? nil : value }
        set { value = newValue }
    }
}

internal struct ExtendedStoredProperties {
    static private let queueName = "SynchronizedExtendedStoredPropertiesAccess"
    static private let accessQueue = DispatchQueue(label: queueName,
                                                   attributes: .concurrent)
    static private var property = [ExtendedStoredPropertyKey<AnyObject>: Any?]()
    
    internal static func remove() {
        if property.count == 0 { return }
        
        accessQueue.async(flags: .barrier) {
            property = property.filter({$0.key.wrappedValue != nil})
        }
    }
    
    internal static func get<T>(_ key: ExtendedStoredPropertyKey<AnyObject>,
                                policy: ExtendedStoredPropertyPolicy) -> T? {
        Self.remove()
        var res: T?
        accessQueue.sync {
            if policy == .assign {
                let weakObject = property[key] as? WeakExtendedStoredProperty<Any>
                res = weakObject?.wrappedValue as? T
            }
            else {
                res = property[key] as? T
            }
        }
        return res
    }

    internal static func haveKey(_ key: ExtendedStoredPropertyKey<AnyObject>,
                                 policy: ExtendedStoredPropertyPolicy) -> Bool {
        var res = false
        accessQueue.sync {
            res = property.contains(where: { $0.key == key })
        }
        return res

    }
    
    internal static func set(_ key: ExtendedStoredPropertyKey<AnyObject>,
                             value: Any,
                             policy: ExtendedStoredPropertyPolicy) {
        Self.remove()
        let flag: DispatchWorkItemFlags = policy.isAtomic ? .barrier : .detached
        
        accessQueue.async(flags: flag) {
            var toStore = value
            if policy == .assign {
                toStore = WeakExtendedStoredProperty(value)
            } else if policy.isCopy {
                toStore = (value as! NSCopying).copy()
            }
            property[key, default: nil] = toStore
        }
    }
}
