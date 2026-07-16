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
 * This is a library for ArgOpt class.
 */
package std.argopt

import std.collection.*

/**
 * This is a library for ArgOpt class.
 * This module helps scripts parse command-line arguments,
 * And parse functions (including special meanings of parameters.
 * in the form of "-" and "--") , Supported by the GNU software.
 * This class uses some methods of String and Rune classes for implementation.
 *
 * @since 0.17.4
 */
@Deprecated[message: "Use global function `public func parseArguments(args: Array<String>, specs: Array<ArgumentSpec>): ParsedArguments` instead."]
public class ArgOpt {

    /* Class that actually handles work. */
    private var utils: ParserHelper

    /* Class that stores symbols. */
    private var arguments: Arguments

    /**
     * Constructor one parameters.
     * For example : shortArgFormat ="abc:d:".
     * indicates that the first letter before the colon can be parsed. that's c and d.
     *
     * @see init(args: Array<String>, shortArgFormat: String, longArgList:Array<String>.
     * @param shortArgFormat Short parameter.
     *
     * @since 0.17.4
     */
    public init(shortArgFormat: String) {
        this(Arguments.NULL, shortArgFormat, Arguments.NULL)
    }

    /**
     * Constructor one parameters.
     * For example: longArgList = {"testA=", "testB"}, args = {"--testA=foo","--test=bar"}
     * Because of the r'=' exists after testA in longArgList. you can find the value of.
     * testA in args. Conversely, no value found.
     *
     * @see init(args: Array<String>, shortArgFormat: String, longArgList: Array<String>).
     * @param longArgList Long parameter set.
     *
     * @since 0.17.4
     */
    public init(longArgList: Array<String>) {
        this(Arguments.NULL, "", longArgList)
    }

    /**
     * Constructor two parameters.
     * For example, see the context.
     *
     * @see init(shortArgFormat: String).
     * @see init(longArgList: Array<String>).
     * @see init(args: Array<String>, shortArgFormat: String, longArgList: Array<String>).
     * @param longArgList Long parameter set.
     * @param shortArgFormat Short parameter.
     *
     * @since 0.17.4
     */
    public init(shortArgFormat: String, longArgList: Array<String>) {
        this(Arguments.NULL, shortArgFormat, longArgList)
    }

    /**
     * This constructor is parsed using the ParserHelper class.
     * which implements the overall round robin scheduling.
     * The split parameters are placed in ParserHelper.argMap.
     * The indexes that do not parse parameters are placed in ParserHelper.argsList.
     * For example No.1: shortArgFormat="abc:d:", args= {"-afoo", "-bofo", "-cbar", "-d"}.
     * Because indicates that the first letter before the colon can be parsed.
     * Keys '-a', '-b', '-c', and '-d' have been saved in the key of ParserHelper.argMap.
     * so the value of r'c' is "bar", the value of r'd' is "".
     * For example No.2: longArgList= {"testA=", "testB"}, args= {"--testA=foo", "--testB=bar"}.
     * Because of the r'=' exists after testA in longArgList.
     * you can find the value of testA in args. Conversely, no value found.
     * Keys 'testA' and 'testB' have been parsed into the key of ParserHelper.argMap.
     * However, The values of keys 'testA' and 'testB' depend on the parametric form of 'longArgList'.
     * For example No.3: longArgList= {"testA=", "testB"},args= {"--testA", "foo", "--testB", "bar"}.
     * Because of the r'=' exists after testA in longArgList.
     * But, if '--testA' in 'args' does not have a value (value after r'='), the next value of '--testA' must be obtained.
     * In addition, the prefix of this next value cannot be '--' or r'-'.
     * In the same way, Keys 'testA' and 'testB' have been parsed into the key of ParserHelper.argMap.
     *
     * @see Arguments.init().
     * @see Arguments.getDoubleSign().
     * @see Arguments.getSingleSign().
     * @see Arguments.setMyArgs(String).
     * @see ParserHelper.init(Arguments).
     * @see ParserHelper.returnTupleFun(String).
     * @see ParserHelper.isArrayEmptyFun(Array<String>).
     * @param longArgList Long parameter set.
     * @param shortArgFormat Short parameter.
     * @param args setting Default parameters of myArgs.
     *
     * @since 0.17.4
     */
    public init(args: Array<String>, shortArgFormat: String, longArgList: Array<String>) {
        this.arguments = Arguments()
        this.utils = ParserHelper(this.arguments)
        this.utils.argsParser(args, shortArgFormat, longArgList)
    }

