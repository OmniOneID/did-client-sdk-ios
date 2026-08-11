#if canImport(Foundation)
import Foundation
#endif
internal import OrderedCollections

protocol CBOREncodable {
    /// Optional function that can potentially serve as an opportunity to optimize encoding.
    func encode(options: CBOROptions) -> [UInt8]

    /// Required function that returns the appropriate `CBOR` variant for a `CBOREncodable`-conforming value.
    func toCBOR(options: CBOROptions) -> CBOR
}

extension CBOREncodable {
    func encode(options: CBOROptions) -> [UInt8] {
        self.toCBOR(options: options).encode(options: options)
    }
}

extension CBOR: CBOREncodable {
    /// Encodes a wrapped CBOR value. CBOR.half (Float16) is not supported and encodes as `undefined`.
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        switch self {
        case let .unsignedInt(ui): return CBOR.encodeVarUInt(ui)
        case let .negativeInt(ni): return CBOR.encodeNegativeInt(~Int64(bitPattern: ni))
        case let .byteString(bs): return CBOR.encodeByteString(bs, options: options)
        case let .utf8String(str): return str.encode(options: options)
        case let .array(a): return CBOR.encodeArray(a, options: options)
        case let .map(m): return CBOR.encodeCBORMap(m, options: options)
        #if canImport(Foundation)
        case let .date(d): return CBOR.encodeDate(d, options: options)
        #endif
        case let .tagged(t, l): return CBOR.encodeTagged(tag: t, value: l, options: options)
        case let .simple(s): return CBOR.encodeSimpleValue(s)
        case let .boolean(b): return b.encode(options: options)
        case .null: return CBOR.encodeNull()
        case .undefined: return CBOR.encodeUndefined()
        case .half(_): return CBOR.undefined.encode(options: options)
        case let .float(f): return f.encode()
        case let .double(d): return d.encode()
        case .break: return CBOR.encodeBreak()
        }
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return self
    }
}

extension Int: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return Int64(self).encode(options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return Int64(self).toCBOR(options: options)
    }
}

extension Int8: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return Int64(self).encode(options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return Int64(self).toCBOR(options: options)
    }
}

extension Int16: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return Int64(self).encode(options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return Int64(self).toCBOR(options: options)
    }
}

extension Int32: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return Int64(self).encode(options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return Int64(self).toCBOR(options: options)
    }
}

extension Int64: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        if (self < 0) {
            return CBOR.encodeNegativeInt(self)
        } else {
            return CBOR.encodeVarUInt(UInt64(self))
        }
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        if self < 0 {
            return CBOR.negativeInt(~UInt64(bitPattern: self))
        } else {
            return CBOR.unsignedInt(UInt64(self))
        }
    }
}

extension UInt: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeVarUInt(UInt64(self))
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return UInt64(self).toCBOR(options: options)
    }
}

extension UInt8: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeUInt8(self)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return UInt64(self).toCBOR(options: options)
    }
}

extension UInt16: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeUInt16(self)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return UInt64(self).toCBOR(options: options)
    }
}

extension UInt32: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeUInt32(self)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return UInt64(self).toCBOR(options: options)
    }
}

extension UInt64: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeUInt64(self)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.unsignedInt(self)
    }
}

extension String: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeString(self, options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.utf8String(self)
    }
}

extension Float: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeFloat(self)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.float(self)
    }
}

extension Double: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeDouble(self)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.double(self)
    }
}

extension Bool: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeBool(self)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.boolean(self)
    }
}

extension Array where Element: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeArray(self, options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.array(self.map { $0.toCBOR(options: options) })
    }
}

extension Dictionary where Key: CBOREncodable, Value: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeMap(self, options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.map(OrderedDictionary<CBOR, CBOR>(uniqueKeysWithValues: self.map { ($0.key.toCBOR(options: options), $0.value.toCBOR(options: options)) }))
    }
}


extension OrderedDictionary where Key: CBOREncodable, Value: CBOREncodable {
		func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
				return CBOR.encodeCBORMap(OrderedDictionary<CBOR, CBOR>(uniqueKeysWithValues: self.map { ($0.key.toCBOR(options: options), $0.value.toCBOR(options: options)) }), options: options)
		}

		func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
			return CBOR.map(OrderedDictionary<CBOR, CBOR>(uniqueKeysWithValues: self.map { ($0.key.toCBOR(options: options), $0.value.toCBOR(options: options)) })) 
		}
}

extension Optional where Wrapped: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        switch self {
        case .some(let wrapped): return wrapped.encode(options: options)
        case .none: return CBOR.encodeNull()
        }
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        switch self {
        case .some(let wrapped): return wrapped.toCBOR(options: options)
        case .none: return CBOR.null
        }
    }
}

extension NSNull: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeNull()
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.null
    }
}

#if canImport(Foundation)
extension Date: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeDate(self, options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.date(self)
    }
}

extension Data: CBOREncodable {
    func encode(options: CBOROptions = CBOROptions()) -> [UInt8] {
        return CBOR.encodeByteString(self.map{ $0 }, options: options)
    }

    func toCBOR(options: CBOROptions = CBOROptions()) -> CBOR {
        return CBOR.byteString(self.map { $0 })
    }
}
#endif
