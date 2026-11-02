/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

public abstract class Visitor {
    private var breakTraverseFlag = false
    func isTraversalStopped(): Bool {
        return breakTraverseFlag
    }

    protected func needBreakTraverse(): Bool {
        if (breakTraverseFlag) {
            breakTraverseFlag = false
            return true
        }
        return false
    }

    public func breakTraverse(): Unit {
        breakTraverseFlag = true
    }

    protected open func visit(_: Node): Unit {}

    protected open func visit(_: Expr): Unit {}

    protected open func visit(_: IsExpr): Unit {}

    protected open func visit(_: AsExpr): Unit {}

    protected open func visit(_: LitConstExpr): Unit {}

    protected open func visit(_: UnaryExpr): Unit {}

    protected open func visit(_: BinaryExpr): Unit {}

    protected open func visit(_: ParenExpr): Unit {}

    protected open func visit(_: CallExpr): Unit {}

    protected open func visit(_: RefExpr): Unit {}

    protected open func visit(_: ReturnExpr): Unit {}

    protected open func visit(_: AssignExpr): Unit {}

    protected open func visit(_: MemberAccess): Unit {}

    protected open func visit(_: IfExpr): Unit {}

    protected open func visit(_: LetPatternExpr): Unit {}

    protected open func visit(_: MatchExpr): Unit {}

    protected open func visit(_: WhileExpr): Unit {}

    protected open func visit(_: LambdaExpr): Unit {}

    protected open func visit(_: SpawnExpr): Unit {}

    protected open func visit(_: SynchronizedExpr): Unit {}

    protected open func visit(_: TrailingClosureExpr): Unit {}

    protected open func visit(_: TypeConvExpr): Unit {}

    protected open func visit(_: ForInExpr): Unit {}

    protected open func visit(_: PrimitiveTypeExpr): Unit {}

    protected open func visit(_: ArrayLiteral): Unit {}

    protected open func visit(_: TupleLiteral): Unit {}

    protected open func visit(_: SubscriptExpr): Unit {}

    protected open func visit(_: RangeExpr): Unit {}

    protected open func visit(_: Block): Unit {}

    protected open func visit(_: DoWhileExpr): Unit {}

    protected open func visit(_: JumpExpr): Unit {}

    protected open func visit(_: IncOrDecExpr): Unit {}

    protected open func visit(_: TryExpr): Unit {}

    protected open func visit(_: ExclaveExpr): Unit {}

    protected open func visit(_: ThrowExpr): Unit {}

    protected open func visit(_: OptionalExpr): Unit {}

    protected open func visit(_: QuoteExpr): Unit {}

    protected open func visit(_: MacroExpandExpr): Unit {}

    protected open func visit(_: WildcardExpr): Unit {}

    protected open func visit(_: VArrayExpr): Unit {}

    protected open func visit(_: Decl): Unit {}

    protected open func visit(_: ClassDecl): Unit {}

    protected open func visit(_: FuncDecl): Unit {}

    protected open func visit(_: MainDecl): Unit {}

    protected open func visit(_: MacroDecl): Unit {}

    protected open func visit(_: StructDecl): Unit {}

    protected open func visit(_: InterfaceDecl): Unit {}

    protected open func visit(_: PropDecl): Unit {}

    protected open func visit(_: VarDecl): Unit {}

    protected open func visit(_: PrimaryCtorDecl): Unit {}

    protected open func visit(_: EnumDecl): Unit {}

    protected open func visit(_: FuncParam): Unit {}

    protected open func visit(_: ThisParam): Unit {}

    protected open func visit(_: ModalInfo): Unit {}

    protected open func visit(_: TypeAliasDecl): Unit {}

    protected open func visit(_: ExtendDecl): Unit {}

    protected open func visit(_: MacroExpandDecl): Unit {}

    protected open func visit(_: TypeNode): Unit {}

    protected open func visit(_: RefType): Unit {}

    protected open func visit(_: PrimitiveType): Unit {}

    protected open func visit(_: FuncType): Unit {}

    protected open func visit(_: ThisType): Unit {}

    protected open func visit(_: ParenType): Unit {}

    protected open func visit(_: QualifiedType): Unit {}

    protected open func visit(_: PrefixType): Unit {}

    protected open func visit(_: TupleType): Unit {}

    protected open func visit(_: VArrayType): Unit {}

    protected open func visit(_: Pattern): Unit {}

    protected open func visit(_: ConstPattern): Unit {}

    protected open func visit(_: WildcardPattern): Unit {}

    protected open func visit(_: VarPattern): Unit {}

    protected open func visit(_: VarOrEnumPattern): Unit {}

    protected open func visit(_: ExceptTypePattern): Unit {}

    protected open func visit(_: TypePattern): Unit {}

    protected open func visit(_: EnumPattern): Unit {}

    protected open func visit(_: TuplePattern): Unit {}

    protected open func visit(_: GenericParam): Unit {}

    protected open func visit(_: GenericConstraint): Unit {}

    protected open func visit(_: MatchCase): Unit {}

    protected open func visit(_: Program): Unit {}

    protected open func visit(_: PackageHeader): Unit {}

    protected open func visit(_: ImportList): Unit {}

    protected open func visit(_: ImportContent): Unit {}

    protected open func visit(_: Constructor): Unit {}

    protected open func visit(_: Argument): Unit {}

    protected open func visit(_: Annotation): Unit {}

    protected open func visit(_: Modifier): Unit {}

    protected open func visit(_: Body): Unit {}

    protected open func visit(_: PerformExpr): Unit {}
    
    protected open func visit(_: ResumeExpr): Unit {}

    protected open func visit(_: CommandTypePattern): Unit {}

    protected open func visit(_: FeatureId): Unit {}

    protected open func visit(_: FeaturesDirective): Unit {}

    protected open func visit(_: FeaturesSet): Unit {}

    protected open func visit(_: QuoteToken): Unit {}

    protected open func visit(_: MacroExpandParam): Unit {}
}