    /**
     * Getting the value of a parameter.
     * For example one: getArg("a") or getArg("-a").
     * The prefix of the input parameter can be without r'-' or can contain r'-'.
     * which does not affect the returned value.
     * For example two: getArg("--test").
     *
     * @param arg Target key.
     * @return return the option type corresponding to the parameter.
     *
     * @since 0.17.4
     */
    public func getArg(arg: String): Option<String> {
        if (arg.isEmpty()) {
            return Option<String>.None
        }

        let argMap: HashMap<String, String> = utils.getArgsMap()
        let argStr: String = if (arg.size == 1 && arg != "-") {
            "-${arg}"
        } else if ((arg.size > 2 && !arg.startsWith("--")) || !arg.startsWith("-")) {
            "--${arg}"
        } else {
            arg
        }
        return argMap.get(argStr)
    }

    /**
     * Getting the are no parsed parameters.
     *
     * @return if there are no unresolved parameters, returns Arguments.NULL.
     *
     * @since 0.17.4
     */
    public func getUnparseArgs(): Array<String> {
        let argsList: ArrayList<Int8> = utils.getArgsList()
        if (argsList.size == 0) {
            return this.arguments.getUnparseArgs()
        }
        var countZero: Int64 = 0
        var arrIndex: Int64 = 0
        for (i in 0..argsList.size) {
            if (argsList[i] != 0) {
                continue
            }
            countZero++
        }
        this.arguments.setUnparseArgs(Array<String>(countZero, repeat: ""))
        for (i in 0..argsList.size) {
            if (argsList[i] != 0) {
                continue
            }
            this.arguments.getUnparseArgs()[arrIndex] = this.arguments.getMyArgs()[i]
            arrIndex++
        }
        return this.arguments.getUnparseArgs()
    }

    /**
     * Getting all parsed parameters and values.
     *
     * @return key-value pair. The header of the key value must contain r'-' or '--'.
     *
     * @since 0.17.4
     */
    public func getArgumentsMap(): HashMap<String, String> {
        return this.utils.getArgsMap()
    }
}

/**
 * Stores parameters used by the ArgOpt class.
 * including default parameters, and common symbols.
 * Provides the get and set methods.
 *
 * @since 0.17.4
 */
class Arguments {

    /* Provide an empty Array. */
    static let NULL: Array<String> = Array<String>()

    /* Default parameters of myArgs.The default value is NULL. */
    private var myArgs: Array<String> = NULL

    /* Unparsed parameter array, The default value is NULL. */
    private var unparseArgs: Array<String> = NULL

    func setMyArgs(Args: Array<String>) {
        this.myArgs = Args
    }

    func setUnparseArgs(unparseArgs: Array<String>) {
        this.unparseArgs = unparseArgs
    }

    func getMyArgs(): Array<String> {
        return myArgs
    }

    func getUnparseArgs(): Array<String> {
        return unparseArgs
    }
}

/**
 * Exception Type Enumeration.
 *
 * @since 0.17.4
 */
enum ErrorType {
    IllegalArgument
    | IndexOutOfBounds
    | Runtime
}

/**
 * Parameter Parsing Helper class
 *
 * @since 0.17.4
 */
class ParserHelper {

    /* Initialization map creation object: HashMap */
    private let argMap: HashMap<String, String> = HashMap<String, String>()

    /* Initialization Records Resolved and Unresolved Collections:argList */
    private var argsList: ArrayList<Int8> = ArrayList<Int8>()

    /* arguments */
    private var arguments: Arguments

    /* prefix prompt for exceptions */
    private static let exceptionPrompt = "Invalid string, please check the parameter: "

    /**
     * Constructor one parameters.
     *
     * @param argument Reference to the incoming object.
     *
     * @since 0.17.4
     */
    init(argument: Arguments) {
        this.arguments = argument
    }

    /**
     * Return Members argMap.
     *
     * @return return HashMap object.
     *
     * @since 0.17.4
     */
    func getArgsMap(): HashMap<String, String> {
        return this.argMap.clone()
    }

    /**
     * Return Members argsList.
     *
     * @return returns the list set.
     *
     * @since 0.17.4
     */
    func getArgsList(): ArrayList<Int8> {
        return this.argsList.clone()
    }

