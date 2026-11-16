# Exception Classes

## class ArithmeticException

```cangjie
public open class ArithmeticException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Arithmetic exception class, used when arithmetic exceptions occur.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [ArithmeticException](core_package_exceptions.md#class-arithmeticexception) instance with empty default exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create ArithmeticException using default constructor
    let exception = ArithmeticException()
    
    println("Successfully created ArithmeticException instance")
    println("ArithmeticException's init() constructor is used to create a default arithmetic exception instance")
}
```

Execution Result:

```text
Successfully created ArithmeticException instance
ArithmeticException's init() constructor is used to create a default arithmetic exception instance
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs an [ArithmeticException](core_package_exceptions.md#class-arithmeticexception) instance with the specified exception message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create ArithmeticException with message constructor
    let exception = ArithmeticException("Division by zero error")
    
    println("Successfully created ArithmeticException instance")
    println("Exception message: Division by zero error")
    println("ArithmeticException's init(String) constructor is used to create an arithmetic exception instance with message")
}
```

Execution Result:

```text
Successfully created ArithmeticException instance
Exception message: Division by zero error
ArithmeticException's init(String) constructor is used to create an arithmetic exception instance with message
```

### func getClassName()

```cangjie
protected open override func getClassName(): String
```

Function: Gets the class name.

Returns:

