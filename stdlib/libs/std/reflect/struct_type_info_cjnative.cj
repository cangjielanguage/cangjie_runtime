/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.reflect

import std.collection.*

/**
 * Contains reflective information about structs.
 */
public class StructTypeInfo <: TypeInfo {
    var _constructors: Option<Collection<ConstructorInfo>> = None
    var _instanceVariables: Option<Collection<InstanceVariableInfo>> = None
    var _staticVariables: Option<Collection<StaticVariableInfo>> = None

    init(cp: CPointer<Unit>) {
        super(cp)
    }

    public static redef func get(qualifiedName: String): StructTypeInfo {
        match (TypeInfo.get(qualifiedName)) {
            case typ: StructTypeInfo => return typ
            case _ => throw IllegalTypeException("Type '${qualifiedName}' is not a struct type.")
        }
    }

    public static redef func of(a: Any): StructTypeInfo {
        match (TypeInfo.of(a)) {
            case typ: StructTypeInfo => return typ
            case _ => throw IllegalTypeException("Parameter 'a' is not a struct type.")
        }
    }

    public static redef func of<T>(): StructTypeInfo {
        match (TypeInfo.of<T>()) {
            case typ: StructTypeInfo => return typ
            case _ => throw IllegalTypeException("Generic type 'T' is not a struct type.")
        }
    }

    /**
     * Returns the collection of public constructors of type info.
     */
    public prop constructors: Collection<ConstructorInfo> {
        get() {
            if (_constructors.isNone()) {
                // find from instanceFunctions
                getInstanceFunctions()
            }
            _constructors.getOrThrow()
        }
    }

    /**
     * Returns public instance variables declared on this struct type.
     */
    public prop instanceVariables: Collection<InstanceVariableInfo> {
        get() {
            match (_instanceVariables) {
                case Some(res) => res
                case None =>
                    let infos = getInstanceVariableInfos(_info, "StructTypeInfo", true)
                    _instanceVariables = infos
                    infos
            }
        }
    }

    /**
     * Returns public static variables declared on this struct type.
     */
    public prop staticVariables: Collection<StaticVariableInfo> {
        get() {
            match (_staticVariables) {
                case Some(res) => res
                case None =>
                    let infos = getStaticVariableInfos(_info, "StructTypeInfo")
                    _staticVariables = infos
                    infos
            }
        }
    }

    /**
     * Creates a new instance struct with corresponding type for incoming args.
     *
     * @param args parameter list.
     *
     * @throw InfoNotFoundException, if no public constructor is found to construct new instance.
     * @throw InvocationTargetException, if an exception is thrown when the constructor is called to construct the instance.
     */
    public func construct(args: Array<Any>): Any {
        let parameterTypes = ArrayList<TypeInfo>()
        for (i in 0..args.size) {
            parameterTypes.add(TypeInfo.of(args[i]))
        }
        getConstructor(parameterTypes.toArray()).apply(args)
    }

    /**
     * Searches the type info's public constructor by incoming parameter types.
     */
    public func getConstructor(parameterTypes: Array<TypeInfo>): ConstructorInfo {
        getByNameAndParamTypes(constructors, constructorName, parameterTypes, "Constructor not found.") {
            constructor => (constructorName, constructor.parameters)
        }
    }

    /**
     * Searches the type info's public instance variable by incoming name.
     */
    public func getInstanceVariable(name: String): InstanceVariableInfo {
        getByName(instanceVariables, name, "Instance variable '${name}' in struct ${qualifiedName} not found.") {
            instanceVariable => instanceVariable.name
        }
    }

    /**
     * Searches the type info's public static variable by incoming name.
     */
    public func getStaticVariable(name: String): StaticVariableInfo {
        getByName(staticVariables, name, "Static variable '${name}' in struct ${qualifiedName} not found.") {
            staticVariable => staticVariable.name
        }
    }
}
