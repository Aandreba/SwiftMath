//
//  LiteralExt.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 22/9/21.
//

import Foundation

extension UInt: Number, Divisible, Descriveable {
    public typealias DecimalType = Double
    
    public static var one: UInt {
        return 1
    }
    
    public var decimalValue: Double {
        return Double(self)
    }
}

extension UInt8: Number, Divisible, Descriveable {
    public typealias DecimalType = Float16
    
    public static var one: UInt8 {
        return 1
    }
    
    public var decimalValue: Float16 {
        return Float16(self)
    }
}

extension UInt16: Number, Divisible, Descriveable {
    public typealias DecimalType = Float16
    
    public static var one: UInt16 {
        return 1
    }
    
    public var decimalValue: Float16 {
        return Float16(self)
    }
}

extension UInt32: Number, Divisible, Descriveable {
    public typealias DecimalType = Float
    
    public static var one: UInt32 {
        return 1
    }
    
    public var decimalValue: Float {
        return Float(self)
    }
}

extension UInt64: Number, Divisible, Descriveable {
    public typealias DecimalType = Double
    
    public static var one: UInt64 {
        return 1
    }
    
    public var decimalValue: Double {
        return Double(self)
    }
}

extension Int: Number, Divisible, Descriveable {
    public typealias DecimalType = Double
    
    public static var one: Int {
        return 1
    }
    
    public var decimalValue: Double {
        return Double(self)
    }
}

extension Int8: Number, Divisible, Descriveable {
    public typealias DecimalType = Float16
    
    public static var one: Int8 {
        return 1
    }
    
    public var decimalValue: Float16 {
        return Float16(self)
    }
}

extension Int16: Number, Divisible, Descriveable {
    public typealias DecimalType = Float16
    
    public static var one: Int16 {
        return 1
    }
    
    public var decimalValue: Float16 {
        return Float16(self)
    }
}

extension Int32: Number, Divisible, Descriveable {
    public typealias DecimalType = Float
    
    public static var one: Int32 {
        return 1
    }
    
    public var decimalValue: Float {
        return Float(self)
    }
}

extension Int64: Number, Divisible, Descriveable {
    public typealias DecimalType = Double
    
    public static var one: Int64 {
        return 1
    }
    
    public var decimalValue: Double {
        return Double(self)
    }
}

extension Float16: Number, Divisible, Descriveable {
    public static var one: Float16 {
        return 1
    }
}

extension Float: Number, Divisible, Descriveable {
    public static var one: Float {
        return 1
    }
}

extension Double: Number, Divisible, Descriveable {
    public static var one: Double {
        return 1
    }
}
