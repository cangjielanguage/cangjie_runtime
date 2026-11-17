/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.database.sql

import std.collection.Map
import std.sync.AtomicBool

class ProxyConnection <: Connection {
    var delegate: Connection
    var poolEntry: Entry<Connection>
    var isReleased = AtomicBool(false)

    init(conn: Connection, poolEntry: Entry<Connection>) {
        this.delegate = conn
        this.poolEntry = poolEntry
    }

    public prop state: ConnectionState {
        get() {
            return delegate.state
        }
    }

    public func getMetaData(): Map<String, String> {
        return delegate.getMetaData()
    }

    public func isClosed(): Bool {
        return isReleased.load()
    }

    public func close(): Unit {
        if (!isReleased.compareAndSwap(false, true)) {
            return
        }
        poolEntry.release()
    }

    public func prepareStatement(sql: String): Statement {
        if (isClosed()) {
            throw SqlException("Connection closed")
        }
        return delegate.prepareStatement(sql)
    }

    public func createTransaction(): Transaction {
        if (isClosed()) {
            throw SqlException("Connection closed")
        }
        return delegate.createTransaction()
    }
}
