//
//  Closure.swift
//  Decodable
//
//  Created by Johannes Lund on 2016-07-10.
//  Copyright © 2016 anviking. All rights reserved.
//

import Foundation

extension Optional {
    
    /// Creates an optional decoder from a decoder decoder of the Wrapped type
    ///
    /// This function is used by `=>` and `=>?` overloads when decoding `T?`
    ///
    /// - parameter decodeClosure: A decoder (decode closure) for the wrapped type
    /// - returns: A closure takes an JSON object, checks it's `NSNull`, if so returns `nil`, otherwise calls the wrapped decode closure.
    static func decoder(_ decodeClosure: (AnyObject) throws -> Wrapped) -> (AnyObject) throws -> Wrapped? {
        return { json in
            if json is NSNull {
                return nil
            } else {
                return try decodeClosure(json)
            }
        }
    }
}

extension Array {
    
    /// Creates an array decoder from an element decoder
    ///
    /// This function is used by `=>` and `=>?` overloads when decoding `[T]`
    ///
    /// - parameter decodeClosure: A decoder (decode closure) for the `Element` type
    /// - throws: if `NSArray.decode` throws or any element decode closure throws
    /// - returns: A closure that takes an `NSArray` and maps it using the element decode closure
    public static func decoder(_ elementDecodeClosure: (AnyObject) throws -> Element) -> (AnyObject) throws -> Array<Element> {
        return { json in
            return try NSArray.decode(json).map { try elementDecodeClosure($0) }
        }
    }
}

extension Dictionary {
    /// Create a dictionary decoder from key- and value- decoders
    ///
    /// This function is used by `=>` and `=>?` overloads when decoding `[K: V]`
    ///
    /// - parameter key: A decoder (decode closure) for the `Key` type
    /// - parameter value: A decoder (decode closure) for the `Value` type
    /// - returns: A closure that takes a `NSDictionary` and "maps" it using key and value decode closures
    public static func decoder(key keyDecodeClosure: (AnyObject) throws -> Key, value elementDecodeClosure: (AnyObject) throws -> Value) -> (AnyObject) throws -> Dictionary {
        return { json in
            var dict = Dictionary()
            for (key, value) in try NSDictionary.decode(json) {
                try dict[keyDecodeClosure(key)] = elementDecodeClosure(value)
            }
            return dict
        }
    }
}

