//
//  ExtendedPropertiesObjects.swift
//
//
//  Created by Thomas on 09/07/2020.
//

import Foundation

@propertyWrapper
private struct WeakExtendedPropertiesObject<Wrapped> {
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

internal struct ExtendedPropertiesObjects {
    static private let queueName = "SynchronizedExtendedPropertiesObjectsAccess"
    static private let accessQueue = DispatchQueue(label: queueName,
                                                   attributes: .concurrent)
    static private var property = [ExtendedPropertiesObjectKey<AnyObject>: Any?]()
    
    internal static func remove() {
        if property.count == 0 { return }
        
        accessQueue.async(flags: .barrier) {
            property = property.filter({$0.key.wrappedValue != nil})
        }
    }
    
    internal static func get<T>(_ key: ExtendedPropertiesObjectKey<AnyObject>,
                                policy: ExtendedPropertiesObjectPolicy) -> T? {
        Self.remove()
        var res: T?
        accessQueue.sync {
            if policy == .assign {
                let weakObject = property[key] as? WeakExtendedPropertiesObject<Any>
                res = weakObject?.wrappedValue as? T
            }
            else {
                res = property[key] as? T
            }
        }
        return res
    }

    internal static func haveKey(_ key: ExtendedPropertiesObjectKey<AnyObject>,
                                 policy: ExtendedPropertiesObjectPolicy) -> Bool {
        var res = false
        accessQueue.sync {
            res = property.contains(where: { $0.key == key })
        }
        return res

    }
    
    internal static func set(_ key: ExtendedPropertiesObjectKey<AnyObject>,
                             value: Any,
                             policy: ExtendedPropertiesObjectPolicy) {
        Self.remove()
        let flag: DispatchWorkItemFlags = policy.isAtomic ? .barrier : .detached
        
        accessQueue.async(flags: flag) {
            var toStore = value
            if policy == .assign {
                toStore = WeakExtendedPropertiesObject(value)
            } else if policy.isCopy {
                toStore = (value as! NSCopying).copy()
            }
            property[key, default: nil] = toStore
        }
    }
}