- [String](core_package_structs.md#struct-string) - Class name string.

Example:

<!-- verify -->
```cangjie
// Create a subclass of ArithmeticException to access protected getClassName method
public class MyArithmeticException <: ArithmeticException {
    public init() {
        super()
    }
    
    public init(message: String) {
        super(message)
    }
    
    // Public method to call protected getClassName
    public func getClassNamePublic(): String {
        return getClassName()
    }
}

main() {
    let exception = MyArithmeticException("Test exception")
    let className = exception.getClassNamePublic()
    println("Class name: ${className}")
    
    println("ArithmeticException's getClassName() method is used to get the class name")
}
```

Execution Result:

```text
Class name: ArithmeticException
ArithmeticException's getClassName() method is used to get the class name
```

## class Exception

<!--RP1-->
```cangjie
public open class Exception <: ToString {
    public init()
    public init(causedBy: Exception)
    public init(message: String)
    public init(message: String, causedBy: Exception)
}
```
<!--RP1End-->

Function: [Exception](core_package_exceptions.md#class-exception) is the parent class of all exception classes.

Supports constructing an exception class, setting/getting exception messages, converting to string, getting/printing stack traces, and setting exception name (for string representation).

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

<!--Del-->
### prop causedBy

```cangjie
public mut prop causedBy: ?Exception
```

Function: Cause of exception.

Type: ?[Exception](core_package_exceptions.md#class-exception)

> **Note：**
>
> Unsupported platform：OpenHarmony
Example:

<!-- verify -->
```cangjie
main() {
    try {
        throwException()
    } catch(e: Exception) {
        println(e)
        if (let Some(cause) <- e.causedBy) {
            println(cause)
        }
    }
}

func throwException() {
    try {
        throwCause()
    } catch (e: Exception) {
        let exception = Exception("This is an exception")
        exception.causedBy = e
        throw exception
    }
}

func throwCause() {
    throw Exception("This is a cause")
}

```

Execution Result:

```text
Exception: This is an exception
Exception: This is a cause
```

> **Note：**
>
> Unsupported platform：OpenHarmony
<!--DelEnd-->

### prop message

```cangjie
public open prop message: String
```

Function: Gets the exception message.

Type: [String](core_package_structs.md#struct-string)

Example:

<!-- verify -->
```cangjie
main() {
    // Create Exception instance and access message property
    let exception = Exception("This is an exception message")
    println("Exception message: " + exception.message)
    
    // Create Exception instance using default constructor
    let defaultException = Exception()
    println("Default exception message: '" + defaultException.message + "'")
}
```

Execution Result:

```text
Exception message: This is an exception message
Default exception message: ''
```

### init()

```cangjie
public init()
```

Function: Constructs a default [Exception](core_package_exceptions.md#class-exception) instance with empty default exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create Exception instance using default constructor
    let exception = Exception()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Execution Result:

```text
Default exception message: ''
Exception class name: Exception
```

<!--Del-->
### init(Exception)

```cangjie
public init(causedBy: Exception)
```

Function: Constructs a [Exception](core_package_exceptions.md#class-exception) instance with the specified cause and empty default exception message.

> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- causedBy: [Exception](core_package_exceptions.md#class-exception) - Cause of exception.

Example:

<!-- verify -->
```cangjie
main() {
    try {
        throwException()
    } catch(e: Exception) {
        println(e)
        if (let Some(cause) <- e.causedBy) {
            println(cause)
        }
    }
}

func throwException() {
    try {
        throwCause()
    } catch (e: Exception) {
        throw Exception(e)
    }
}

func throwCause() {
    throw Exception("This is a cause")
}
```

Execution Result:

```text
Exception
Exception: This is a cause
```

> **Note：**
>
> Unsupported platform：OpenHarmony
<!--DelEnd-->

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs an [Exception](core_package_exceptions.md#class-exception) instance with the specified exception message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create Exception instance with message constructor
    let exception = Exception("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Execution Result:

```text
Exception message: Custom exception message
Exception class name: Exception: Custom exception message
```

<!--Del-->
### init(String, Exception)

```cangjie
public init(message: String, causedBy: Exception)
```

Function: Construct a [Exception](core_package_exceptions.md#class-exception) instance with the specified exception message and cause。

> **Note：**
>
> Unsupported platform：OpenHarmony
Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.
- causedBy: [Exception](core_package_exceptions.md#class-exception) - Cause of exception.

Example:

<!-- run -->
```cangjie
main(): Unit {
    try {
        throwException()
    } catch(e: Exception) {
        throw Exception("This is the exception to be thrown", e)
    }

    ()
}

func throwException() {
    try {
        throwCause()
    } catch (e: Exception) {
        throw Exception("This is an exception", e)
    }
}

func throwCause() {
    throw Exception("This is a cause")
}
```

Possible execution result:

```text
An exception has occurred:
Exception: This is the exception to be thrown
     at default::main()(/tmp/test-exception-chain.cj:5)
Caused by: Exception: This is an exception
     at default::throwException()(/tmp/test-exception-chain.cj:15)
     at default::main()(/tmp/test-exception-chain.cj:3)
Caused by: Exception: This is a cause
     at default::throwCause()(/tmp/test-exception-chain.cj:20)
     at default::throwException()(/tmp/test-exception-chain.cj:13)
     ... 1 more
```

> **Note：**
>
> Unsupported platform：OpenHarmony
<!--DelEnd-->

### func getClassName()

```cangjie
protected open func getClassName(): String
```

Function: Gets the class name.

Returns:

- [String](core_package_structs.md#struct-string) - Class name.

Example:

<!-- verify -->
```cangjie
// Create Exception subclass to demonstrate getClassName()
class MyException <: Exception {
    public init() {
        super()
    }
    
    public init(message: String) {
        super(message)
    }
    
    // Call protected getClassName()
    public func getExceptionClassName(): String {
        return this.getClassName()
    }
}

main() {
    let exception = MyException("Test exception")
    println("Exception class name: " + exception.getExceptionClassName())
}
```

Execution Result:

```text
Exception class name: Exception
```

### func getStackTrace()

```cangjie
public func getStackTrace(): Array<StackTraceElement>
```

Function: Gets stack trace information, where each stack trace is represented by a [StackTraceElement](core_package_classes.md#class-stacktraceelement) instance, returning an array of [StackTraceElement](core_package_classes.md#class-stacktraceelement).

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<[StackTraceElement](core_package_classes.md#class-stacktraceelement)> - Stack trace array.

Example:

<!-- verify -->
```cangjie
main() {
    try {
        // Create and throw an exception
        throw Exception("Test exception")
    } catch (e: Exception) {
        // Get stack trace
        let stackTrace = e.getStackTrace()
        println("Number of stack trace elements: " + stackTrace.size.toString())
        // Print first stack element (if exists)
        if (stackTrace.size > 0) {
            let element = stackTrace[0]
            println("First stack element class name: " + element.declaringClass)
            println("First stack element method name: " + element.methodName)
        }
    }
}
```

Execution Result:

```text
Number of stack trace elements: 1
First stack element class name: default
First stack element method name: main()
```

### func printStackTrace()

```cangjie
public func printStackTrace(): Unit
```

Function: Prints stack trace to console.

Example:

<!-- run -->
```cangjie
main() {
    try {
        // Create and throw an exception
        throw Exception("Test exception")
    } catch (e: Exception) {
        // Print stack trace to console
        println("Printing exception stack trace:")
        e.printStackTrace()
    }
}
```

Possible Execution Result:

```text
Printing exception stack trace:
An exception has occurred:
Exception: Test exception
	 at default.main()(/path/path/temp_printStackTrace_example.cj:4)
```

### func toString()

```cangjie
public open func toString(): String
```

Function: Gets string representation of current [Exception](core_package_exceptions.md#class-exception) instance, including class name and exception message.

Returns:

- [String](core_package_structs.md#struct-string) - Exception string.

Example:

<!-- verify -->
```cangjie
main() {
    // Create Exception instances
    let exception1 = Exception()
    let exception2 = Exception("Custom exception message")
    
    // Use toString() to get string representation
    println("Default exception string: " + exception1.toString())
    println("Exception with message string: " + exception2.toString())
}
```

Execution Result:

```text
Default exception string: Exception
Exception with message string: Exception: Custom exception message
```

## class ExclusiveScopeException

```cangjie
public class ExclusiveScopeException <: Exception
```

Purpose: Custom exception class used to wrap exceptions thrown in an exclusive scope. It preserves the stack trace information of the original exception, does not support actively constructing this exception, but it can be caught.

Parent Type:

- [Exception](#class-exception)

### func toString()

```cangjie
public override func toString(): String
```

Purpose: Get class name.

Return Value:

- [String](core_package_structs.md#struct-string) - Class name.

Example:

<!-- code_no_check -->
```cangjie
// This example is for demonstration only, assuming an ExclusiveScopeException is thrown
main() {
    try {
    // Assume memory error occurs
    } catch (e: ExclusiveScopeException) {
        println(e.message)
    }
}
```

## class IllegalArgumentException

```cangjie
public open class IllegalArgumentException <: Exception {
    public init()
    public init(message: String)
}
```

Purpose: Represents an exception class for illegal arguments.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) instance with empty exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalArgumentException instance using default constructor
    let exception = IllegalArgumentException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: IllegalArgumentException
```

### init(String)

```cangjie
public init(message: String)
```

Purpose: Constructs an [IllegalArgumentException](core_package_exceptions.md#class-illegalargumentexception) instance with specified message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalArgumentException instance with custom message
    let exception = IllegalArgumentException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: IllegalArgumentException: Custom exception message
```

### func getClassName()

```cangjie
protected override open func getClassName(): String
```

Purpose: Gets the class name.

Returns:

- [String](core_package_structs.md#struct-string) - Class name.

Example:

<!-- verify -->
```cangjie
// Create subclass of IllegalArgumentException to demonstrate getClassName()
class MyException <: IllegalArgumentException {
    public init() {
        super()
    }
    
    public init(message: String) {
        super(message)
    }
    
    // Call protected method getClassName()
    public func getExceptionClassName(): String {
        return this.getClassName()
    }
}

main() {
    let exception = MyException("Test exception")
    println("Exception class name: " + exception.getExceptionClassName())
}
```

Output:

```text
Exception class name: IllegalArgumentException
```

## class IllegalFormatException

```cangjie
public open class IllegalFormatException <: IllegalArgumentException {
    public init()
    public init(message: String)
}
```

Purpose: Represents an exception class for invalid or non-standard variable formats.

Parent Types:

- [IllegalArgumentException](#class-illegalargumentexception)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [IllegalFormatException](core_package_exceptions.md#class-illegalformatexception) instance with empty exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalFormatException instance using default constructor
    let exception = IllegalFormatException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: IllegalFormatException
```

### init(String)

```cangjie
public init(message: String)
```

Purpose: Constructs an [IllegalFormatException](core_package_exceptions.md#class-illegalformatexception) instance with specified message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalFormatException instance with custom message
    let exception = IllegalFormatException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: IllegalFormatException: Custom exception message
```

### func getClassName()

```cangjie
protected override func getClassName(): String
```

Purpose: Gets the class name.

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - Class name.

Example:

<!-- verify -->
```cangjie
// Create subclass of IllegalFormatException to demonstrate getClassName()
class MyException <: IllegalFormatException {
    public init() {
        super()
    }
    
    public init(message: String) {
        super(message)
    }
    
    // Call protected method getClassName()
    public func getExceptionClassName(): String {
        return this.getClassName()
    }
}

main() {
    let exception = MyException("Test exception")
    println("Exception class name: " + exception.getExceptionClassName())
}
```

Output:

```text
Exception class name: IllegalFormatException
```

## class IllegalMemoryException

```cangjie
public class IllegalMemoryException <: Exception {
    public init()
    public init(message: String)
}
```

Purpose: Represents an exception class for memory operation errors.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) instance with empty exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalMemoryException instance using default constructor
    let exception = IllegalMemoryException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: IllegalMemoryException
```

### init(String)

```cangjie
public init(message: String)
```

Purpose: Constructs an [IllegalMemoryException](core_package_exceptions.md#class-illegalmemoryexception) instance with specified message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalMemoryException instance with custom message
    let exception = IllegalMemoryException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: IllegalMemoryException: Custom exception message
```

## class IllegalStateException

```cangjie
public class IllegalStateException <: Exception {
    public init()
    public init(message: String)
}
```

Purpose: Represents an exception class for illegal states.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [IllegalStateException](core_package_exceptions.md#class-illegalstateexception) instance with empty exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalStateException instance using default constructor
    let exception = IllegalStateException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: IllegalStateException
```

### init(String)

```cangjie
public init(message: String)
```

Purpose: Constructs an [IllegalStateException](core_package_exceptions.md#class-illegalstateexception) instance with specified message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IllegalStateException instance with custom message
    let exception = IllegalStateException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: IllegalStateException: Custom exception message
```

## class IncompatiblePackageException

```cangjie
public class IncompatiblePackageException <: Exception {
    public init()
    public init(message: String)
}
```

Purpose: Represents an exception class for incompatible packages.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Purpose: Constructs a default [IncompatiblePackageException](core_package_exceptions.md#class-incompatiblepackageexception) instance with empty exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IncompatiblePackageException instance using default constructor
    let exception = IncompatiblePackageException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: IncompatiblePackageException
```

### init(String)

```cangjie
public init(message: String)
```

Purpose: Constructs an [IncompatiblePackageException](core_package_exceptions.md#class-incompatiblepackageexception) instance with specified message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - Exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create IncompatiblePackageException instance with custom message
    let exception = IncompatiblePackageException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: IncompatiblePackageException: Custom exception message
```

## class IndexOutOfBoundsException

```cangjie
public class IndexOutOfBoundsException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Represents an exception class for index out-of-bounds errors.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) instance with an empty default exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an IndexOutOfBoundsException instance using the default constructor
    let exception = IndexOutOfBoundsException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: IndexOutOfBoundsException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs an [IndexOutOfBoundsException](core_package_exceptions.md#class-indexoutofboundsexception) instance with the specified exception message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an IndexOutOfBoundsException instance with a custom message
    let exception = IndexOutOfBoundsException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: IndexOutOfBoundsException: Custom exception message
```

## class NegativeArraySizeException

```cangjie
public class NegativeArraySizeException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Represents an exception class for negative array size errors.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) instance with an empty default exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a NegativeArraySizeException instance using the default constructor
    let exception = NegativeArraySizeException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: NegativeArraySizeException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs a [NegativeArraySizeException](core_package_exceptions.md#class-negativearraysizeexception) instance with the specified exception message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a NegativeArraySizeException instance with a custom message
    let exception = NegativeArraySizeException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: NegativeArraySizeException: Custom exception message
```

## class NoneValueException

```cangjie
public class NoneValueException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Represents an exception class for [Option](core_package_enums.md#enum-optiont)\<T> instances with `None` value, typically thrown by the `getOrThrow` function.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [NoneValueException](core_package_exceptions.md#class-nonevalueexception) instance with an empty default exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a NoneValueException instance using the default constructor
    let exception = NoneValueException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: NoneValueException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs a [NoneValueException](core_package_exceptions.md#class-nonevalueexception) instance with the specified exception message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a NoneValueException instance with a custom message
    let exception = NoneValueException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: NoneValueException: Custom exception message
```

## class OverflowException

```cangjie
public class OverflowException <: ArithmeticException {
    public init()
    public init(message: String)
}
```

Function: Represents an exception class for arithmetic overflow errors.

Parent Types:

- [ArithmeticException](#class-arithmeticexception)

### init()

```cangjie
public init()
```

Function: Constructs a default [OverflowException](core_package_exceptions.md#class-overflowexception) instance with an empty default exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an OverflowException instance using the default constructor
    let exception = OverflowException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: OverflowException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs an [OverflowException](core_package_exceptions.md#class-overflowexception) instance with the specified exception message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an OverflowException instance with a custom message
    let exception = OverflowException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: OverflowException: Custom exception message
```

## class SpawnException

```cangjie
public class SpawnException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Represents a thread exception class for errors occurring during thread processing.

Parent Types:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [SpawnException](core_package_exceptions.md#class-spawnexception) instance with an empty default error message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a SpawnException instance using the default constructor
    let exception = SpawnException()
    println("Default exception message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Default exception message: ''
Exception class name: SpawnException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs a [SpawnException](core_package_exceptions.md#class-spawnexception) instance with the specified exception message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The exception message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a SpawnException instance with a custom message
    let exception = SpawnException("Custom exception message")
    println("Exception message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Output:

```text
Exception message: Custom exception message
Exception class name: SpawnException: Custom exception message
```

## class TimeoutException

```cangjie
public class TimeoutException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Thrown when a blocking operation times out.

Parent Type:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [TimeoutException](core_package_exceptions.md#class-timeoutexception) instance with an empty default error message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a TimeoutException instance using the default constructor
    let exception = TimeoutException()
    println("Default error message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Execution Result:

```text
Default error message: ''
Exception class name: TimeoutException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs a [TimeoutException](core_package_exceptions.md#class-timeoutexception) instance with the specified error message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The error message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create a TimeoutException instance with a custom message
    let exception = TimeoutException("Custom error message")
    println("Error message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Execution Result:

```text
Error message: Custom error message
Exception class name: TimeoutException: Custom error message
```

<!--Del_sink-->
## class UnimplementedException

```cangjie
public class UnimplementedException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Represents the exception thrown when the current type has not yet provided the `@local!` or `@local?` adaptation implementation required by some interfaces.

When a type does not provide the corresponding local implementation, the default implementations of interfaces such as [ToString](core_package_interfaces.md#interface-tostring) and [Hashable](core_package_interfaces.md#interface-hashable) throw this exception. The local default implementations of [Iterable](core_package_interfaces.md#interface-iterablee) and [Iterator](core_package_classes.md#class-iteratort) throw [IllegalStateException](#class-illegalstateexception) instead.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parent Type:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [UnimplementedException](core_package_exceptions.md#class-unimplementedexception) instance with the default error message "UnimplementedException".

Example:

<!-- verify -->
```cangjie
main() {
    // Create an UnimplementedException instance using the default constructor
    let exception = UnimplementedException()
    println("created: ${exception.message}")
}
```

Execution Result:

```text
created: UnimplementedException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs an [UnimplementedException](core_package_exceptions.md#class-unimplementedexception) instance with the specified error message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The error message.

Example:

<!-- verify -->
```cangjie
main() {
    try {
        throw UnimplementedException("test message")
    } catch (e: UnimplementedException) {
        println("caught: ${e.message}")
    }
}
```

Execution Result:

```text
caught: test message
```

### func getClassName()

```cangjie
protected override func getClassName(): String
```

Function: Obtains the class name.

This function is a `protected` member and can only be accessed inside the class or its subclasses; external code that needs to display exception information can use the public `toString` function.

Returns:

- [String](core_package_structs.md#struct-string) - The class name "UnimplementedException".

Example:

<!-- verify -->
```cangjie
main() {
    try {
        throw UnimplementedException("test message")
    } catch (e: UnimplementedException) {
        // Use the public toString to obtain the exception information containing the class name
        println(e.toString())
    }
}
```

Execution Result:

```text
UnimplementedException: test message
```

<!--DelEnd_sink-->
## class UnsupportedException

```cangjie
public class UnsupportedException <: Exception {
    public init()
    public init(message: String)
}
```

Function: Represents an exception class for unsupported features.

Parent Type:

- [Exception](#class-exception)

### init()

```cangjie
public init()
```

Function: Constructs a default [UnsupportedException](core_package_exceptions.md#class-unsupportedexception) instance with an empty default error message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an UnsupportedException instance using the default constructor
    let exception = UnsupportedException()
    println("Default error message: '" + exception.message + "'")
    println("Exception class name: " + exception.toString())
}
```

Execution Result:

```text
Default error message: ''
Exception class name: UnsupportedException
```

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs an [UnsupportedException](core_package_exceptions.md#class-unsupportedexception) instance with the specified error message.

Parameters:

- message: [String](core_package_structs.md#struct-string) - The error message.

Example:

<!-- verify -->
```cangjie
main() {
    // Create an UnsupportedException instance with a custom message
    let exception = UnsupportedException("Custom error message")
    println("Error message: " + exception.message)
    println("Exception class name: " + exception.toString())
}
```

Execution Result:

```text
Error message: Custom error message
Exception class name: UnsupportedException: Custom error message
```

## class Error

```cangjie
public open class Error <: ToString
```

Function: [Error](core_package_exceptions.md#class-error) is the base class for all error classes. This class cannot be inherited or instantiated, but can be caught.

Parent Types:

- [ToString](core_package_interfaces.md#interface-tostring)

### prop message

```cangjie
public open prop message: String
```

Function: Gets the error message.

Type: [String](core_package_structs.md#struct-string)

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming Error is thrown
main() {
    try {
        // Assume memory error or stack overflow occurs
    } catch (e: Error) {
        println(e.message)
    }
}
```

### func getClassName()

```cangjie
protected open func getClassName(): String
```

Function: Gets the class name.

Returns:

- [String](core_package_structs.md#struct-string) - Class name.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming internal Error is thrown
main() {
    try {
        // Assume stack overflow occurs
    } catch (e: StackOverflowError) {
        println(e.message)
    }
}

extend Error {
    public func printlnClassName(): Unit {
        println(getClassName())
    }
}
```

### func getStackTrace()

```cangjie
public func getStackTrace(): Array<StackTraceElement>
```

Function: Gets stack trace information, where each stack trace is represented by a [StackTraceElement](core_package_classes.md#class-stacktraceelement) instance, returning an array of [StackTraceElement](core_package_classes.md#class-stacktraceelement).

Returns:

- [Array](core_package_structs.md#struct-arrayt)\<[StackTraceElement](core_package_classes.md#class-stacktraceelement)> - Stack trace array.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming internal Error is thrown
main() {
    try {
        // Assume memory error, stack overflow, or internal error occurs
    } catch (e: Error) {
        println(e.getStackTrace()[0].methodName)
    }
}
```

### func getStackTraceMessage()

```cangjie
public open func getStackTraceMessage(): String
```

Function: Gets stack trace information.

Returns:

- [String](core_package_structs.md#struct-string) - Stack trace message.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming internal Error is thrown
main() {
    try {
        // Assume memory error, stack overflow, or internal error occurs
    } catch (e: Error) {
        println(e.getStackTraceMessage())
    }
}
```

### func printStackTrace()

```cangjie
public open func printStackTrace(): Unit
```

Function: Prints stack trace to console.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming internal Error is thrown
main() {
    try {
        // Assume memory error, stack overflow, or internal error occurs
    } catch (e: Error) {
        println(e.printStackTrace())
    }
}
```

### func toString()

```cangjie
public open func toString(): String
```

Function: Gets string representation of current [Error](core_package_exceptions.md#class-error) instance, including class name and error message.

Returns:

- [String](core_package_structs.md#struct-string) - Error message string.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming internal Error is thrown
main() {
    try {
        // Assume memory error, stack overflow, or internal error occurs
    } catch (e: Error) {
        println(e)
    }
}
```

<!--Del_sink-->
## class LocalRegionOutOfMemoryError

```cangjie
public class LocalRegionOutOfMemoryError <: Error {}
```

Function: Represents the error raised when memory allocation in a local region fails. This error is thrown when the runtime fails to allocate memory for an object in a local region.

The memory usage of local objects is not counted in the result of `getAllocatedHeapSize`.

> **Note:**
>
> - Experimental API, for test verification only; the specification and implementation may still change; use with caution.
> - Platform not supported: OpenHarmony.

Parent Type:

- [Error](#class-error)

Example:

<!-- verify -->
```cangjie
func allocateAndPrint() {
    // Allocate a small array in the local region; the allocation normally succeeds
    let arr: Array<Int64> @local! = [1, 2, 3]
    println("allocated: ${arr.size}")
}

main() {
    try {
        allocateAndPrint()
    } catch (e: LocalRegionOutOfMemoryError) {
        // This error is thrown when memory allocation in the local region fails
        println("local region out of memory")
    }
}
```

Execution Result:

```text
allocated: 3
```

<!--DelEnd_sink-->

## class OutOfMemoryError

```cangjie
public class OutOfMemoryError <: Error
```

Function: Represents an error class for out-of-memory conditions. This class cannot be inherited or instantiated, but can be caught.

Parent Types:

- [Error](#class-error)

### func getClassName()

```cangjie
protected override func getClassName(): String
```

Function: Gets the class name.

Returns:

- [String](core_package_structs.md#struct-string) - The class name.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming OutOfMemoryError is thrown
main() {
    try {
        // Assume an out-of-memory error occurs
    } catch (e: OutOfMemoryError) {
        println(e.message)
    }
}

extend Error {
    public func printlnClassName(): Unit {
        println(getClassName())
    }
}
```

## class StackOverflowError

```cangjie
public class StackOverflowError <: Error
```

Function: Represents the error class for stack overflow errors. This class cannot be inherited or instantiated but can be caught.

Parent Type:

- [Error](#class-error)

### func getClassName()

```cangjie
protected override func getClassName(): String
```

Function: Retrieves the class name.

Returns:

- [String](core_package_structs.md#struct-string) - The class name.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming a StackOverflowError is thrown
main() {
    try {
        // Assume a stack overflow error occurs
    } catch (e: StackOverflowError) {
        println(e.message)
    }
}

extend Error {
    public func printlnClassName(): Unit {
        println(getClassName())
    }
}
```

### func printStackTrace()

```cangjie
public override func printStackTrace(): Unit
```

Function: Prints stack trace information to the console.

Example:

<!-- compile -->
```cangjie
// This example is for demonstration only, assuming a StackOverflowError is thrown
main() {
    try {
        // Assume a stack overflow error occurs
    } catch (e: StackOverflowError) {
        println(e.printStackTrace())
    }
}
```