//
//  BigMath.swift
//  SciCal
//
//  Created by Àlex Andreba Martinez on 18/9/21.
//

import Foundation

public class BigMath {
    // SQUARE ROOT
    public static func sqrt (_ value: BigUInt) -> BigUInt {
        var num : BigUInt = value
        var res : BigUInt = BigUInt.zero
        var bit : BigUInt = BigUInt.zero.setBit(pos: value.bitWidth, value: true);
        
        while (bit > num) {
            bit >>= 2;
        }
        
        while (bit != 0) {
            let alpha = res + bit
            if (num >= alpha) {
                num -= alpha
                res = (res >> 1) + bit;
            } else {
                res >>= 1;
            }
            
            bit >>= 2;
        }
        
        return res
    }
    
    public static func sqrt (_ value: BigInt) -> Complex<BigInt> {
        let sqrt = BigInt(false, sqrt(value.magnitude))
        return value < BigInt.zero ? Complex<BigInt>(im: sqrt) : Complex<BigInt>(re: sqrt)
    }
    
    public static func sqrt (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) -> Complex<BigDecimal> {
        let lambda : UInt = (precision & 1) != (value.scale & 1) ? precision + 1 : precision
        let abs : BigUInt = value.value.magnitude << lambda
        
        let result = BigDecimal(unsigned: sqrt(abs), (value.scale + lambda) >> 1)
        return value.sign ? Complex<BigDecimal>(im: result) : Complex<BigDecimal>(re: result)
    }
    
    // BINARY LOGARITHM
    public static func log2 (_ value: BigUInt, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        let len = value.bitWidth - value.trailingZeroBitCount
        let exp = len - 1
        
        var scaled : BigDecimal = BigDecimal.one
        var pow : UInt = 1
        
        for i in (0...(len - 2)).reversed() {
            if (value.bitAt(pos: i)) {
                scaled += BigDecimal(1, pow)
            }
            
            pow += 1
        }
        
        var log2 : BigDecimal = BigDecimal(BigInt(exp))
        pow = 1
        
        for _ in 0..<precision {
            scaled = (scaled * scaled).round(precision)
            if (scaled >= BigDecimal.two) {
                log2 += BigDecimal(1, pow)
                scaled = scaled.withScale(scale: scaled.scale + 1)
            }
            
            pow += 1
        }
        
        return log2
    }
    
    public static func log2 (_ value: BigInt, _ precision: UInt = BigDecimal.precision) throws -> BigDecimal {
        if (value.sign) {
            throw ArithmeticException.negativeLogarithm
        }
        
        return log2(value.magnitude, precision)
    }
    
    public static func log2 (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) throws -> BigDecimal {
        if (value.sign) {
            throw ArithmeticException.negativeLogarithm
        }
        
        return log2(value.value.magnitude) - BigDecimal(BigInt(value.scale))
    }
    
    // NATURAL LOGARITHM
    public static func log (_ value: BigUInt, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        return (log2(value, precision) * ln2(precision)).round(precision)
    }
    
    public static func log (_ value: BigInt, _ precision: UInt = BigDecimal.precision) throws -> BigDecimal {
        if (value.sign) {
            throw ArithmeticException.negativeLogarithm
        }
        
        return try (log2(value, precision) * ln2(precision)).round(precision)
    }
    
    public static func log (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) throws -> BigDecimal {
        if (value.sign) {
            throw ArithmeticException.negativeLogarithm
        }
        
        return try (log2(value, precision) * ln2(precision)).round(precision)
    }
    
    // EXPONENTIAL
    public static func exp (_ value: BigUInt, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        var e : BigDecimal = e(precision)
        var result : BigDecimal = BigDecimal.one
        
        for i in 0..<(value.bitWidth - value.trailingZeroBitCount) {
            if (value.bitAt(pos: i)) {
                result = (result * e).round(precision)
            }
            
            e = (e * e).round(precision)
        }
        
        return result
    }
    
    public static func exp (_ value: BigInt, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        let exp : BigDecimal = exp(value.magnitude, precision)
        return value.sign ? BigDecimal.one.divide(exp, precision) : exp
    }
    
