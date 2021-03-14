//
//  ExtendedStoredProperty.swift
//  
//
//  Created by Thomas on 09/07/2020.
//

import Foundation

public protocol ExtendedStoredPropertyOptionalType: ExpressibleByNilLiteral {
    associatedtype WrappedType
    var asOptional: WrappedType? { get }
}

extension Optional: ExtendedStoredPropertyOptionalType {
    public var asOptional: Wrapped? {
        return self
    }
}

@propertyWrapper
public class ExtendedStoredProperty<T: Any> {

    internal let key: ExtendedStoredPropertyKey<AnyObject>
    internal var policy: ExtendedStoredPropertyPolicy

    public typealias ObjectType = T
    public typealias CopyPolicy = ExtendedStoredPropertyCopyValuePolicy
    public typealias ValuePolicy = ExtendedStoredPropertyValuePolicy
    public typealias ReferencePolicy = ExtendedStoredPropertyReferencePolicy
    public typealias OptionalType = ExtendedStoredPropertyOptionalType


    public var wrappedValue: ObjectType! {
        get {
            ExtendedStoredProperties.get(key, policy: policy) }
        set {
            ExtendedStoredProperties.set(key, value: newValue as Any,
                                  policy: policy)
        }
    }

    internal required init<M: Hashable>(_ object: AnyObject,
                                        key: M,
                                        initValue: T,
                                        policy: ExtendedStoredPropertyPolicy,
                                        internal: Bool) {
        self.key = ExtendedStoredPropertyKey(object, key: key)
        self.policy = policy
        if !ExtendedStoredProperties.haveKey(self.key, policy: self.policy) {
            self.wrappedValue = initValue
        }
    }

    private convenience init<M: Hashable>(_ object: AnyObject,
                                          key: M,
                                          initValue: T,
                                          policy: RealPolicy,
                                          internal: Bool) {
        self.init(object, key: key,
                  initValue: initValue,
                  policy: policy.rPolicy,
                  internal: true)
    }

    public convenience init<M: Hashable>(_ object: AnyObject,
                                         key: M,
                                         initValue: T,
                                         policy: ValuePolicy = .atomic) {
        self.init(object, key: key,
                  initValue: initValue,
                  policy: policy,
                  internal: true)
        if wrappedValue == nil {
            wrappedValue = initValue
        }
    }



    public convenience init<M: Hashable>(_ object: AnyObject,
                                         key: M,
                                         initValue: T,
                                         policy: ValuePolicy)
        where T: AnyObject {
            self.init(object, key: key,
                      initValue: initValue,
                      policy: policy,
                      internal: true)
            if wrappedValue == nil {
                wrappedValue = initValue
            }
    }

    public convenience init<M: Hashable>(_ object: AnyObject,
                             key: M,
                             initValue: T? = nil,
                             policy: ValuePolicy = .atomic)
        where T: OptionalType {
            self.init(object, key: key,
                      initValue: initValue.asOptional ?? nil,
                      policy: policy,
                      internal: true)
    }


    public convenience init<M: Hashable>(_ object: AnyObject,
                             key: M,
                             initValue: T = nil,
                             policy: ReferencePolicy)
        where T: OptionalType, T.WrappedType: AnyObject {
            self.init(object, key: key,
            initValue: initValue.asOptional as? ObjectType ?? nil,
            policy:policy,
            internal: true)
    }

    public convenience init<M: Hashable>(_ object: AnyObject,
                             key: M,
                             initValue: T = nil,
                             policy: CopyPolicy)
        where T: OptionalType {
            self.init(object, key: key,
                      initValue: initValue.asOptional as? ObjectType ?? nil,
                      policy:policy,
                      internal: true)
    }

    #if swift(>=5.2)

    public func callAsFunction() -> T {
        wrappedValue
    }

    public func callAsFunction(_ newValue: T) -> Void {
        wrappedValue = newValue
    }

    #endif
}
