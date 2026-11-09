/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.core

/**
 * RawArray intrinsic functions.
 */
@Intrinsic
func acquireRawData<T>(rawArr: RawArray<T>): CPointer<T> where T <: CType

@Intrinsic
func acquireRawData2<T>(rawArr: RawArray<T> @local?): CPointer<T> where T <: CType

@Intrinsic
func releaseRawData<T>(rawArr: RawArray<T>, ptr: CPointer<T>): Unit where T <: CType

@Intrinsic
func releaseRawData2<T>(rawArr: RawArray<T> @local?, ptr: CPointer<T>): Unit where T <: CType

@Intrinsic
func intrinsicBuiltInCopyTo<T>(
    src: RawArray<T>, dst: RawArray<T>, srcStart: Int64, dstStart: Int64, copyLen: Int64): Unit

@Intrinsic
func intrinsicBuiltInCopyTo2<T>(src: RawArray<T> @local!, dst: RawArray<T> @local!, srcStart: Int64,
    dstStart: Int64, copyLen: Int64): Unit

@Intrinsic
func intrinsicBuiltInCopyTo3<T>(src: RawArray<T> @local?, dst: RawArray<T> @local?, srcStart: Int64,
    dstStart: Int64, copyLen: Int64): Unit

@Intrinsic
func arrayGet<T>(rawArr: RawArray<T>, index: Int64): T

@Intrinsic
func arraySet<T>(rawArr: RawArray<T>, index: Int64, element: T): Unit

@Intrinsic
func arraySet2<T>(rawArr: RawArray<T> @local!, index: Int64, element: T @local!): Unit

@Intrinsic
func arraySet3<T>(rawArr: RawArray<T> @local?, index: Int64, element: T @local?): Unit

@Intrinsic
func arrayGetUnchecked<T>(rawArr: RawArray<T>, index: Int64): T

@Intrinsic
func arrayGetUnchecked2<T>(rawArr: RawArray<T> @local!, index: Int64): T @local!

@Intrinsic
func arrayGetUnchecked3<T>(rawArr: RawArray<T> @local?, index: Int64): T @local?

@Intrinsic
func arraySetUnchecked<T>(rawArr: RawArray<T>, index: Int64, element: T): Unit

@Intrinsic
func arraySetUnchecked2<T>(rawArr: RawArray<T> @local!, index: Int64, element: T @local!): Unit

@Intrinsic
func arraySetUnchecked3<T>(rawArr: RawArray<T> @local?, index: Int64, element: T @local?): Unit where T <: Copyable

@Intrinsic
func arraySize<T>(rawArr: RawArray<T> @local?): Int64

@Intrinsic
func arrayClone<T>(rawArr: RawArray<T>): RawArray<T>

@Intrinsic
func rawArrayAllocate<T>(size: Int64): RawArray<T>

@Intrinsic
func rawArrayAllocate2<T>(size: Int64): RawArray<T> @local!

@Intrinsic
func rawArrayAllocate3<T>(size: Int64): RawArray<T> @local?

@Intrinsic
func rawArrayInitByValue<T>(rawArr: RawArray<T>, size: Int64, initValue: T): Unit

@Intrinsic
func rawArrayInitByValue2<T>(rawArr: RawArray<T> @local!, size: Int64, initValue: T @local!): Unit

@Intrinsic
func rawArrayInitByValue3<T>(rawArr: RawArray<T> @local?, size: Int64, initValue: T @local?): Unit where T <: Copyable
