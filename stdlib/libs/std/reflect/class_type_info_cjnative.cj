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
 * Contains reflective information about classes.
 */
const constructorName = "init"

public class ClassTypeInfo <: TypeInfo {
    var _constructors: Option<Collection<ConstructorInfo>> = None
    var _instanceVariables: Option<Collection<InstanceVariableInfo>> = None
    var _staticVariables: Option<Collection<StaticVariableInfo>> = None
    var _superClass: Option<Option<ClassTypeInfo>> = None
    var _sealedSubclasses: Option<Collection<ClassTypeInfo>> = None

    init(cp: CPointer<Unit>) {
        super(cp)
    }

    public redef static func get(qualifiedName: String): ClassTypeInfo {
        match (TypeInfo.get(qualifiedName)) {
            case typ: ClassTypeInfo => return typ
            case _ => throw IllegalTypeException("The type of '${qualifiedName}' is not a Class Type.")
        }
    }

    public redef static func of(a: Any): ClassTypeInfo {
        match (TypeInfo.of(a)) {
            case typ: ClassTypeInfo => return typ
            case _ => throw IllegalTypeException("The type of parameter 'a' is not a Class Type.")
        }
    }

    public static func of(a: Object): ClassTypeInfo {
        return TypeInfo.of(a)
    }

    public redef static func of<T>(): ClassTypeInfo {
        match (TypeInfo.of<T>()) {
            case typ: ClassTypeInfo => return typ
            case _ => throw IllegalTypeException("The type of generic type 'T' is not a Class Type.")
        }
    }

    /**
     * Returns the collection of public constructors of type info.
     */
    public prop constructors: Collection<ConstructorInfo> {
        // find from instanceFunctions
        get() {
            match (_constructors) {
                case Some(res) => res
                case None =>
                    getInstanceFunctions()
                    _constructors.getOrThrow()
            }
        }
    }

    /**
     * Returns public instance variables declared on this class type.
     */
    public prop instanceVariables: Collection<InstanceVariableInfo> {
        get() {
            match (_instanceVariables) {
                case Some(res) => res
                case None =>
                    let infos = getInstanceVariableInfos(_info, "ClassTypeInfo", false)
                    _instanceVariables = infos
                    infos
            }
        }
    }

    /**
     * Returns public static variables declared on this class type.
     */
    public prop staticVariables: Collection<StaticVariableInfo> {
        get() {
            match (_staticVariables) {
                case Some(res) => res
                case None =>
                    let infos = getStaticVariableInfos(_info, "ClassTypeInfo")
                    _staticVariables = infos
                    infos
            }
        }
    }

    /**
     * Returns the super class of type info.
     */
    public prop superClass: Option<ClassTypeInfo> {
        get() {
            match (_superClass) {
                case Some(res) => res
                case None =>
                    let info = if (qualifiedName == "Object") {
                        None<ClassTypeInfo>
                    } else {
                        let pointer = getSuperTypeInfo(_info)
                        if (pointer.isNull()) {
                            throw InfoNotFoundException("ClassTypeInfo find superClass failed!")
                        }
                        (getOrCreate(pointer) as ClassTypeInfo) ?? throw MisMatchException(
                            "Super class info of '${qualifiedName}' can not cast to ClassTypeInfo.")
                    }
                    _superClass = info
                    info
            }
        }
    }

    /**
     * Returns the collection of sealed subclasses of type info.
     */
    public prop sealedSubclasses: Collection<ClassTypeInfo> {
        get() {
            match (_sealedSubclasses) {
                case Some(res) => res
                case None =>
                    let res = if (!isSealed()) {
                        Array<ClassTypeInfo>()
                    } else {
                        findSubtypeFromPackage<ClassTypeInfo>(this)
                    }
                    _sealedSubclasses = res
                    res
            }
        }
    }

    /**
     * Creates a new instance of class with corresponding type for incoming args.
     *
     * @param args parameter list.
     *
     * @throw InvocationTargetException, if this class is abstract.
     * @throw InfoNotFoundException, if no public constructor is found to construct new instance.
     * @throw InvocationTargetException, if an exception is thrown when the constructor is called to construct the instance.
     */
    public func construct(args: Array<Any>): Any {
        if (this.isAbstract()) {
            throw InvocationTargetException("Constructing abstract classes is not allowed.")
        }
        let parameterTypes = Array<TypeInfo>(args.size) {i => TypeInfo.of(args[i])}
        getConstructor(parameterTypes).apply(args)
    }

    /**
     * Returns true if type info is 'open', false otherwise.
     */
    public func isOpen(): Bool {
        containsModifier(modifiers, ModifierInfo.Open)
    }

    /**
     * Returns true if type info is 'abstract', false otherwise.
     */
    public func isAbstract(): Bool {
        containsModifier(modifiers, ModifierInfo.Abstract)
    }

    /**
     * Returns true if type info is 'sealed', false otherwise.
     */
    public func isSealed(): Bool {
        containsModifier(modifiers, ModifierInfo.Sealed)
    }

    /**
     * Searches the type info's public constructor by incoming parameter types.
     */
    public func getConstructor(parameterTypes: Array<TypeInfo>): ConstructorInfo {
        getByNameAndParamTypes(constructors, constructorName, parameterTypes, "Can not find the specified constructor") {
            constructor => (constructorName, constructor.parameters)
        }
    }

    /**
     * Searches the type info's public instance variable by incoming name.
     */
    public func getInstanceVariable(name: String): InstanceVariableInfo {
        getByName(instanceVariables, name, "instance variable '${name}' in class ${qualifiedName} not found") {
            instanceVariable => instanceVariable.name
        }
    }

    /**
     * Searches the type info's public static variable by incoming name.
     */
    public func getStaticVariable(name: String): StaticVariableInfo {
        getByName(staticVariables, name, "static variable '${name}' in class ${qualifiedName} not found") {
            staticVariable => staticVariable.name
        }
    }
}