    /**
     * Processes the args parameter sent by the argopt.
     * Traverse @args to determine the @arg type based on the @arg prefix.
     * If the prefix is --, use @doLongParser  to obtain @long and @unParse.
     * If the prefix is -, use @doShortParser  to obtain @long and @unParse.
     * @unParse check whether the @arg is matched and parsed in @shortStr or @longOpts.
     * @long is number of @arg consumed by each parsing operation.
     *
     * @param args
     * @param shortArgFormat
     * @param longArgList
     *
     * @since 0.17.4
     */
    func argsParser(args: Array<String>, shortArgFormat: String, longArgList: Array<String>): Unit {
        let shortStr: String = checkShortStr(shortArgFormat)
        let longOpts: Array<String> = checkLongOpt(longArgList)
        let size: Int64 = args.size
        this.arguments.setMyArgs(args)
        this.argsList = ArrayList<Int8>(size, {_ => 0})

        var i: Int64 = 0
        while (i < size) {
            let arg: String = args[i]
            if (arg.startsWith("-") && arg != "-" && arg != "--") {
                let (long, unParse): (Int64, Bool) = if (arg.startsWith("--")) {
                    this.doLongParser(longOpts, args, i)
                } else {
                    this.doShortParser(shortStr, args, i)
                }
                if (unParse) {
                    i++
                    continue
                }
                for (j in 0..long where j + i < size) {
                    this.argsList[i + j] = 1
                }
                i = i + long
                continue
            }
            i++
        }
    }

    private func doLongParser(longOpts: Array<String>, args: Array<String>, i: Int64): (Int64, Bool) {
        var key: String = args[i]
        let split = key.indexOf("=") ?? -1
        var optArg: String = ""
        var long: Int64 = 1
        if (split > -1) {
            if (split + 1 < key.size) {
                optArg = key[split + 1..]
            }
            key = key[0..split]
        }
        var unParse: Bool = true
        var hasArg: Bool = false
        for (itemStr in longOpts) {
            let split: Int64 = itemStr.indexOf("=") ?? -1
            var item: String = itemStr
            if (split > -1) {
                item = itemStr[0..=split]
            }
            let isFinished = (item.startsWith(key) && (item == key || item == key + "=")) ||
                !item.startsWith("--") && ("--" + item).startsWith(key) && ("--" + item == key || "--" + item == key +
                "=")
            if (isFinished) {
                unParse = false
                hasArg = item.endsWith("=")
                break
            }
        }
        if (unParse || (!hasArg && split != -1)) {
            return (long, true)
        }
        if (hasArg && split == -1) {
            if (i + 1 >= args.size) {
                return (long, true)
            }
            optArg = args[i + 1]
            long++
        }
        this.argMap.add(key, optArg)
        return (long, false)
    }

    private func doShortParser(shortStr: String, args: Array<String>, i: Int64): (Int64, Bool) {
        if (args[i].size < 2) {
            return (1, true)
        }
        var size: Int64 = shortStr.size
        var key: String = args[i][0..2]
        let index: Int64 = shortStr.indexOf(key[1]) ?? -1
        if (index >= 0) {
            let hasArg: Bool = if (index + 1 >= size) {
                false
            } else {
                shortStr[index + 1] == b':'
            }
            if (!hasArg) {
                if (args[i].size == 2) {
                    this.argMap.add(key, "")
                    return (1, false)
                }
                return (1, true)
            }
            if (args[i] == key) {
                if (i + 1 >= args.size) {
                    return (1, true)
                }
                this.argMap.add(key, args[i + 1])
                return (2, false)
            }
            this.argMap.add(key, args[i][2..])
            return (1, false)
        }
        return (1, true)
    }

    /**
     * @throws IllegalArgumentException if errorId is IllegalArgument.
     */
    private func checkShortStr(shortStr: String): String {
        for (item in shortStr.runes()) {
            if (item == r':' || item.isAsciiLetter()) {
                continue
            }
            throw IllegalArgumentException("${exceptionPrompt}${shortStr}\n")
        }
        return shortStr
    }

    /**
     * @throws IllegalArgumentException if errorId is IllegalArgument.
     */
    private func checkLongOpt(longOpts: Array<String>): Array<String> {
        for (item in longOpts) {
            if (item.isEmpty()) {
                continue
            }
            let isDoubleSign: Bool = item.startsWith("--")
            let isSingleSign: Bool = !isDoubleSign && item.startsWith("-")
            let itemCharArray = item.toRuneArray()
            let size: Int64 = itemCharArray.size
            if (isDoubleSign && size >= 3 && itemCharArray[2].isAsciiLetter()) {
                continue
            }
            if (isSingleSign && size >= 2 && itemCharArray[1].isAsciiLetter()) {
                continue
            }
            if (itemCharArray[0].isAsciiLetter()) {
                continue
            }
            throw IllegalArgumentException("${exceptionPrompt}${item}\n")
        }
        return longOpts
    }
}

