//
//  BigExt.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 22/9/21.
//

import Foundation

extension BigUInt: Number {
    public typealias DecimalType = BigDecimal
    
    public func squareRoot() -> BigDecimal {
        return self.decimalValue.squareRoot()
    }
}

extension BigInt: Number {
    public typealias DecimalType = BigDecimal
    
    public func squareRoot() -> BigDecimal {
        return self.decimalValue.squareRoot()
    }
}

extension BigDecimal: Number {
    public typealias DecimalType = BigDecimal
    
    public var isNegative: Bool {
        return self.value.sign
    }
    
    public var positive: BigDecimal {
        return self.magnitude
    }
    
    public var decimalValue: BigDecimal {
        return self
    }
    
    public func squareRoot() -> BigDecimal {
        return BigMath.sqrt(self).re
    }
    
    public func complexSqrt() -> Complex<BigDecimal> {
        return BigMath.sqrt(self)
    }
}
