/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
protected package std.deriving.builtins

import std.deriving.api.*
import std.ast.*
import std.collection.*

class ArbitraryDeriving <: Deriving {
    private static let ARBITRARY_NAME = QualifiedName("std.unittest.prop_test.Arbitrary")
    private static let ARBITRARY_INFO = DerivingInterfaceInfo(
        ARBITRARY_NAME, [], GenericsInjector.singleRecursive()
    )

    public override prop name: String {
        get() { "Arbitrary"}
    }

    public override prop description: String {
        get() { "Arbitrary"}
    }

    public override prop supportedInterfaces: Array<QualifiedName> {
        get() { [ARBITRARY_NAME] }
    }

    public override func queryInterfaceInfo(interfaceName: QualifiedName): DerivingInterfaceInfo {
        if (interfaceName != ARBITRARY_NAME) {
            throw IllegalArgumentException("Interface ${interfaceName} is not supported.")
        }
        return ARBITRARY_INFO
    }

    public override func derive(
        _: Tokens,
        target: DerivingTarget,
        logger: Logger
    ): Tokens {
        let targetType = target.toType()
        let generators = ArrayList<ToTokens>()

        for (ecase in target.enumCases) {
            constructorGenerator { argGenCall: (ToTokens) -> ToTokens =>
                ecase.createCall(targetType) { typeArg: TypeNode, i: Int64 =>
                    if (ecase.hasExcludedField(position: i)) {
                        logger.error(
                            ecase.constructor.identifier,
                            "@DeriveExclude on constructor parameters ('${typeArg.toTokens()}' at position ${i})" +
                                " is not allowed for Arbitrary deriving"
                        )
                    }
                    let argGen = typeArg.generatorLookup()
                    argGenCall(argGen)
                }
            } |> generators.add
        }

        match (target.primaryConstructor) {
            case Some(pc) =>
                constructorGenerator { argGenCall: (ToTokens) -> ToTokens =>
                    pc.createCall(targetType) { param: FuncParam, _: Int64 =>
                        if (target.hasExcludedField(name: param.identifier)) {
                            logger.error(
                                param.identifier,
                                "@DeriveExclude on primary constructor parameters ('${param.identifier.toTokens()}')" +
                                    " is not allowed for Arbitrary deriving"
                            )
                        }
                        let argGen = param.paramType.generatorLookup()
                        argGenCall(argGen)
                    }
                } |> generators.add

            case _ where target.declaration is ClassDecl || target.declaration is StructDecl =>
                logger.error(target.declaration.identifier, "Primary constructor is required for Arbitrary deriving")
            case _ => ()
        }

        let e = target.createExtendSkeleton()
        e.body.decls.add(FuncDecl(quote(
            public static func arbitrary(random: RandomSource): Generator<$(targetType)> {
                $(generators |> pickGenerator)
            }
        )))

        e.appendAllConstraints(this, target, ARBITRARY_NAME)
        return e.toTokens()
    }


    static init() {
        registerDeriving(ArbitraryDeriving())
    }
}


func commaSeparated<T>(things: Iterable<T>): Tokens where T <: ToTokens {
    let tokens = Tokens()
    let it = things.iterator()
    let first = it.next()

    (first?.toTokens() ?? return tokens) |> tokens.append

    for (e in it) {
        tokens.append(Token(COMMA)).append(e.toTokens())
    }
    return tokens
}

extend DerivingTarget {
    prop body: ?Body {
        get() {
            (declaration as ClassDecl)?.body ?? (declaration as StructDecl)?.body
        }
    }

    prop primaryConstructor: ?PrimaryCtorDecl {
        get() {
            let body = this.body ?? return None
            first(filterMap<Decl, PrimaryCtorDecl>({ decl => decl as PrimaryCtorDecl })(body.declsUnwrapped()))
        }
    }

    func hasExcludedField(name!: Token): Bool {
        settings.excludedFields |> any<TargetNamedAttribute> { it => it.identifier.value == name.value }
    }
}

extend TargetEnumCase {
    func hasExcludedField(position!: Int64): Bool {
        let hasField = fields |> any<TargetEnumField> { it => it.position == position }
        !hasField // if it is not in 'fields', then it is excluded
    }

    func createCall(ofType: TypeNode, argument: (TypeNode, Int64) -> ToTokens): ToTokens {
        let arguments = Array<ToTokens>(fields.size) { i =>
            argument(fields[i].fieldType, i)
        } |> commaSeparated

        match (fields.size) {
            case 0 => quote($ofType.$(constructor.identifier))
            case _ => quote($ofType.$(constructor.identifier)($arguments))
        }
    }
}

extend PrimaryCtorDecl {
    func createCall(ofType: TypeNode, argument: (FuncParam, Int64) -> ToTokens): ToTokens {
        let funcParams = funcParamsUnwrapped() |> collectArray
        let arguments = Array<ToTokens>(funcParams.size) { i =>
            let param = funcParams[i]
            let arg = argument(param, i)
            match (param.named) {
                case true => quote($(param.identifier): $arg)
                case _ => arg.toTokens()
            }
        } |> commaSeparated

        quote($ofType($arguments))
    }
}

extend TypeNode {
    func generatorLookup() {
        quote(Generators.lookup<$(this)>(random))
    }
}

private func constructorGenerator(constructorCall: (argGenCall: (ToTokens) -> ToTokens) -> ToTokens): ToTokens {
    let block = Block()
    let argGenIdx = Box<Int64>(1)
    let buildArgGenerator: (ToTokens) -> ToTokens = { argGen: ToTokens =>
        let argGenId = Token(IDENTIFIER, "__g${argGenIdx.value}")
        argGenIdx.value++
        quote(let $(argGenId) = $argGen) |> parseDecl |> block.nodes.add
        quote($argGenId.next())
    }

    let ctorCall = constructorCall(buildArgGenerator)
    quote(Generators.generate { $ctorCall }) |> parseExpr |> block.nodes.add
    quote({ => $block }())
}

private func pickGenerator(generators: ArrayList<ToTokens>): ToTokens {
    match (generators.size) {
        case 1 => generators[0]
        case _ => quote(Generators.pick(random, [$(generators |> commaSeparated)]))
    }
}

extend FuncParam {
    prop named: Bool {
        get() {
            this.not != Token()
        }
    }
}