public enum ArgumentMode <: ToString & Equatable<ArgumentMode> {
    | NoValue
    | RequiredValue
    | OptionalValue

    public func toString(): String {
        match (this) {
            case NoValue => "NoValue"
            case RequiredValue => "RequiredValue"
            case OptionalValue => "OptionalValue"
        }
    }

    public operator func ==(other: ArgumentMode): Bool {
        this.toString() == other.toString()
    }
}

public enum ArgumentSpec {
    | Short(Rune, ArgumentMode)
    | Short(Rune, ArgumentMode, (String) -> Unit)
    | Long(String, ArgumentMode)
    | Long(String, ArgumentMode, (String) -> Unit)
    | Full(String, Rune, ArgumentMode)
    | Full(String, Rune, ArgumentMode, (String) -> Unit)
    | NonOptions((Array<String>) -> Unit)

    prop name: (?String, ?Rune) {
        get() {
            match (this) {
                case Short(r, _) => (None, r)
                case Short(r, _, _) => (None, r)
                case Long(s, _) => (s, None)
                case Long(s, _, _) => (s, None)
                case Full(s, r, _) => (s, r)
                case Full(s, r, _, _) => (s, r)
                case NonOptions(_) => (None, None)
            }
        }
    }

    prop mode: ArgumentMode {
        get() {
            match (this) {
                case Short(_, m) => m
                case Short(_, m, _) => m
                case Long(_, m) => m
                case Long(_, m, _) => m
                case Full(_, _, m) => m
                case Full(_, _, m, _) => m
                case NonOptions(_) => throw NoneValueException()
            }
        }
    }

    prop optionAction: ?(String) -> Unit {
        get() {
            match (this) {
                case Short(_, _, action) => action
                case Long(_, _, action) => action
                case Full(_, _, _, action) => action
                case _ => None
            }
        }
    }

    prop optionKey: String {
        get() {
            match (this) {
                case Short(r, _) => r.toString()
                case Short(r, _, _) => r.toString()
                case Long(s, _) => s
                case Long(s, _, _) => s
                case Full(s, _, _) => s
                case Full(s, _, _, _) => s
                case NonOptions(_) => throw NoneValueException()
            }
        }
    }

    prop nonOptionAction: ?(Array<String>) -> Unit {
        get() {
            match (this) {
                case NonOptions(action) => action
                case _ => None
            }
        }
    }
}

public struct ParsedArguments {
    var _options: HashMap<String, String>
    var _nonOptions: Array<String>

    init(options: HashMap<String, String>, nonOptions: Array<String>) {
        _options = options
        _nonOptions = nonOptions
    }

    public prop options: ReadOnlyMap<String, String> {
        get() {
            _options
        }
    }

    public prop nonOptions: Array<String> {
        get() {
            _nonOptions
        }
    }
}

enum ParseState {
    Start | Option | NonOption | End
}

class ArgParser {
    let _options: HashMap<String, String> = HashMap<String, String>()
    let _nonOptions: ArrayList<String> = ArrayList<String>()
    let _longOptionSpecs: HashMap<String, ArgumentSpec> = HashMap<String, ArgumentSpec>()
    let _shortOptionSpecs: HashMap<Rune, ArgumentSpec> = HashMap<Rune, ArgumentSpec>()
    var _nonOptionSpecs: ?ArgumentSpec = None
    var _index = 0
    let _pendingCallbacks: ArrayList<((String) -> Unit, String)> = ArrayList<((String) -> Unit, String)>()
    var _pendingNonOptionCallback: ?(Array<String>) -> Unit = None
    var _pendingNonOptionArgs: ?Array<String> = None

    func checkDuplicateShortOption(r: Rune) {
        if (_shortOptionSpecs.contains(r) || _longOptionSpecs.contains(String(r))) {
            throw IllegalArgumentException("Duplicated option ${r} founded.")
        }
    }
    func checkDuplicateLongOption(s: String) {
        if (_longOptionSpecs.contains(s) || (s.size == 1 && _shortOptionSpecs.contains(Rune(s[0])))) {
            throw IllegalArgumentException("Duplicated option: ${s} founded.")
        }
    }

