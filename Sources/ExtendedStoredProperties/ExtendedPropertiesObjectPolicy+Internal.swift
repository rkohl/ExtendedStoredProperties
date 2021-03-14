//
//  ExtendedStoredPropertyPolicy+Internal.swift
//  
//
//  Created by Thomas on 11/07/2020.
//

import Foundation

internal enum ExtendedStoredPropertyPolicy {

    /// Specifies a weak reference to the associated object.
    case assign

    /// Specifies that the associated object is copied.
    /// And that the association is made atomically.
    case copy_atomic

    /// Specifies that the associated object is copied.
    /// And that the association is not made atomically.
    case copy_non_atomic

    /// Specifies that the association is made atomically.
    case atomic

    /// Specifies that the association is not made atomically.
    case non_atomic

    internal var isAtomic: Bool {
        self == .copy_atomic || self == .atomic || self == .assign
    }

    internal var isCopy: Bool {
        self == .copy_atomic || self == .copy_non_atomic
    }
}

internal protocol RealPolicy {
    var rPolicy: ExtendedStoredPropertyPolicy { get }
}

extension ExtendedStoredPropertyReferencePolicy: RealPolicy {
    internal var rPolicy: ExtendedStoredPropertyPolicy { .assign }
}

extension ExtendedStoredPropertyValuePolicy: RealPolicy {
    internal var rPolicy: ExtendedStoredPropertyPolicy {
        self == .atomic ? .atomic : .non_atomic
    }
}

extension ExtendedStoredPropertyCopyValuePolicy: RealPolicy {
    internal var rPolicy: ExtendedStoredPropertyPolicy {
        self == .copy_atomic ? .copy_atomic : .copy_non_atomic
    }
}
