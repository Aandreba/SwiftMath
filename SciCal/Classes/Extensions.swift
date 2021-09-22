import Foundation

extension UInt16 {
    func bytes() -> [UInt8] {
        return [UInt8(self & 0xFF), UInt8(self >> 8)]
    }
}

extension UInt32 {
    func bytes() -> [UInt8] {
        return [UInt8(self & 0xFF), UInt8((self >> 8) & 0xFF), UInt8(self >> 16)]
    }
}

extension UInt64 {
    func bytes() -> [UInt8] {
        return [UInt8(self & 0xFF), UInt8((self >> 8) & 0xFF), UInt8((self >> 16) & 0xFF), UInt8(self >> 24)]
    }
}

extension Int16 {
    func bytes() -> [Int8] {
        return [Int8(self & 0xFF), Int8(self >> 8)]
    }
}

extension Int32 {
    func bytes() -> [Int8] {
        return [Int8(self & 0xFF), Int8((self >> 8) & 0xFF), Int8(self >> 16)]
    }
}

extension Int64 {
    func bytes() -> [Int8] {
        return [Int8(self & 0xFF), Int8((self >> 8) & 0xFF), Int8((self >> 16) & 0xFF), Int8(self >> 24)]
    }
}
