/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.collection.*
import std.fs.*
import std.sync.Semaphore
import std.unittest.common.*

foreign {
    func CJ_FS_IsFileORLinkToFile(path: CString): Int8 // -1: error, 0: false, 1: true

    func CJ_FS_IsDirORLinkToFDir(path: CString): Int8 // -1: error, 0: false, 1: true
}

extend<K, V> HashMap<K, V> {
    func getOrInsert(key: K, default: V): V {
        this.addIfAbsent(key, default)
        this.get(key).getOrThrow()
    }

    func getOrInsert(key: K, default: () -> V): V {
        match (this.get(key)) {
            case Some(value) => value
            case None =>
                let value = default()
                this.add(key, value)
                value
        }
    }
}

extend<T> Array<T> {
    operator func +(elem: T): Array<T> {
        let tmp = ArrayList(this)
        tmp.add(elem)
        tmp.toArray()
    }
}

extend<T> Array<T> where T <: Hashable & Equatable<T> {
    func removeDuplicatesStable(): Array<T> {
        let set = HashSet<T>()
        let result = ArrayList<T>()
        for (x in this where !set.contains(x)) {
            set.add(x)
            result.add(x)
        }
        result.toArray()
    }
}

extend<T> Array<T> where T <: Equatable<T> {
    func containsFrom(index: Int64, subseq: Array<T>): Bool {
        if (this.size < index + subseq.size) { false } else {
            this.slice(index, subseq.size) == subseq
        }
    }

    /**
     * Returns array of parts (including empty), separated by delimiter:
     * [].split([2]) ~> [[]]
     * [1, 2].split([2]) ~> [[1], []]
     * [2, 3].split([2]) ~> [[], [3]]
     * [2, 2].split([2]) ~> [[], [], []]
     * [2, 2].split([2, 2]) ~> [[], []]
     */
    func split(delimiter: Array<T>): Array<Array<T>> {
        let parts = ArrayList<Array<T>>()
        var idxPartStart = 0
        for (idxAfterPartEnd in 0..this.size where this.containsFrom(idxAfterPartEnd, delimiter)) {
            parts.add(this.slice(idxPartStart, idxAfterPartEnd - idxPartStart))
            idxPartStart = idxAfterPartEnd + delimiter.size
        }
        parts.add(this.slice(idxPartStart, this.size - idxPartStart))
        parts.toArray()
    }
}

extend Array<Byte> {
    func split(delimiter: String): Array<Array<Byte>> {
        split(delimiter.toArray())
    }
}

extend<T> ArrayList<T> {
    func pop(): ?T {
        if (size == 0) {
            None
        } else {
            remove(at: size - 1)
        }
    }
}

extend DataModelStruct {
    func tryGet(key: String): ?DataModel {
        for (field in this.getFields()) {
            if (field.getName() == key) {
                return Some(field.getData())
            }
        }
        return None
    }

    func toJsonString(): String {
        this.toJson().toString()
    }

    func toJsonBytes(): Array<Byte> {
        this.toJsonString().toArray()
    }

    static func fromJsonBytes(bytes: Array<Byte>): DataModel {
        let string = String.fromUtf8(bytes)
        let json = JsonValue.fromStr(string)
        DataModelStruct.fromJson(json)
    }
}

extend DataModel {
    func asStruct(): DataModelStruct {
        (this as DataModelStruct) ?? throw Exception("this data is not DataModelStruct")
    }
}

extend File {
    static func exists(path: String): Bool {
        if (path.contains("\0")) {
            return false
        }
        unsafe {
            let cPath = LibC.mallocCString(path)
            let exists: Int8 = CJ_FS_IsFileORLinkToFile(cPath)
            LibC.free(cPath)
            return exists > 0
        }
    }
}

extend Directory {
    static func exists(path: String): Bool {
        if (path.contains("\0")) {
            return false
        }
        unsafe {
            let cPath = LibC.mallocCString(path)
            let exists: Int8 = CJ_FS_IsDirORLinkToFDir(cPath)
            LibC.free(cPath)
            return exists > 0
        }
    }

    static func ensureExists(path: Path): Unit {
        if (!Directory.exists(path.toString())) {
            Directory.create(path, recursive: true)
        }
    }
}

func mapParallelOrdered<T, V>(bufferSize: Int64, f: (T) -> V): (Iterable<T>) -> Iterator<V> {
    { iter =>
        let futuresIter = iter |> map{ x => spawn { f(x) } }
        ParallelOrderedMapIterator(bufferSize, futuresIter)
    }
}

class ParallelOrderedMapIterator<T> <: Iterator<T> {
    var futures: ArrayList<Future<T>>
    var currentIdx: Int64 = 0
    ParallelOrderedMapIterator(let bufferSize: Int64, let iter: Iterator<Future<T>>) {
        futures = iter.take(bufferSize) |> collectArrayList
    }

    public func next(): ?T {
        let result = futures.get(currentIdx) ?? return None
        if (let Some(fut) <- iter.next()) {
            futures[currentIdx] = fut
            currentIdx += 1
        } else {
            futures.remove(at: currentIdx)
        }
        if (futures.size != 0) {
            currentIdx = currentIdx % futures.size
        }
        result.get()
    }
}

class ChainIterator<T> <: Iterator<T> {
    ChainIterator(let l: Iterator<T>, let r: Iterator<T>) {}

    public override func next(): Option<T> {
        l.next() ?? r.next()
    }
}

func chain<T>(l: Iterable<T>, r: Iterable<T>): Iterable<T> {
    ChainIterator(l.iterator(), r.iterator())
}

extend Semaphore {
    func doWith<R>(f: () -> R): R {
        this.acquire()
        try {
            f()
        } finally {
            this.release()
        }
    }
}