    func addSpec(spec: ArgumentSpec): Unit {
        match (spec) { // r: Rune for short option, s: String for long option
            case Short(r, _) =>
                checkDuplicateShortOption(r)
                _shortOptionSpecs.add(r, spec)
            case Short(r, _, _) =>
                checkDuplicateShortOption(r)
                _shortOptionSpecs.add(r, spec)
            case Long(s, m) =>
                checkDuplicateLongOption(s)
                _longOptionSpecs.add(s, spec)
            case Long(s, _, _) =>
                checkDuplicateLongOption(s)
                _longOptionSpecs.add(s, spec)
            case Full(s, r, _) =>
                checkDuplicateShortOption(r)
                checkDuplicateLongOption(s)
                _longOptionSpecs.add(s, spec)
                _shortOptionSpecs.add(r, spec)
            case Full(s, r, _, _) =>
                checkDuplicateShortOption(r)
                checkDuplicateLongOption(s)
                _longOptionSpecs.add(s, spec)
                _shortOptionSpecs.add(r, spec)
            case NonOptions(action) => _nonOptionSpecs = spec
        }
    }

    func addOptionAndExecuteAction(key: String, val: String, spec: ArgumentSpec) {
        _options.add(key, val)
        match (spec.name) {
            case (Some(longKey), Some(shortKey)) =>
                if (key == String(shortKey)) {
                    _options.add(longKey, val)
                } else if (key == longKey) {
                    _options.add(String(shortKey), val)
                }
            case _ => ()
        }
        if (let Some(action) <- spec.optionAction) {
            _pendingCallbacks.add((action, val))
        }
    }

    func parseLongOption(arg: String, next: ?String): Bool {
        let splited: Array<String> = arg.split("=", 2) // if `=` not exist in arg, [arg] will get, else [option, value] get.

        return if (let Some(spec) <- _longOptionSpecs.get(splited[0])) {
            match ((spec.mode, splited.size == 1)) { // splited.size == 1 means no `=`, simply like --option
                case (OptionalValue, true) => addOptionAndExecuteAction(splited[0], "", spec) // --option
                case (OptionalValue, false) => addOptionAndExecuteAction(splited[0], splited[1], spec) // --option=value
                case (RequiredValue, true) =>
                    addOptionAndExecuteAction(splited[0],
                        next ?? throw ArgumentParseException("Missing option value for ${splited[0]}."), spec) // --option value
                    _index += 1 // consume next string
                case (RequiredValue, false) => addOptionAndExecuteAction(splited[0], splited[1], spec) // --option=value
                case (NoValue, true) => addOptionAndExecuteAction(splited[0], "", spec) // --option
                case (NoValue, false) => throw ArgumentParseException("Unexcepted value for ${splited[0]}.")
            }
            true
        } else {
            false
        }
    }

    // Initialize and filter a list for argument specs that have no value, until first not NoValue option.
    func generateNoValueSpecForShortOption(runeArray: Array<Rune>): ArrayList<ArgumentSpec> {
        let arr: ArrayList<ArgumentSpec> = ArrayList<ArgumentSpec>()
        let set = HashSet<Rune>() // cjlint-ignore !G.VAR.02
        for ((idx, c) in enumerate(runeArray.iterator())) {
            if (let Some(spec) <- _shortOptionSpecs.get(c) && !set.contains(c) && !_options.contains(spec.optionKey) &&
                spec.mode == NoValue) { // cjlint-ignore !G.EXP.03 
                arr.add(spec)
                set.add(c)
            } else {
                break
            }
        }
        arr
    }
    func parseNoValueForShortOption(runeArray: Array<Rune>, next: ?String) {
        let noValueSpecs = generateNoValueSpecForShortOption(runeArray)

        for (spec in noValueSpecs) {
            let key = spec.name[1]?.toString() ?? "" // should not be "", just for pass the compile check.
            addOptionAndExecuteAction(key, "", spec)
        }

        let cur = runeArray[0]
        if (runeArray.size - 1 == noValueSpecs.size) { // for last rune
            let spec = _shortOptionSpecs.get(runeArray[runeArray.size - 1]) ?? throw ArgumentParseException(
                "Unknown option: ${cur}.")
            let key = String(runeArray[runeArray.size - 1])
            match (spec.mode) {
                case OptionalValue => addOptionAndExecuteAction(key, "", spec)
                case RequiredValue =>
                    let value = next ?? throw ArgumentParseException("Missing option value for ${cur}.")
                    _index += 1
                    addOptionAndExecuteAction(key, value, spec)
                case NoValue => throw ArgumentParseException("Should never reach here becauese of previously check.")
            }
        } else if (runeArray.size - 1 > noValueSpecs.size) { // for not last rune
            let spec = _shortOptionSpecs.get(runeArray[noValueSpecs.size]) ?? throw ArgumentParseException(
                "Unknown option: ${runeArray[noValueSpecs.size]}.")
            let key = String(runeArray[noValueSpecs.size])
            if (spec.mode == RequiredValue && noValueSpecs.size < runeArray.size - 1) {
                addOptionAndExecuteAction(key, String(runeArray[noValueSpecs.size + 1..]),
                    spec)
            } else if (spec.mode == OptionalValue) {
                addOptionAndExecuteAction(key, String(runeArray[noValueSpecs.size + 1..]),
                    spec)
            } else {
                throw ArgumentParseException("Unknown option: ${runeArray[noValueSpecs.size]}.")
            }
        }
    }

