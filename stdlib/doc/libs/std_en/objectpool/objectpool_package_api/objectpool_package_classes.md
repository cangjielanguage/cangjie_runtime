# Classes

## class ObjectPool\<T> where T <: Object <sup>(deprecated)</sup>

```cangjie
public class ObjectPool<T> where T <: Object {
    public init(newFunc: () -> T, resetFunc!: Option<(T) -> T> = None)
}
```

Function: This class provides a thread-safe object caching type that can store allocated but unused objects.

When an object is no longer needed, it can be stored in [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated). When the object is needed again, it can be retrieved from the same [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated).

Objects stored in an [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated) must all be of the same type.

Objects stored in an [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated) will not be released until the lifecycle of the [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated) object ends.

> **Note:**
>
> This will be deprecated in future versions.

Example:

<!-- verify -->
```cangjie
import std.objectpool.*

class City {
    var id: Int64 = 0
    var name: String = ""
}

func resetCity(c: City): City {
    let city = c
    city.id = 0
    city.name = ""
    return city
}

main() {
    let cityPool = ObjectPool({=> City()}, resetFunc: resetCity)
    let cityA = cityPool.get()
    cityA.id = 30
    cityA.name = "A"
    println("id: ${cityA.id}, name: ${cityA.name}")
    cityPool.put(cityA)
}
```

Execution result:

```text
id: 30, name: A
```

### init(() -> T, Option\<(T) -> T>)

```cangjie
public init(newFunc: () -> T, resetFunc!: Option<(T) -> T> = None)
```

Function: Creates a new [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated) object.

Parameters:

- newFunc: () ->T - When the get method is called and fails to retrieve an object from [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated), newFn will be called to create a new object. newFunc must ensure thread safety.
- resetFunc!: [Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<(T) ->T> - The get method will call resetFunc to reset the object state. If resetFunc is None, no reset will occur. resetFunc must ensure thread safety.

### func get()

```cangjie
public func get(): T
```

Function: Attempts to retrieve an object from [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated). If retrieval fails, calls newFunc to create and return a new object. Objects obtained via get should be returned to [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated) using put when no longer needed.

Returns:

- T - The object retrieved from [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated) or a new object created by calling newFunc.

### func put(T)

```cangjie
public func put(item: T): Unit
```

Function: Returns an object to [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated). The object will be stored in the subqueue corresponding to the current thread, and can be retrieved and reused by subsequent get operations on the same thread. After calling put on an object, no further operations should be performed on that object, as this may lead to undefined behavior.

Parameters:

- item: T - The object to be returned to [ObjectPool](objectpool_package_classes.md#class-objectpoolt-where-t--object-deprecated).