    public static func exp (_ value: BigDecimal, _ precision: UInt = BigDecimal.precision) -> BigDecimal {
        let int : BigInt = value.integerValue
        var frac : BigDecimal = (value - BigDecimal(int)).magnitude
        
        var e : BigDecimal = sqrt(e(precision), precision).re
        var result : BigDecimal = exp(int, precision)
        
        for i in 0..<precision {
            frac = frac.scaleByFactorOfTwo(1)
            
            if (frac >= BigDecimal.one) {
                frac -= BigDecimal.one
                result = (result * e).round(precision)
            }
            
            e = sqrt(e, precision).re
        }
        
        return result
    }
    
    // POWER
    public static func pow (_ lhs: BigDecimal, _ rhs: BigDecimal, _ precision : UInt = BigDecimal.precision) throws -> BigDecimal {
        return exp(rhs * (try! log(lhs, precision)), precision)
    }
    
    // ARC TANGENT
    public static func atan (_ value: BigDecimal, _ precision : UInt = BigDecimal.precision) -> BigDecimal {
        let subprec = Swift.max(precision, precision << 1)
        var val : BigDecimal = value.divide(BigDecimal.one + sqrt(value * value + BigDecimal.one, subprec).re, subprec)
        val = val.divide(BigDecimal.one + sqrt(val * val + BigDecimal.one, subprec).re, subprec)
        
        var add : Bool = false
        let x2 : BigDecimal = val * val
        var sum : BigDecimal = val
        var pow : BigDecimal = val
        var n : BigUInt = 1
        
        let lim : BigDecimal = BigDecimal(1, subprec)
        while true {
            n += 2
            pow = (pow * x2).round(subprec)
            
            let alpha : BigDecimal = pow.divide(BigDecimal(unsigned: n), subprec)
            if (alpha <= lim) {
                break
            }
            
            sum = add ? sum + alpha : sum - alpha
            add = !add
        }
        
        return sum.scaleByFactorOfTwo(2).round(precision)
    }
    
    // TRASCENDENTAL NUMBERS
    private static var pi : [UInt: BigDecimal] = [UInt: BigDecimal]()
    private static var e : [UInt: BigDecimal] = [UInt: BigDecimal]()
    private static var ln2 : [UInt: BigDecimal] = [UInt: BigDecimal]()
    
    public static func pi (_ precision: UInt = BigDecimal.precision) -> BigDecimal {
        let precalc = pi[precision]
        if (precalc != nil) {
            return precalc!
        }
        
        var result = BigDecimal.zero
        let lim = BigDecimal(1, precision)
        var k : UInt = 0
        var add : Bool = true
        
        while true {
            let k2 = k << 1
            let k4 = k2 << 1
            
            let alpha = BigDecimal(1, k2)
            var beta = BigDecimal.one.divide(BigDecimal(integerLiteral: Int(1 + k2)), precision)
            beta += BigDecimal.two.divide(BigDecimal(integerLiteral: Int(1 + k4)), precision)
            beta += BigDecimal.one.divide(BigDecimal(integerLiteral: Int(3 + k4)), precision)
            
            let delta = (alpha * beta).round(precision)
            if (delta <= lim) {
                break
            }
            
            result = add ? result + delta : result - delta
            k += 1
            add = !add
        }
        
        pi[precision] = result
        return result
    }
    
    public static func e (_ precision: UInt = BigDecimal.precision) -> BigDecimal {
        let precalc = e[precision]
        if (precalc != nil) {
            return precalc!
        }
        
        var k : UInt = 0
        var fact : BigUInt = BigUInt.one
        
        var result : BigDecimal = BigDecimal.zero
        let lim = BigDecimal(1, precision)
        
        while (true) {
            if (k > 1) {
                fact *= BigUInt(k)
            }
            
            let delta = BigDecimal.one.divide(BigDecimal(unsigned: fact), precision)
            if (delta <= lim) {
                break
            }
            
            result += delta
            k += 1
        }
        
        e[precision] = result
        return result
    }
    
    public static func ln2 (_ precision: UInt = BigDecimal.precision) -> BigDecimal {
        let precalc = ln2[precision]
        if (precalc != nil) {
            return precalc!
        }
        
        var result : BigDecimal = BigDecimal.zero
        var k : UInt = 1
        
        let lim = BigDecimal(1, precision)
        while (true) {
            var delta : BigDecimal = BigDecimal.one.divide(BigDecimal(BigInt(k)), precision)
            delta = delta.withScale(scale: delta.scale + k)
            
            if (delta <= lim) {
                break
            }
            
            result += delta
            k += 1
        }
        
        ln2[precision] = result
        return result
    }
    
    enum ArithmeticException: Error {
        case negativeLogarithm
    }
}
