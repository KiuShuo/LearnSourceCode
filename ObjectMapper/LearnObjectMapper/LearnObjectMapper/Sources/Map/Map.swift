//
//  Map.swift
//  ObjectMapper
//
//  Created by Tristan Himmelman on 2015-10-09.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2016 Hearst
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation

/// MapContext is available for developers who wish to pass information around during the mapping process.
// 这是一个未来用于扩展的空协议
public protocol MapContext {
	
}

/// A class used for holding mapping data
public final class Map {
	public let mappingType: MappingType // 映射类型 JSON->Model / Model->JSON
	
	public internal(set) var JSON: [String: Any] = [:]
    /*
     isKeyPresent表示是否为当前key，只有shouldIncludeNilValues为true 或者 确实是没有找到JSON中对应的该key的值 的时候，isKeyPresent为false，其他情况下isKeyPresent为true. 
     用于json转model的时候：
     当isKeyPresent为false的时候将不会转变对应的属性。
     反过来说，只有当isKeyPresent为true时才会进行currentKey对应属性的转变。
     */
	public internal(set) var isKeyPresent = false
	public internal(set) var currentValue: Any? // 当前key对应的value值
	public internal(set) var currentKey: String? // 当前的key值
	var keyIsNested = false // 是否是内嵌的
	public internal(set) var nestedKeyDelimiter: String = "." // 内嵌分隔符
	public var context: MapContext?
	public var shouldIncludeNilValues = false  /// If this is set to true, toJSON output will include null values for any variables that are not set.
	
	let toObject: Bool // indicates whether the mapping is being applied to an existing object
	
	public init(mappingType: MappingType, JSON: [String: Any], toObject: Bool = false, context: MapContext? = nil, shouldIncludeNilValues: Bool = false) {
		
		self.mappingType = mappingType
		self.JSON = JSON
		self.toObject = toObject
		self.context = context
		self.shouldIncludeNilValues = shouldIncludeNilValues
	}
	
	/// Sets the current mapper value and key.
	/// The Key paramater can be a period separated string (ex. "distance.value") to access sub objects. // Key 参数可以使用句点来访问子对象
    // 由于下标不能设置默认参数，所以只能通过下标重载来实现。
	public subscript(key: String) -> Map {
		// save key and value associated to it
        print(self.nestedKeyDelimiter)
		return self[key, delimiter: ".", ignoreNil: false]
	}
	
	public subscript(key: String, delimiter delimiter: String) -> Map {
		let nested = key.contains(delimiter)
		return self[key, nested: nested, delimiter: delimiter, ignoreNil: false]
	}
	
	public subscript(key: String, nested nested: Bool) -> Map {
		return self[key, nested: nested, delimiter: ".", ignoreNil: false]
	}
	
	public subscript(key: String, nested nested: Bool, delimiter delimiter: String) -> Map {
		return self[key, nested: nested, delimiter: delimiter, ignoreNil: false]
	}
	
	public subscript(key: String, ignoreNil ignoreNil: Bool) -> Map {
		return self[key, delimiter: ".", ignoreNil: ignoreNil]
	}
	
	public subscript(key: String, delimiter delimiter: String, ignoreNil ignoreNil: Bool) -> Map {
		let nested = key.contains(delimiter)
		return self[key, nested: nested, delimiter: delimiter, ignoreNil: ignoreNil]
	}
	
	public subscript(key: String, nested nested: Bool, ignoreNil ignoreNil: Bool) -> Map {
		return self[key, nested: nested, delimiter: ".", ignoreNil: ignoreNil]
	}
    
	/// 定义下标
	///
	/// - Parameters:
	///   - key: key
	///   - nested: 是否是内嵌的 默认为flase
	///   - delimiter: 内嵌分隔符 默认为.
	///   - ignoreNil: 忽略nil 默认为true忽略
	public subscript(key: String, nested nested: Bool, delimiter delimiter: String, ignoreNil ignoreNil: Bool) -> Map {
		// save key and value associated to it
		currentKey = key
		keyIsNested = nested
		nestedKeyDelimiter = delimiter
		
		if mappingType == .fromJSON { // JSON->Model
			// check if a value exists for the current key
			// do this pre-check for performance reasons
			if nested == false {
				let object = JSON[key]
				let isNSNull = object is NSNull
                // isKeyPresent表示是否为当前key，当object is NSNull 或者 object != nil 时，isKeyPresent为true，否则为false
				isKeyPresent = isNSNull ? true : object != nil
				currentValue = isNSNull ? nil : object
			} else {
				// break down the components of the key that are separated by . // 内嵌类型
				(isKeyPresent, currentValue) = valueFor(ArraySlice(key.components(separatedBy: delimiter)), dictionary: JSON)
			}
			
			// update isKeyPresent if ignoreNil is true
			if ignoreNil && currentValue == nil {
				isKeyPresent = false
			}
		}
		
		return self
	}
	
	public func value<T>() -> T? {
		return currentValue as? T
	}
	
}

// 通过下面的两个函数，最终找到(isKeyPresent, currentValue)

/// Fetch value from JSON dictionary, loop through keyPathComponents until we reach the desired object
private func valueFor(_ keyPathComponents: ArraySlice<String>, dictionary: [String: Any]) -> (Bool, Any?) {
	// Implement it as a tail recursive function.
	if keyPathComponents.isEmpty {
		return (false, nil)
	}
	
	if let keyPath = keyPathComponents.first {
		let object = dictionary[keyPath]
		if object is NSNull {
			return (true, nil)
		} else if keyPathComponents.count > 1, let dict = object as? [String: Any] {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, dictionary: dict)
		} else if keyPathComponents.count > 1, let array = object as? [Any] {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, array: array)
		} else {
			return (object != nil, object)
		}
	}
	
	return (false, nil)
}

/// Fetch value from JSON Array, loop through keyPathComponents them until we reach the desired object
private func valueFor(_ keyPathComponents: ArraySlice<String>, array: [Any]) -> (Bool, Any?) {
	// Implement it as a tail recursive function.
	
	if keyPathComponents.isEmpty {
		return (false, nil)
	}
	
	//Try to convert keypath to Int as index
	if let keyPath = keyPathComponents.first,
		let index = Int(keyPath) , index >= 0 && index < array.count {
		
		let object = array[index]
		
		if object is NSNull {
			return (true, nil)
		} else if keyPathComponents.count > 1, let array = object as? [Any]  {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, array: array)
		} else if  keyPathComponents.count > 1, let dict = object as? [String: Any] {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, dictionary: dict)
		} else {
			return (true, object)
		}
	}
	
	return (false, nil)
}
