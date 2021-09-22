//
//  Cordic.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 21/9/21.
//

import Foundation

public class Cordic {
    public static func sineAndCosine (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) -> (sin: BigDecimal, cos: BigDecimal) {
        
        return (sin: BigDecimal.zero, cos: BigDecimal.zero)
    }
    
    public static func sine (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        return sineAndCosine(value, precision).sin
    }
    
    public static func cosine (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        return sineAndCosine(value, precision).cos
    }
    
    public static func tangent (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        let sinCos = sineAndCosine(value, precision)
        return sinCos.sin.divide(sinCos.cos, precision)
    }
}
