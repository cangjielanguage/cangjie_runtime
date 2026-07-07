/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file
 *
 * This is a library for Serializable.
 */
package std.unittest.common

import std.collection.*

/**
 * This interface used for canonical serialization.
 */
protected interface Serializable<T> {
    /**
     * Serializes itself into DataModel.
     *
     * @return serialized DataModel.
     *
     * @since 0.17.4
     */
    func serializeInternal(): DataModel

    /**
     * Deserializing DataModel into object.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized object.
     *
     * @since 0.17.4
     */
    static func deserialize(dm: DataModel): T
}

/**
 * Extended Int64 to implement Serializable.
 */
extend Int64 <: Serializable<Int64> {
    /**
     * Serializes Int64 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(this)
    }

    /**
     * Deserializing DataModel into Int64.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Int64.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): Int64 {
        return match (dm) {
            case dmi: DataModelInt => dmi.getValue()
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended Int32 to implement Serializable.
 */
extend Int32 <: Serializable<Int32> {
    /**
     * Serializes Int32 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(Int64(this))
    }

    /**
     * Deserializing DataModel into Int32.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Int32.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): Int32 {
        return match (dm) {
            case dmi: DataModelInt => Int32(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended Int16 to implement Serializable.
 */
extend Int16 <: Serializable<Int16> {
    /**
     * Serializes Int16 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(Int64(this))
    }

    /**
     * Deserializing DataModel into Int16.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Int16.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): Int16 {
        return match (dm) {
            case dmi: DataModelInt => Int16(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended Int8 to implement Serializable.
 */
extend Int8 <: Serializable<Int8> {
    /**
     * Serializes Int8 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(Int64(this))
    }

    /**
     * Deserializing DataModel into Int8.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Int8.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): Int8 {
        return match (dm) {
            case dmi: DataModelInt => Int8(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended UInt64 to implement Serializable.
 */
extend UInt64 <: Serializable<UInt64> {
    /**
     * Serializes UInt64 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(Int64(this))
    }

    /**
     * Deserializing DataModel into UInt64.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized UInt64.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): UInt64 {
        return match (dm) {
            case dmi: DataModelInt => UInt64(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended UInt32 to implement Serializable.
 */
extend UInt32 <: Serializable<UInt32> {
    /**
     * Serializes UInt32 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(Int64(this))
    }

    /**
     * Deserializing DataModel into UInt32.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized UInt32.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): UInt32 {
        return match (dm) {
            case dmi: DataModelInt => UInt32(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended UInt16 to implement Serializable.
 */
extend UInt16 <: Serializable<UInt16> {
    /**
     * Serializes UInt16 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(Int64(this))
    }

    /**
     * Deserializing DataModel into UInt16.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized UInt16.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): UInt16 {
        return match (dm) {
            case dmi: DataModelInt => UInt16(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended UInt8 to implement Serializable.
 */
extend UInt8 <: Serializable<UInt8> {
    /**
     * Serializes UInt8 into DataModelInt.
     *
     * @return serialized DataModelInt.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelInt(Int64(this))
    }

    /**
     * Deserializing DataModel into UInt8.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized UInt8.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if dm is not DataModelnt
     */
    public static func deserialize(dm: DataModel): UInt8 {
        return match (dm) {
            case dmi: DataModelInt => UInt8(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelInt")
        }
    }
}

/**
 * Extended Float64 to implement Serializable.
 */
extend Float64 <: Serializable<Float64> {
    /**
     * Serializes Float64 into DataModelFloat.
     *
     * @return serialized DataModelFloat.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelFloat(this)
    }

    /**
     * Deserializing DataModel into Float64.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Float64.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if data is not DataModelFloat
     */
    public static func deserialize(dm: DataModel): Float64 {
        return match (dm) {
            case dmf: DataModelFloat => dmf.getValue()
            case dmi: DataModelInt => Float64(dmi.getValue())
            case _ => throw DataModelException("this data is not DataModelFloat")
        }
    }
}

/**
 * Extended Float32 to implement Serializable.
 */
extend Float32 <: Serializable<Float32> {
    /**
     * Serializes Float32 into DataModelFloat.
     *
     * @return serialized DataModelFloat.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelFloat(Float64(this))
    }

    /**
     * Deserializing DataModel into Float32.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Float32.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if data is not DataModelFloat
     */
    public static func deserialize(dm: DataModel): Float32 {
        return match (dm) {
            case dmf: DataModelFloat => Float32(dmf.getValue())
            case _ => throw DataModelException("this data is not DataModelFloat")
        }
    }
}

/**
 * Extended Float16 to implement Serializable.
 */
extend Float16 <: Serializable<Float16> {
    /**
     * Serializes Float16 into DataModelFloat.
     *
     * @return serialized DataModelFloat.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelFloat(Float64(this))
    }

    /**
     * Deserializing DataModel into Float16.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Float16.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if data is not DataModelFloat
     */
    public static func deserialize(dm: DataModel): Float16 {
        return match (dm) {
            case dmf: DataModelFloat => Float16(dmf.getValue())
            case _ => throw DataModelException("this data is not DataModelFloat")
        }
    }
}

/**
 * Extended Bool to implement Serializable.
 */
extend Bool <: Serializable<Bool> {
    /**
     * Serializes Bool into DataModelBool.
     *
     * @return serialized DataModelBool.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelBool(this)
    }

    /**
     * Deserializing DataModel into Bool.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Bool.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if data is not DataModelBool
     */
    public static func deserialize(dm: DataModel): Bool {
        return match (dm) {
            case dmb: DataModelBool => dmb.getValue()
            case _ => throw DataModelException("this data is not DataModelBool")
        }
    }
}

/**
 * Extended String to implement Serializable.
 */
extend String <: Serializable<String> {
    /**
     * Serializes String into DataModelString.
     *
     * @return serialized DataModelString.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelString(this)
    }

    /**
     * Deserializing DataModel into String.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized String.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if data is not DataModelString
     */
    public static func deserialize(dm: DataModel): String {
        return match (dm) {
            case dms: DataModelString => dms.getValue()
            case _ => throw DataModelException("this data is not DataModelString")
        }
    }
}

/**
 * Extended Rune to implement Serializable.
 */
extend Rune <: Serializable<Rune> {
    /**
     * Serializes Rune into DataModelString.
     *
     * @return serialized DataModelString.
     *
     * @since 0.17.4
     */
    public func serializeInternal(): DataModel {
        return DataModelString(this.toString())
    }

    /**
     * Deserializing DataModel into Rune.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Rune.
     *
     * @since 0.17.4
     *
     * @throws DataModelException if data is not DataModelString
     * @throws Exception if data is not Rune
     */
    public static func deserialize(dm: DataModel): Rune {
        let charStr: String = match (dm) {
            case dms: DataModelString => dms.getValue()
            case _ => throw DataModelException("this data is not DataModelString")
        }
        let runeArray = charStr.toRuneArray()
        if (runeArray.size != 1) {
            throw Exception("this data is not Rune")
        }
        return runeArray[0]
    }
}

/**
 * Extended Option to implement Serializable.
 */
extend<T> Option<T> <: Serializable<Option<T>> where T <: Serializable<T> {
    /**
     * Serializes Option into DataModel of T.
     *
     * @return serialized DataModel.
     *
     * @since 0.18.4
     */
    public func serializeInternal(): DataModel {
        return match (this) {
            case Some(x) => x.serializeInternal()
            case None => DataModelNull()
        }
    }

    /**
     * Deserializing DataModel into Option.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Option.
     *
     * @since 0.18.4
     */
    public static func deserialize(dm: DataModel): Option<T> {
        return match (dm) {
            case dmn: DataModelNull => Option<T>.None
            case _ => Option<T>.Some(T.deserialize(dm))
        }
    }
}

/**
 * Extended Array to implement Serializable.
 */
extend<T> Array<T> <: Serializable<Array<T>> where T <: Serializable<T> {
    /**
     * Serializes Array into DataModelSeq.
     *
     * @return serialized DataModelSeq.
     *
     * @since 0.29.3
     */
    public func serializeInternal(): DataModel {
        return createDataModelSeq<T>(this)
    }

    /**
     * Deserializing DataModel into Array.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized Array.
     *
     * @since 0.29.3
     *
     * @throws DataModelException if data is not DataModelSeq
     */
    public static func deserialize(dm: DataModel): Array<T> {
        var data: ArrayList<DataModel> = match (dm) {
            case dms: DataModelSeq => dms.getItems()
            case _ => throw DataModelException("this data is not DataModelSeq")
        }
        let dataSize = data.size
        if (dataSize == 0) {
            return Array<T>()
        }
        let arr: Array<T> = Array<T>(dataSize, repeat: T.deserialize(data[0]))
        for (i in 1..dataSize) {
            arr[i] = T.deserialize(data[i])
        }
        return arr
    }
}

/**
 * Extended ArrayList to implement Serializable.
 */
extend<T> ArrayList<T> <: Serializable<ArrayList<T>> where T <: Serializable<T> {
    /**
     * Serializes ArrayList into DataModelSeq.
     *
     * @return serialized DataModelSeq.
     *
     * @since 0.22.4
     */
    public func serializeInternal(): DataModel {
        return createDataModelSeq<T>(this)
    }

    /**
     * Deserializing DataModel into ArrayList.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized ArrayList.
     *
     * @since 0.22.4
     *
     * @throws DataModelException if data is not DataModelSeq
     */
    public static func deserialize(dm: DataModel): ArrayList<T> {
        var data: ArrayList<DataModel> = match (dm) {
            case dms: DataModelSeq => dms.getItems()
            case _ => throw DataModelException("this data is not DataModelSeq")
        }
        var arr: ArrayList<T> = ArrayList<T>()
        for (i in data) {
            arr.add(T.deserialize(i))
        }
        return arr
    }
}

/**
 * Extended HashSet to implement Serializable.
 */
extend<T> HashSet<T> <: Serializable<HashSet<T>> where T <: Serializable<T> & Hashable & Equatable<T> {
    /*
     * Serializes HashSet into DataModelSeq.
     *
     * @return serialized DataModelSeq.
     *
     * @since 0.23.3
     */
    public func serializeInternal(): DataModel {
        return createDataModelSeq<T>(this)
    }

    /*
     * Deserializing DataModel into HashSet.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized HashSet.
     *
     * @since 0.23.3
     *
     * @throws DataModelException if data is not DataModelSeq
     */
    public static func deserialize(dm: DataModel): HashSet<T> {
        var data: DataModelSeq = match (dm) {
            case dms: DataModelSeq => dms
            case _ => throw DataModelException("this data is not DataModelSeq")
        }
        var arr: HashSet<T> = HashSet<T>()
        for (i in data.getItems()) {
            arr.add(T.deserialize(i))
        }
        return arr
    }
}

/**
 * Extended HashMap to implement Serializable.
 */
extend<K, V> HashMap<K, V> <: Serializable<HashMap<K, V>>
    where K <: Serializable<K> & Hashable & Equatable<K>, V <: Serializable<V> {
    /*
     * Serializes HashMap into DataModelStruct.
     *
     * @return serialized DataModelStruct.
     *
     * @since 0.23.3
     *
     * @throws DataModelException if the type of key of this hashmap is not String
     */
    public func serializeInternal(): DataModel {
        var dms: DataModelStruct = DataModelStruct()
        for ((k, v) in this) {
            match (k) {
                case k: String => dms.add(field<V>(k, v))
                case _ => throw DataModelException("this data is not String")
            }
        }
        return dms
    }

    /*
     * Deserializing DataModel into HashMap.
     *
     * @param dm DataModel to be deserialized.
     * @return deserialized HashMap.
     *
     * @since 0.23.3
     *
     * @throws DataModelException if dm is not DataModelStruct type or the field of dm is not String type
     */
    public static func deserialize(dm: DataModel): HashMap<K, V> {
        var data: DataModelStruct = match (dm) {
            case dms: DataModelStruct => dms
            case _ => throw DataModelException("this data is not DataModelStruct")
        }
        var arr: HashMap<K, V> = HashMap<K, V>()
        for (i in data.getFields()) {
            match (i.getName()) {
                case k: K => arr.add(k, V.deserialize(i.getData()))
                case _ => throw DataModelException("this data is not String")
            }
        }
        return arr
    }
}
