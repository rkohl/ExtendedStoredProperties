//
//  ExtendedPropertiesObjectPolicy+Internal.swift
//  
//
//  Created by Thomas on 11/07/2020.
//

import Foundation

internal enum ExtendedPropertiesObjectPolicy {

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
    var rPolicy: ExtendedPropertiesObjectPolicy { get }
}

extension ExtendedPropertiesObjectReferencePolicy: RealPolicy {
    internal var rPolicy: ExtendedPropertiesObjectPolicy { .assign }
}

extension ExtendedPropertiesObjectValuePolicy: RealPolicy {
    internal var rPolicy: ExtendedPropertiesObjectPolicy {
        self == .atomic ? .atomic : .non_atomic
    }
}

extension ExtendedPropertiesObjectCopyValuePolicy: RealPolicy {
    internal var rPolicy: ExtendedPropertiesObjectPolicy {
        self == .copy_atomic ? .copy_atomic : .copy_non_atomic
    }
}
