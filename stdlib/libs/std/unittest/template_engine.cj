/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.collection.*
import std.regex.Regex
import std.unittest.common.*

protected func substituteTemplate(template: String, values: JsonValue): String {
    Root(template).substitute(values)
}

// template consists of
//  - named subtemplate `{{Type <subtemplate> }}` where `Type` is the name identifying this subtemplate. Can't contain nested subtemplates.
//  - placeholders in the form of `$ident` which substitute `ident` field value in that place, or `$ident:Type`
//    which substitute subtemplate named `Type` with value of `ident` field.
//  - repetitions in form of `{! <subtemplate>  !}. This will repeatedly insert subtemplate
//    repeating non-array fields and zipping array fields for all placeholders inside of it until *any* of arrays is finished.
//    if repetition is the only subtemplate in current scope then it also works on array of structs so preliminary unzipping is not required
class Root {
    var templates = HashMap<String, Template>()
    var rootTemplate: Template
    Root(t: String) {
        var template = t

        var idx = 0
        let builder = StringBuilder()

        // not using regex because for some reason it crashes on such input
        while (let Some(start) <- template.indexOf("{{", idx)) {
            let end = template.indexOf("}}", idx).getOrThrow()
            let t = Template.fromString(template[start + 2..end])
            templates.add(t.name, t)
            builder.append(template[idx..start])
            idx = end + 2
        }
        builder.append(template[idx..])

        rootTemplate = Template("Root", builder.toString())
    }

    func substitute(values: JsonValue): String {
        rootTemplate.substitute(values, templates, 0).getOrThrow()
    }
}

class Template {
    Template(let name: String, let baseText: String) {}
    static func fromString(text: String): Template {
        let parts = text.split("\n", 2)
        Template(parts[0].trimEnd(" \r\n"), parts[1])
    }

    static let REPEATABLES_MATCHER: Regex = Regex("\\{\\!(([^!]|\\![^}])+)\\!\\}")
    static let VARIABLES_MATCHER: Regex = Regex("\\$([a-zA-Z0-9_]+)\\:?([a-zA-Z0-9_]+)?")
    static let REPETITIONS_SANITY_CHECK: Int64 = 1000;

    func substitute(values: JsonValue, templates: HashMap<String, Template>, index: Int64): ?String {
        if (values is JsonNull) {
            return ""
        }

        var baseText = this.baseText

        while (let Some(repeated) <- REPEATABLES_MATCHER.find(baseText, group: true)) {
            let data = StringBuilder()
            data.append(baseText[0..repeated.matchPosition().start])

            let inner = repeated.matchString(1)

            var repIndex = 0
            while (repIndex < REPETITIONS_SANITY_CHECK) {
                data.append(Template("Dummy", inner).substitute(values, templates, repIndex) ?? break)
                repIndex += 1
            }

            data.append(baseText[repeated.matchPosition().end..])
            baseText = data.toString()
        }

        var hadArrays = values is JsonArray
        while (let Some(variable) <- VARIABLES_MATCHER.find(baseText, group: true)) {
            let data = StringBuilder()
            data.append(baseText[0..variable.matchPosition().start])

            let field = variable.matchString(1)
            hadArrays = hadArrays || values.getOrNull(field) is JsonArray
            let values = values.getIndexed(field, index) ?? return None
            if (variable.groupNumber() == 1) {
                data.append(values.render())
            } else {
                let substitutionName = variable.matchString(2)
                if (!templates.contains(substitutionName)) {
                    data.append("<Error: subtemplate \"${substitutionName}\" not found.>")
                } else {
                    let result = templates[substitutionName].substitute(values, templates, 0) ??
                        "<Error while substituting subtemplate \"${substitutionName}\">"
                    data.append(result)
                }
            }
            data.append(baseText[variable.matchPosition().end..])
            baseText = data.toString()
        }
        if (!hadArrays && index >= 1) {
            return None
        }
        baseText
    }
}

func object(data: Array<(String, IntoJson)>): JsonObject {
    JsonObject(HashMap<String, JsonValue>(data.size) { i => (data[i][0], data[i][1].json()) })
}

interface IntoJson {
    func json(): JsonValue
}

extend JsonValue <: IntoJson {
    public func json(): JsonValue {
        this
    }
}

extend String <: IntoJson {
    public func json(): JsonValue {
        JsonString(this)
    }
}

extend Int64 <: IntoJson {
    public func json(): JsonValue {
        JsonInt(this)
    }
}

extend<T> Option<T> <: IntoJson where T <: IntoJson {
    public func json(): JsonValue {
        match (this) {
            case None => JsonNull()
            case Some(x) => x.json()
        }
    }
}

extend<T> Array<T> <: IntoJson where T <: IntoJson {
    public func json(): JsonValue {
        JsonArray(ArrayList(this.size) {i => this[i].json()})
    }
}

extend<T> ArrayList<T> <: IntoJson where T <: IntoJson {
    public func json(): JsonValue {
        JsonArray(ArrayList(this.size) {i => this[i].json()})
    }
}

extend JsonValue {
    func render(): String {
        match (this) {
            case x: JsonString => x.getValue()
            case _: JsonNull => "<none>"
            case _ => this.toString()
        }
    }
}

extend JsonValue {
    func getOrNull(field: String): JsonValue {
        ((this as JsonObject)?.get(field) ?? return JsonNull()) ?? JsonNull()
    }
    // Index in SoA and AoS simultaneously
    func getIndexed(field: String, index: Int64): ?JsonValue {
        if (let Some(arr) <- (this as JsonArray)) {
            let element = arr.get(index) ?? return None
            return (element as JsonObject)?.get(field) ?? None
        }

        if (!(this is JsonObject)) {
            return None
        }

        match (this.asObject().get(field)) {
            case Some(arr) where arr is JsonArray => arr.asArray().get(index)
            case Some(arr) where arr is JsonNull => None
            case Some(other) => other
            case None =>
                return None
        }
    }

}