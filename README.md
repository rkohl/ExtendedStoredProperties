# ExtendedStoredProperties

Pure Swift Implementation of Associated Object

[![Platform](http://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
[![Language](https://img.shields.io/badge/swift-5.0-orange.svg)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-green.svg?style=flat)](https://swift.org/package-manager/)


Extended Stored Properties is a pure swift implementation of Associated Object bundle in a framework for iOS, tvOS, watchOS, macOS, and Mac Catalyst.
- Swift Extended Stored Properties let you forget about the “Extensions must not contain stored properties” constraint with a pure swift approach
- It is not a wrapper on Objective-C runtime Associated Object !

## Content

- [Features](#features)
- [Add stored properties on a class extension](#add-stored-properties-on-a-class-extension)
- [Using an Extended Stored Property](#using-associatedobject)
- [Extended Stored Property Policy](#associated-object-policy)
- [Requirements](#requirements)
- [Installation](#installation)

## Features

- Add stored property on a class extension.
- Thread safe.
- Auto-release memory based on ARC.
- Extended Stored Properties let you forget about the “Extensions must not contain stored properties” constraint 
- Pure swift approach (no dependency on Objective-C runtime).
- iOS, tvOS, watchOS, macOS, and Catalyst compatible


## Add stored properties on a class extension

### Using ExtendedStoredProperty

#### Using ExtendedStoredProperty Swift>=5.2


```swift

import ExtendedStoredProperty

protocol MyProtocol {
var myStoredVar: Bool { get set }
}

extension NSObject: MyProtocol {
private var myStoredVarAssociated: ExtendedStoredProperty<Bool> {
ExtendedStoredProperty(self, key: "myStoredVar", initValue: false)
}

public var myStoredVar: Bool {
get { myStoredVarAssociated() }
set { myStoredVarAssociated(newValue) }
}
}
```

### Extended Stored Property Policy

You can specify an ExtendedStoredPropertyPolicy on ExtendedStoredProperty Initialization to define the association type.
If you don't define one the default .atomic Policy will be used.

```swift
/// Specifies a weak reference to the associated object.
/// Require the associated object to be an optional reference type.
case assign

/// Specifies that the association is made atomically.
/// On a reference type the associated object will be a strong reference.
/// On a value type the associated object is copied.
case atomic

/// Specifies that the association is not made atomically.
/// On a reference type the associated object will be a strong reference.
/// On a value type the associated object is copied.
case non_atomic

/// Specifies that the associated object is copied.
/// And that the association is made atomically.
/// Require the associated object to be reference type
/// and to conform to NSCopying protocol.
case copy_atomic

/// Specifies that the associated object is copied.
/// And that the association is not made atomically.
/// Require the associated object to be reference type
/// and to conform to NSCopying protocol.
case copy_non_atomic

```

#### ExtendedStoredPropertyPolicy Exemple

```swift

import ExtendedStoredProperty

private var testClassGlobal = NSNumber(value: 42)

fileprivate protocol Valuable {
var weakValue: NSNumber? { get set }
var copiedOptionalValue: NSNumber? { get set }
}

extension NSObject: Valuable {

private var weakValueAssociated: ExtendedStoredProperty<NSNumber?> {
ExtendedStoredProperty(self, key: "weakValue", initValue: Optional(testClassGlobal), policy: .assign)
}

private var copiedOptionalAssociated: ExtendedStoredProperty<NSNumber?> {
ExtendedStoredProperty(self, key: "copiedOptionalValue",
initValue: Optional(testClassGlobal),
policy: .copy_atomic)
}

fileprivate var weakValue: NSNumber? {
get { weakValueAssociated() }
set { weakValueAssociated(newValue) }
}

fileprivate var copiedOptionalValue: NSNumber? {
get { copiedOptionalAssociated() }
set { copiedOptionalAssociated(newValue) }
}
}
```

#### ExtendedStoredProperty Policy



## Requirements

| iOS | watchOS | tvOS | macOS | Mac Catalyst |
|-----|---------|------|-------|--------------|
| 8.0 | 6.2     | 9.0  | 10.10 | 13.0         |

## Installation
There are a number of ways to install ExtendedStoredProperties for your project. Swift Package Manager integration is the preferred and recommended approach. Unfortunately, CocoaPods is not supported yet.

Regardless, make sure to import the project wherever you may use it:

```swift
import ExtendedStoredProperties
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into Xcode and the Swift compiler. **This is the recommended installation method.** Updates to ExtendedStoredProperty will always be available immediately to projects with SPM. SPM is also integrated directly with Xcode.

If you are using Xcode 11 or later:
1. Click `File`
2. `Swift Packages`
3. `Add Package Dependency...`
4. Specify the git URL for ExtendedStoredProperties.

```swift
https://github.com/rkohl/ExtendedStoredProperties.git
```