    func parseShortOption(arg: String, next: ?String) {
        let runeArray = arg.toRuneArray()
        let runeSize = runeArray.size
        let cur = runeArray.get(0).getOrThrow()

        if (let Some(spec) <- _shortOptionSpecs.get(cur)) {
            let key = String(cur)
            match (spec.mode) {
                case OptionalValue =>
                    let value = if (runeSize > 1) {
                        String(runeArray[1..]) // rune after a OptionalValue option is value
                    } else {
                        ""
                    }
                    addOptionAndExecuteAction(key, value, spec)
                case RequiredValue =>
                    let value = if (runeSize == 1) { // -o v
                        _index += 1
                        next ?? throw ArgumentParseException("Missing option value for ${cur}.")
                    } else { // -ov
                        String(runeArray[1..])
                    }
                    addOptionAndExecuteAction(key, value, spec)
                case NoValue => parseNoValueForShortOption(runeArray, next)
            }
        } else {
            throw ArgumentParseException("Unknown option: ${arg}.")
        }
    }

    // '-' or '--' should be removed before this function called.
    func parseOption(arg: String, next: ?String, longOptionOnly!: Bool = false) {
        if (arg.size == 0) {
            throw ArgumentParseException("Option cannot be empty.")
        }

        if (!parseLongOption(arg, next)) {
            if (longOptionOnly) {
                throw ArgumentParseException("Unknown option: ${arg}.")
            }
            parseShortOption(arg, next)
        }
    }

    func executeCallbacks() {
        for ((callback, value) in _pendingCallbacks) {
            callback(value)
        }
        if (let Some(action) <- _pendingNonOptionCallback) {
            let args = _pendingNonOptionArgs ?? Array<String>()
            action(args)
        }
    }

    func parse(args: Array<String>, specs: Array<ArgumentSpec>): ParsedArguments {
        specs |> forEach(addSpec)

        var state = ParseState.Start
        while (_index < args.size) {
            let cur = args[_index]
            match (state) {
                case ParseState.Start =>
                    if (cur == "--") {
                        state = ParseState.End
                    } else if (!cur.isEmpty() && cur[0] == b'-') {
                        state = ParseState.Option
                        _index -= 1
                    } else {
                        state = ParseState.NonOption
                        _index -= 1
                    }
                case ParseState.Option =>
                    if (cur.startsWith("--")) {
                        parseOption(cur[2..], args.get(_index + 1), longOptionOnly: true)
                    } else if (cur.startsWith("-")) {
                        parseOption(cur[1..], args.get(_index + 1))
                    } else {
                        throw ArgumentParseException("Illegal option format for ${cur}.") // just for branch coverage, should never be here
                    }
                    state = ParseState.Start
                case ParseState.NonOption =>
                    _nonOptions.add(cur)
                    state = ParseState.Start
                case ParseState.End => _nonOptions.add(cur)
            }
            _index += 1
        }
        if (let Some(action) <- _nonOptionSpecs?.nonOptionAction) {
            _pendingNonOptionCallback = action
            _pendingNonOptionArgs = _nonOptions.toArray()
        }
        let result = ParsedArguments(_options, _nonOptions.toArray())
        executeCallbacks()
        return result
    }
}

public class ArgumentParseException <: Exception {
    public init() {
        super()
    }

    public init(message: String) {
        super(message)
    }

    protected override func getClassName(): String {
        return "ArgumentParseException"
    }
}

public func parseArguments(args: Array<String>, specs: Array<ArgumentSpec>): ParsedArguments {
    ArgParser().parse(args, specs)
}
