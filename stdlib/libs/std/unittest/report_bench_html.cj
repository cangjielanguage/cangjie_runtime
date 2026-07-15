/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */
package std.unittest

import std.fs.*
import std.convert.Formattable
import std.collection.*
import std.unittest.common.*
import std.process.*
import std.math.*
import std.env.*
import std.regex.Regex
import std.time.DateTime

let STYLES = """
html {
    overflow-x: hidden;
    font-family: Arial, sans-serif;
    -ms-text-size-adjust: 100%;
    -webkit-text-size-adjust: 100%;
    box-sizing: border-box;
}
*, *:before, *:after {
    box-sizing: inherit;
    font-family: inherit;
}

@supports (-moz-appearance:none) {
    * {
        font-stretch: condensed !important;
    }
}

a {
    background-color: transparent;
    color: inherit;
}

h1 {
    font-size: 36px
}

h2 {
    font-size: 30px
}

h3 {
    font-size: 24px
}

h4 {
    font-size: 20px
}

h5 {
    font-size: 18px
    }

h6 {
    font-size: 16px
}
h1,h2,h3,h4,h5,h6 {
    font-family: "Segoe UI",Arial,sans-serif;
    font-weight: 400;
    margin: 10px 0
}


body {
    margin: 0
}

.sidebar {
    z-index: 3;
    width: 250px;
    top: 43px;
    bottom: 0;
    height: inherit;
    position: fixed !important;
    font-size: 18px !important;
    color:#000 !important;
    background-color:#f0f0f0 !important;
}

.shadow {
    box-shadow: 0 4px 10px 0 rgba(0,0,0,0.2),0 4px 20px 0 rgba(0,0,0,0.19);
}

#summary td,
#summary th {
    min-width: 100px;
    width: auto;
    word-wrap: break-word;
}

.main td, .main th {
    padding-top: 4px;
}

#summary table {
    overflow-x: auto;
    display: block;
}

#summary td:first-child, #summary th:first-child {
    min-width: 100px;
    width: 250px;
    max-width: 250px;
}
#summary td:last-child, #summary th:last-child {
    width: auto;
}

div.main {
    padding-top: 48px;
    display: none;
}

div.main:last-child {
    display: block;
}

div:target ~ div.main {
    display: none;
}


div:target {
    display: block;
}

table {
    border-collapse: collapse;
    border-spacing: 0;
    width: 100%;
    display: table;
    font-size: 12px!important
}

table td, table th {
    padding: 4px 4px;
    display: table-cell;
    text-align: left;
    vertical-align: top;
}

table th:first-child,table td:first-child {
    padding-left: 16px;
}

td.text-center button {
    margin: -2px!important
}

.left-button {
    word-wrap: break-word;
    width: 100%;
    display: block;
    padding: 8px 16px;
    text-align: left;
    border: none;
    white-space: normal;
    float: none;
    outline: 0;
    overflow: hidden;
    text-decoration: none;
    cursor: pointer;
}

.clicked {
    border: 1px solid #ccc !important;
    border-left: 6px solid #ccc !important;
    border-right: 0px !important;
}

.divider-border {
    border-top: 1px solid #ccc !important;
}

.default-padding, .spacer{
    padding: 8px 16px!important;
}
.spacer {
    width: 100%;
}

.left-button:hover {
    color: #fff !important;
    background-color: #000 !important
}

body {
    font-size: 15px;
    line-height: 1.5;
}

.cj-footer, .cj-header {
    color: #fff !important;
    position: fixed;
    width: 100%;
    z-index: 1;
}

.cj-footer {
    bottom: 0;
    background-color: #333333 !important;
    padding-left: 16px;
}

.cj-header {
    top: 0;
    background-color: #000 !important;
    font-size: 18px !important;
}

.text-teal {
    color: #009688 !important;
}

.container {
    padding: 0.01em 16px;
    max-width: 100%;
    height: auto
}
.container:after,.container:before {
    content: "";
    display: table;
    clear: both;
}

@media (min-width: 1205px) {
    .img-half {
        width: 50%;
    }
}

@media (max-width: 1204px) {
    .img-half {
        width: 100%;
    }
}

.img-half {
    float: left;
    text-align: center!important;
}

.image:hover {
    opacity: 60%;
}

.root {
    margin-left: 250px;
    margin-bottom: 50px;
    min-width: 200px;
}

.anchor {
    scroll-margin-top: 60px;
}

.modal {
    z-index: 3;
    display: none;
    padding-top: 100px;
    position: fixed;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background-color: rgb(0,0,0);
    background-color: rgba(0,0,0,0.4)
}

.modal-content {
    background-color: #fff;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    min-width: 600px;
    width: 90%;
    max-width: 1200px;
}

.display-container {
    position: relative;
}

.background-text{
    display: inline-block;
    position: absolute;
    left: 0;
    bottom: 20px;
    width: 100%;
    min-width: 60px;
    padding-left: 8px;
    padding-right: 8px;
    z-index: -1;
    text-align: center;
}

.tooltip {
    position: relative
}

.tooltip div{
    border-bottom: 1px dotted black;
}

.tooltip span {
    position: absolute;
    left: 0;
    bottom: 20px;
    width: 100%;
    min-width: 60px;
    border-radius: 4px;

    background-color: #000;
    color: #fff;
    padding-left: 8px;
    padding-right: 8px;
    text-align: center;
    display: none;
}

.tooltip:hover span {
    display: inline-block;
}

.opaque {
    opacity: 60%;
}

.text-right {
    text-align: right;
}

.text-left {
    text-align: left;
}

.text-center {
    text-align: center;
}

.float-left {
    float: left !important;
}

.float-right {
    float: right !important;
}

code, .inline-code {
    color: crimson;
    background-color: #f0f0f0;
    padding-left: 4px;
    padding-right: 4px;
}

"""
let CASE_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
<title>$caseName</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="../styles.css">
</head>
<body>

  <div class="cj-header">
    <div class="default-padding float-left" style="background-color: #333333 !important;">Benchmark:  $caseName</div>
  </div>

<div class="sidebar shadow" id="mySidebar">

  <a class="left-button" href="#summary" onclick='displayContainer(this,"summary")'> > Summary</a>
  <div class="divider-border" style="margin-bottom:5px"></div>
  <div class="divider-border default-padding"><b>Parameters:</b></div>
  <div style="height: 100%; padding-bottom:140px;">
    <div style="margin-left:10px; overflow-y: auto; max-height: 100%;">
        {{Button
            <a class="left-button" href="#$parameterIndex" onclick='displayContainer(this,"$parameterIndex")'> > $parameterText</a>
        }}
        {!$parameters:Button!}

    </div>
  </div>
  <a class="left-button divider-border"
    style="bottom:0;position:absolute;"
    href="#explanation" onclick='displayContainer(this,"explanation")'>
        > Understanding report
  </a>
</div>

<!-- Main content: shift it to the right by 250 pixels when the sidebar is visible -->

<div class="root" >
    {{Statistics
    <tr>
        <td>$name</td>
        <td class="opaque text-right">$lower</td>
        <td class="text-center">$estimate</td>
        <td class="opaque text-left">$upper</td>
        <td>$change</td>
        {!
        <td class="text-center">
            <button onclick="openModal(this)">Show</button>
            <div class="modal">
                <object class="modal-content" data="$link" type="image/svg+xml"></object>
            </div>
        </td>
        !}
    </tr>
    }}
    {{ResultRow
        <tr>
            {!<td>$name</td>!}
            <td>$p10</td>
            <td>$median</td>
            <td>$p90</td>
            <td>$p95</td>
            <td>$p99</td>
            <td>$mean</td>
            <td>$mode</td>
            <td>$mode2</td>
            <td>$stddev</td>
            <td>$skewness</td>
            {!
            <td class="text-center">
                <button onclick="openModal(this)">Show</button>
                <div class="modal">
                    <object class="modal-content" data="$kdePath" type="image/svg+xml"></object>
                </div>
            </td>
            !}
        </tr>
    }}
    {{Empty
    }}
    {{Measurement
        <div class="container">
            <h3 class="text-teal anchor" id="$anchor" ><a href="#$anchor">$name</a></h3>
            $description
            <div class="container">
                <div class="img-half">
                    <div class="spacer"></div>
                    <div>Bootstrapped KDE</div>
                    <div class="display-container" style="min-height: 100px;">
                        <div class="background-text">Image does not exist. Are you sure that gnuplot is installed on your system?</div>
                        <div style="background-color: #fff;">
                            <img style="max-height: 360px; "  onclick="openModal(this.parentElement.parentElement)"
                                class="shadow image" src="$kdeImage">
                        </div>
                    </div>

                    <div class="modal">
                        <object class="modal-content" data="$kdeImage" type="image/svg+xml"></object>
                    </div>
                </div>

                <div class="img-half">
                    <div class="spacer"></div>
                    <div>Linear regression</div>
                    <div class="display-container" style="min-height: 100px;">
                        <div class="background-text">Image does not exist. Are you sure that gnuplot is installed on your system?</div>
                        <div style="background-color: #fff;">
                            <img style="max-height: 360px; "  onclick="openModal(this.parentElement.parentElement)"
                                class="shadow image" src="$linregImage">
                        </div>
                    </div>

                    <div class="modal">
                        <object class="modal-content" data="$linregImage" type="image/svg+xml"></object>
                    </div>
                </div>
            </div>
            <div class="spacer"></div>
            <div class="spacer"></div>

            <div class="container">
                <div style="max-width: 1000px;">
                    
                    <h6>Bootstrapped estimations</h6>
                    <table>
                        <tr>
                            {! <th></th>  $displayKde:Empty !}
                            <th>p10</th>
                            <th>median</th>
                            <th>p90</th>
                            <th>p95</th>
                            <th>p99</th>
                            <th>mean</th>
                            <th>mode</th>
                            <th>second mode</th>
                            <th>stddev</th>
                            <th>skewness</th>
                            {! <th>KDE</th> $displayKde:Empty !}
                        </tr>
                        {! $result:ResultRow !}
                    </table>
                    <div class="spacer"></div>

                    <h6>Regression statistics</h6>
                    <table>
                        <tr>
                        <th></th>
                        <th class="opaque">
                            <div class="tooltip">
                                <div class="float-right"> Lower Bound </div>
                                <span>99% Confidence interval</span>
                            </div>
                        </th>
                        <th class="text-center">Estimation</th>
                        <th class="opaque">
                            <div class="tooltip">
                                <div class="float-left"> Upped Bound </div>
                                <span>99% Confidence interval</span>
                            </div>
                        </th>
                        <th>
                            <div class="tooltip">
                                <div class="float-left"> Change </div>
                                <span>Change since previous Run</span>
                            </div>
                        </th>
                        <th class="text-center">Bootstrap distribution</th>
                        </tr>

                        {! $stats:Statistics !}
                    </table>
                </div>
            </div>
            <div class="default-padding" style="max-width: 900px; font-size: 12px;">
                <p>
                    $additionalInfo
                </p>
            </div>
        </div>
    }}

    {{Parameter
    <div class="main" id="$parameterIndex">
        {!$measurement:Measurement!}
    </div>
    }}

    {!$parameters:Parameter!}

    <div class="main" id="explanation">
        <div class="container">
        <div class="container">
        <div class="container">
            <div class="spacer"></div>
            <div class="spacer"></div>
            <p>
            This page contains all statistics results for a single benchmark case. On the left there are tabs with results for each parameter.
            Each tab contains all measurements and statistics for a single set of input parameters of parameterized benchmark.
            For each type of measurement there is a:
            <ul>
              <li>Plot with estimated probability density function for how much time or other measurement does the execution of benchmarked function take excluding any overhead.
                  The estimated distribution is calculated using standard random non-parametric resampling bootstrapping. Then actual probability density function is calculated with KDE method.
                  </li>
              <li>Plot that displays all raw measurements made by the framework with mean and median linear regression results for that data.
                  The framework measures execution of benchmarked code in increasing batches for better precision.
                  So there should be a clear linear dependency between batch size and raw measurement.
                  Thus if there is a clear non-linearity on the plot, it is likely that benchmark was written incorrectly and might measure not what was expected.
                  </li>
              <li>Concrete values for all statistical parameters calculated by the framework with their <code>99%</code> confidence interval and bootstrap distribution.</li>
              <li>Change since previous run or baseline, if available.</li>
            </ul>
            </p>

            <div class="spacer"></div>
            <p>
                Benchmarking is a part of Cangjie unittest framework.
                For more details please refer to the documentation for Cangjie <code>std.unittest</code> module or to the manual for Cangjie unittest framework.
            </p>

        </div>
        </div>
        </div>
    </div>

    <div class="main" id="summary">
        <div class="container">
            <h3 class="text-teal" id="Duration"><a>Summary</a></h3>
            <div class="container">
                <table>
                    <tr>
                        {!<th>$summaryHeaders</th>!}
                    </tr>
                    {{Row
                    <tr>
                        {!<td>$col</td>!}
                    </tr>
                    }}
                    {!$summaryRows:Row!}

                </table>
            </div>
            <h3 class="text-teal" id="Duration"><a>Environment</a></h3>
            <div class="container">
                <table>
                    {{EnvRow
                    <tr>
                        <td>$name</td>
                        <td>$value</td>
                    </tr>
                    }}
                    {!$envRows:EnvRow!}
                </table>
            </div>
        </div>
    </div>

    <footer>
        <div class="cj-footer">
          <p>Generated by Cangjie unittest framework.</p>
        </div>
    </footer>
<!-- END MAIN -->
</div>

<script>

displayContainer(null, window.location.hash.split("+")[0])
if (!window.location.hash.includes("+")){
    history.replaceState(null, null, '#');
} else {
    history.replaceState(null, null, window.location.hash);
    let target = document.getElementById(window.location.hash.replace('#', ''))
    target.scrollIntoView(true)
}

let modals = document.getElementsByClassName("modal")
for (let modal of modals) {
    modal.addEventListener("click", function(e) {
        e = window.event || e;
        if(modal === e.target) {
            modal.style.display='none'
            document.body.parentElement.style.overflow = 'auto';
        }
    });
}

function openModal(el) {
    el.nextElementSibling.style.display='block';
    document.body.parentElement.style.overflow = 'hidden';
}

function displayContainer(clicked, id) {
    let targetId = id.replace('#','')
    const params = document.getElementsByClassName("main");
    var found = false
    for (let i = 0; i < params.length; i++) {
        let item = params.item(i)
        if (item.id == targetId) {
            item.style.display = 'block'
            found = true
        } else {
            item.style.display = 'none'
        }
    }
    if (!found) {
        params.item(params.length-1).style.display = 'block'
    }

    if (clicked) {
        // make back button return back to original page
        history.replaceState(null, null, "#")
        clicked.setAttribute("href", "#");
    }

    const buttons = document.getElementsByClassName("left-button");
    for (let i = 0; i < buttons.length; i++) {
        let item = buttons.item(i)
        item.classList.remove("clicked")

    }

    let selected = clicked == null ? buttons[0] : clicked
    selected.classList.add("clicked")

}

</script>

</body>
</html>
"""
let ROOT_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
<title>Cangjie benchmark report</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="styles.css">
</head>
<style>
ul {
    list-style-type: none;
    list-style-position: inside;
    padding: 0;
    margin: 0
}
ul li {
    padding: 8px 16px;
    border-bottom: 1px solid #ddd
}

ul li:last-child {
    border-bottom: none
}
.case {
    padding-left: 64px;
    list-style-type: circle;
}
</style>
<body>
<div >
    <div style="position: absolute;left: 50%;transform: translate(-50%, -0%);max-width: 1024px; width: 95%; min-width: max-content;">
        <h4> Cangjie Benchmark report</h4>
        <ul style="border: 1px solid #ccc!important">
            {{Func
                <li class="case">func $func<a class="float-right" href="$link">Details</a> </li>
            }}
            {{Fail
                <li class="case">func $func <a class="float-right" style="color: red;">Failed</a> </li>
            }}
            {{Class
                <li style="padding-left: 40px;">class $name :</li>
                {! $funcs:Func !}
                {! $failures:Fail !}
            }}
            {{Package
                <li>package $name :</li>
                {! $classes:Class !}
            }}
            $package:Package
        </ul>
    </div>
</div>
</body>
</html>
"""
var gnuplotAvailable: Bool = true

extend TestGroupResult {
    func reportHtml(dir: Path): Unit {
        let rc = try {
            Process.run("gnuplot", ["--version"], stdOut: Discard, stdErr: Discard)
        } catch (_: ProcessException) {
            1
        }
        if (rc != 0) {
            gnuplotAvailable = false
            println("Warning: gnuplot executable not found. It is used by html reporting for drawing plots.")
            println("         Have you installed gnuplot?")
        }

        Directory.ensureExists(dir)
        let caseResults = collectAllResults(dir)

        for ((name, results) in caseResults) {
            let subdir = dir.join(name.fqName())
            Directory.ensureExists(subdir)

            let data = Root(CASE_TEMPLATE).substitute(results)
            File.writeTo(
                subdir.join("index.html"),
                data.toArray()
            )
        }

        let classes = collectClassObjects(caseResults.keys())

        let htmlBytes = Root(ROOT_TEMPLATE).substitute(object([("package", object([("name", groupName), ("classes", classes)]))]))

        //write html
        File.writeTo(
            dir.join("index.html"),
            htmlBytes.toString().toArray()
        )
        println("Html report available at ${dir.join("index.html")}")

        // write css
        File.writeTo(
            dir.join("styles.css"),
            STYLES.toString().toArray()
        )
    }

    func collectClassObjects(passedFQNames: Iterable<TestCaseId>): ArrayList<JsonObject> {
        let failedCases = HashSet<TestCaseId>()
        this.visitFailedSteps { step, result => failedCases.add(result.caseId) }
        passedFQNames
            .iterator()
            .concat(failedCases.iterator())
            .groupBy { id => id.suiteId }
            .map<JsonObject> { it =>
                let (k, v) = it
                let funcs = v.iterator()
                    .filter { x => !failedCases.contains(x) }
                    .map { v => object([("func", "${v.caseName}()"), ("link", "${v.fqName()}/index.html")]) }
                    .into(collectArray<JsonObject>)
                let failures = v.iterator()
                    .filter { x => failedCases.contains(x) }
                    .map { v => object([("func", "${v.caseName}()")]) }
                    .into(collectArray<JsonObject>)
                object( [("name", k.suiteName), ("funcs", funcs), ("failures", failures)] )
            }
            .into(collectArrayList<JsonObject>)
    }

    func envRow<T>(name: String, value: T): JsonObject where T <: ToString {
        object([("name", JsonString(name)), ("value", JsonString(value.toString()))])
    }

    func collectEnvironment(): JsonArray {
        let result = JsonArray()

        result.add(envRow("Finished", DateTime.now().format("yyyy/MM/dd HH:mm:ss")))
        result.add(envRow("OS", tryGetNative(getOsVersion)))
        result.add(envRow("CPU", tryGetNative(getCpuName)))
        result.add(envRow("Compiler", tryGetNative(getCompilerVersion)))
        result.add(envRow("target", tryGetNative(getTargetTriple)))

        for ((env, value) in getVariables()) {
            if (env.toAsciiLower().startsWith("cj")) {
                result.add(envRow("ENV: ${env}", value))
            }
        }

        result
    }

    func tryGetNative(f: () -> String): String {
        try {
            f()
        } catch (e: ProcessException) {
            e.toString()
        }
    }

    // creates json model suitable for the template for all benchmarks
    func collectAllResults(directory: Path): HashMap<TestCaseId, JsonValue> {
        let env = collectEnvironment()
        let results = HashMap<TestCaseId, JsonValue>()
        let summaryHeaders = HashMap<String, HashSet<String>>()

        this.visitPassedBenches { step =>
            let id = step.caseId

            let fullName = id.fqName()
            let result = results.getOrInsert(id){ object([
                    ("caseName", JsonString("${fullName}()")),
                    ("parameters", JsonArray()),
                    ("summaryHeaders", JsonArray([JsonString("Parameter")])),
                    ("summaryRows", JsonArray()),
                    ("envRows", env)
                ]) }.asObject()
            Directory.ensureExists(directory.join(fullName))

            let parameters = result["parameters"].asArray()
            let parameter = parameters.get(step.arg.stepIndex)?.asObject() ?? JsonObject()
            let paramText = step.arg.textDescription?.toString() ?? "-"
            parameter.put("parameterText", JsonString(paramText))
            parameter.put("parameterIndex", JsonString("parameter${step.arg.stepIndex}"))

            let mName = step.measurementInfo.name
            if (!summaryHeaders.getOrInsert(fullName, HashSet()).contains(mName)) {
                summaryHeaders[fullName].add(mName)
                result.arrayFieldAppend("summaryHeaders", JsonString(mName))
            }

            let measurementIndex = parameter.get("measurement")?.asArray().size() ?? 0
            let (mean, measurementValue) = measurementModel(step, directory.join(fullName), measurementIndex)
            parameter.arrayFieldAppend("measurement", measurementValue)

            if (parameters.get(step.arg.stepIndex).isNone()) {
                // it is a first measument for this parameter
                parameters.add(parameter)
                let row = JsonObject()
                row.put("col", JsonArray([JsonString(paramText)]))
                result.arrayFieldAppend("summaryRows", row)
            }
            let converter = step.measurementInfo.conversionTable
            result["summaryRows"]
                .asArray()[step.arg.stepIndex]
                .asObject()["col"]
                .asArray()
                .add(JsonString(converter.toString(mean)))
        }

        results
    }
}

func processPercentiles(step: BenchStepEntry, directory: Path): JsonObject {
    let measurementValue = JsonObject()
    let stats = step.result

    func addPercentiles(bootstrapped: BootstrapResult): String {
        let converter = step.measurementInfo.conversionTable 
        let mName = step.measurementInfo.name
        let hasTwoKdes = stats.bootstrapped.allPoints.isSome()   
        let sample = bootstrapped.resultSample

        let file = "${mName}_${step.arg.stepIndex}_kde_${bootstrapped.separateGc.toString().toSafeFileName()}.svg"
        sample.drawKde(directory.join(file))

        let result1 = sample.createPercentilesRow(converter)
        if (hasTwoKdes) {
            result1.put("kdePath", JsonString(file))
            result1.put("name", JsonString("${bootstrapped.separateGc}:"))
        } else {
            result1.put("name", JsonNull())
        }
        measurementValue.arrayFieldAppend("result", result1)

        file
    }
    
    let kdeFile = addPercentiles(stats.bootstrapped)
    measurementValue.put("kdeImage", JsonString(kdeFile))

    if (let Some(all) <- stats.bootstrapped.allPoints) {
        measurementValue.put("displayKde", JsonBool(true))
        addPercentiles(all)
        
    }  
    measurementValue
}

// creates json model suitable for the Measurement subtemplate for one benchmark result
func measurementModel(step: BenchStepEntry, directory: Path, index: Int64): (Float64, JsonObject) {   
    let mName = step.measurementInfo.name
    let stats = step.result
    
    let linregFile = "${mName}_${step.arg.stepIndex}_linreg.svg"
    try {
        stats.draw(directory.join(linregFile), step.measurementInfo.conversionTable[0][1])
    } catch (e: Exception) {
        eprintln("Error: Failed to draw ${e.toString()}")
    }

    let percentiles = spawn { processPercentiles(step, directory) } 

    let imgDir = directory.join("${mName}_${step.arg.stepIndex}")
    Directory.ensureExists(imgDir)
    let name = if (stats.bootstrapped.separateGc.hasSeparation()) {
        "(${stats.bootstrapped.separateGc})"
    } else {
        ""
    }
    let futures = ArrayList([
        spawn { stats.bootstrapped.meanStats.createStatsRow("mean slope${name}", imgDir) },
        spawn { stats.bootstrapped.medianStats.createStatsRow("median slope${name}", imgDir) },
        spawn { stats.bootstrapped.overhead.createStatsRow("overhead${name}", imgDir) },
        spawn { stats.bootstrapped.r2Stats.createStatsRow("R-squared${name}", imgDir) }
    ])

    if (let Some(separated) <- stats.bootstrapped.allPoints) {
        futures.add(all: [
            spawn { separated.meanStats.createStatsRow("mean slope", imgDir) },
            spawn { separated.medianStats.createStatsRow("median slope", imgDir) },
            spawn { separated.overhead.createStatsRow("overhead", imgDir) },
            spawn { separated.r2Stats.createStatsRow("R-squared", imgDir) }
        ])
    }

    // wait before others to prevent data race
    let measurementValue = percentiles.get()

    let start = DateTime.now()
    for (rowFut in futures) {
        try {
            let remaining = Duration.second * 20 - (DateTime.now() - start)
            let row = rowFut.get(remaining) ?? continue
            measurementValue.arrayFieldAppend("stats", row)
        } catch (_: TimeoutException) {
            println("Warning: analysis takes too long")
        }
    }

    measurementValue.put("anchor", JsonString("parameter${step.arg.stepIndex}+measure${index}"))
    measurementValue.put("linregImage", JsonString(linregFile)) 
    measurementValue.put("name", JsonString(mName))
    measurementValue.put("description", JsonString(step.measurementInfo.textDescription))
    measurementValue.put("additionalInfo", JsonString(""))

    (stats.mean, measurementValue)
}

extend StatisticsSample {
    func createPercentilesRow(converter: MeasurementUnitTable): JsonObject {
        let result = JsonObject()
        if (isEmpty()) { return result }
        result.put("p10", JsonString(converter.toString(this.sample.percentile(0.10))))
        result.put("median", JsonString(converter.toString(this.sample.percentile(0.50))))
        result.put("p90", JsonString(converter.toString(this.sample.percentile(0.90))))
        result.put("p95", JsonString(converter.toString(this.sample.percentile(0.95))))
        result.put("p99", JsonString(converter.toString(this.sample.percentile(0.99))))
        result.put("mean", JsonString(converter.toString(this.sample.mean())))
        result.put("mode", JsonString(converter.toString(this.mode)))
        result.put("stddev", JsonString(converter.toString(this.sample.stddev())))
        result.put("skewness", JsonString([(1.0, "")].toString(this.sample.skewness())))
        let mode2 = this.mode2()
        if (mode2.isNormal()) {
            result.put("mode2", JsonString(converter.toString(mode2)))
        } else {
            result.put("mode2", JsonString("-"))
        }
        result
    }
    func createStatsRow(name: String, dir: Path, change!: ?Float64 = None): ?JsonObject {
        let fileName = name.replace(" ", "") + ".svg"
        Directory.ensureExists(dir)
        try {
            this.drawKde(dir.join(fileName))
        } catch (e: Exception) {
            return None
        }
        let parentDir = dir.fileName

        let converter = [(1.0, "")]
        let result = JsonObject()
        result.put("name", JsonString(name))
        result.put("lower", JsonString(converter.toString(this.sample.percentile(0.01))))
        result.put("estimate", JsonString(converter.toString(this.sample.percentile(0.5))))
        result.put("upper", JsonString(converter.toString(this.sample.percentile(0.99))))
        result.put("change", if (let Some(chg) <- change) { JsonFloat(chg) } else { JsonString("-") })
        result.put("link", JsonString("${parentDir}/${fileName}"))
        result
    }
    
    func writeDataToFile(folder: Path, kde: ArrayList<(Float64, Float64)>, digits: Int64): Path {
        let dataFile = File.createTemp(folder)

        for (i in 0..kde.size) {
            dataFile.write("${kde[i][0].format(".6g")} ${kde[i][1].format(".${digits}")}\n".toArray())
        }
        dataFile.close()
        dataFile.info.path
    }
    
    func drawKde(into: Path, second!: ?StatisticsSample = None) {
        if (!gnuplotAvailable) {
            return
        }

        let kde = this.kde
        let kde2 = second?.kde

        let (mode, maxDensity) = kde.iterator().maxBy{ a => a[1] }
        if (!maxDensity.isNormal()) {
            println("Error for kde on data: ${sample.data}")
            return
        }

        let digits = max(-Int64(floor(log10(maxDensity))) + 3, 1)
        let noGcFile = writeDataToFile(into.parent, kde, digits)

        var gcData = ""
        if (let Some(kdeGc) <- kde2) {
            let withGcFile = writeDataToFile(into.parent, kdeGc, digits)
            gcData = "'${withGcFile}' using 1:2 with lines title \"kde(full)\" smooth mcsplines, "
        }

        let maxy = (maxDensity * 1.05).format(".${digits}");

        let mode2 = mode2()
        let mode2line = if (mode2.isNaN()) {
            ""
        } else {
            "[t=0:${maxy}] '+' using (${mode2}):(t) with lines lw 1 title \"mode2\","
        }

        let script = """
            set term svg size 1200,800 dynamic mouse standalone font "Arial,23";
            set key outside reverse center right Left;
            set lmargin at screen 0.085;
            set datafile missing "nan";
            set output \"${into}\";
            set yrange [0.0:${maxy}];
            plot '${noGcFile}' using 1:2 with lines title "kde" smooth mcsplines,
                ${gcData}
                [t=0:${maxy}] '+' using (${median}):(t) with lines lw 1 title "median",
                [t=0:${maxy}] '+' using (${mean}):(t) with lines lw 1 title "mean",
                [t=0:${maxy}] '+' using (${mode}):(t) with lines lw 1 title "mode",
                ${mode2line}
                [t=0:${maxy}] '+' using (${sample.percentile(0.95)}):(t) with lines lw 1 title "p95";
            """
        let (rc, _, _) = Process.runOutput("gnuplot", ["-e", script])

        if (rc != 0) {
            eprintln("Error: gnuplot call failed.")
        }
        fixGnuplotSvg(into)
        remove(noGcFile)
    }
}

extend BenchmarkResult {
    func writeDataToFile(folder: Path, upperBound: Float64): Path {
        let dataFile = File.createTemp(folder)

        for ((batchSize, timeNanos, gc) in this.data) {
            dataFile.write("${Int64(batchSize)} ${Int64(min(timeNanos, upperBound))} ${gc}\n".toArray())
        }
        dataFile.close()
        dataFile.info.path
    }

    func draw(into: Path, mName: String) {
        if (!gnuplotAvailable) {
            return
        }
        let maxx = this.data.iterator().maxBy{ x => x[0] }[0]
        let miny = this.data.iterator().minBy{ x => x[1] }[1]
        let (maxyPos, maxy, _) = this.data.iterator().maxBy { x => x[1] }
        let max98 = Sample(this.data |> map { x: BenchRawMeasurement => x[1] } |> collectArrayList).percentile(0.98)
        let result = bootstrapped.medianStats.median
        let overhead = bootstrapped.medianOverheadStats.mean

        // prevent major outliers to ruin whole image
        let upperBound = min(max(maxx * result * 1.4 + overhead, max98 * 1.2), maxy + (maxy-miny)*0.5) + 0.000001
        let lowerBound = miny*0.99

        let dataFile = writeDataToFile(into.parent, upperBound)

        let name = bootstrapped.separateGc
        var lines = "    x*${result}+${overhead} with lines lc rgb \"red\" title \"median(${bootstrapped.separateGc})\",\n"
        lines += "    x*${bootstrapped.meanStats.mean}+${bootstrapped.meanOverheadStats.mean} with lines lc rgb \"green\" title \"OLS(${bootstrapped.separateGc})\" "

        if (let Some(separated) <- bootstrapped.allPoints) {
            lines += ",\n"
            lines += "    x*${separated.medianStats.mean}+${separated.medianOverheadStats.mean} with lines lc rgb \"yellow\" title \"median(all)\",\n"
            lines += "    x*${separated.meanStats.mean}+${separated.medianOverheadStats.mean} with lines lc rgb \"orange\" title \"OLS(all)\" "
        }

        var data  = ""
        data += "'${dataFile}' using 1:(($3 == 1) ? $2 : (1/0)) with points pointtype 2 lc rgb '#88ca336d' title \"with GC\",\n"
        data += "'${dataFile}' using 1:(($3 == 0) ? $2 : (1/0)) with points pointtype 2 lc rgb '#889d00ff' title \"without GC\",\n"
        if (this.data.iterator().any { x => x[2] > 1.99 }) {
            data += "'${dataFile}' using 1:(($3 >= 2) ? $2 : (1/0)) with points pointtype 2 lc rgb '#88000000' title \"double GC\",\n"
        }

        let script = """
            set key at screen 1.03,0.5 reverse center right Left;
            set term svg size 1200,800 dynamic mouse standalone font "Arial,23";
            set output "${into}";
            set lmargin at screen 0.090;
            set rmargin at screen 0.77;
            set label "${mName}" at graph 0.0, 1.0 right front offset character -1,0.3;
            set label "max=${maxy.format(".2g")}" at first ${maxyPos}, ${min(upperBound, maxy)} left front offset character 0,0.4 font "Arial,18";
            set object circle at first ${maxyPos}, ${min(upperBound, maxy)} radius char 0.5 front noclip fillstyle empty border lc rgb '#aa1100';
            set label "batch size" at graph 1.0, 0.0 left front offset character 3,-1;
            set yrange [${lowerBound}:${upperBound}];
            plot
                ${data}
                ${lines};
            """
        let (rc, _, _) = Process.runOutput("gnuplot", ["-e", script])
        if (rc != 0) {
            eprintln("Error: gnuplot call failed.")
        }
        fixGnuplotSvg(into)
        remove(dataFile)
    }
}

// gnuplot 6.0's svg terminal wraps its JavaScript in a CDATA section, but the
// script contains the literal "]]>" (in a replaceAll that strips CDATA markers
// from innerHTML). That sequence prematurely closes the CDATA, so the later JS
// (which uses "<"/">" as comparison operators) is parsed as XML markup and the
// SVG stops being well-formed. Rewrite that one JS string literal so "]]>" no
// longer appears verbatim (string concatenation yields the same value at
// runtime). No-op when the bug is absent.
protected func fixGnuplotSvg(path: Path): Unit {
    if (!exists(path)) {
        return
    }
    let content = String.fromUtf8(File.readFrom(path))
    let buggy = "replaceAll(\"]]>\", \"\")"
    if (!content.contains(buggy)) {
        return
    }
    let fixed = content.replace(buggy, "replaceAll(\"]]\" + \">\", \"\")")
    let out = File(path, OpenMode.Write)
    out.write(fixed.toArray())
    out.close()
}

extend JsonObject {
    func arrayFieldAppend<T>(name: String, value: T): T where T <: JsonValue {
        let array = this.get(name)?.asArray() ?? JsonArray()
        array.add(value)
        this.put(name, array)
        value
    }
}

let NO_INFO = "Could not retrieve information"

@When[os == "Windows"]
func getOsVersion(): String {
    let (rc, stdout, _) = Process.runOutput("cmd", ["/c", "ver"])
    if (rc != 0) { return NO_INFO }

    String.fromUtf8(stdout)
}

@When[os == "Linux"]
func getOsVersion(): String {
    let (rc, stdout, _) = Process.runOutput("uname", ["-a"])
    if (rc != 0) { return NO_INFO }

    String.fromUtf8(stdout)
}

@When[os == "macOS"]
func getOsVersion(): String {
    "macOS"
}

@When[os == "iOS"]
func getOsVersion(): String {
    "iOS"
}

@When[os == "Linux"]
func getCpuName(): String {
    let (rc, stdout, _) = Process.runOutput("lscpu", [])
    if (rc != 0) { return NO_INFO }
    let intermediate = String.fromUtf8(stdout)

    let matched = Regex("Model name:[\\s]*([^\\r\\n]+)").matcher(intermediate).find()

    matched?.matchString(1) ?? return NO_INFO
}

@When[os == "macOS"]
func getCpuName(): String {
    let (rc, stdout, _) = Process.runOutput("sysctl", ["-a"])
    if (rc != 0) { return NO_INFO }
    let intermediate = String.fromUtf8(stdout)

    let matched = Regex("machdep.cpu.brand_string:[\\s]*([^\\r\\n]+)").matcher(intermediate).find()

    matched?.matchString(1) ?? return NO_INFO
}

@When[os == "iOS"]
func getCpuName(): String {
    "unknown"
}

@When[os == "Windows"]
func getCpuName(): String {
    let (rc, stdout, _) = Process.runOutput("cmd", ["/c", "wmic", "cpu", "get", "name"])
    if (rc != 0) { return NO_INFO }
    String.fromUtf8(stdout)
}

func getCompilerVersion(): String {
    let (rc, stdout, _) = Process.runOutput("cjc", ["--version"])
    if (rc != 0) { return NO_INFO }
    String.fromUtf8(stdout).lines().next() ?? return NO_INFO
}

func getTargetTriple(): String {
    let (rc, stdout, _) = Process.runOutput("cjc", ["--version"])
    if (rc != 0) { return NO_INFO }
    let intermediate = String.fromUtf8(stdout)

    let matched = Regex("Target:[\\s]*([^\\r\\n]+)").matcher(intermediate).find()

    matched?.matchString(1) ?? return NO_INFO
}
extend<V> Iterator<V> {
    func into<R>(f: (Iterable<V>) -> R): R {
        f(this)
    }

    func groupBy<K>(keyFor: (V) -> K): Iterator<(K, Array<V>)>
        where K <: Hashable & Equatable<K>
    {
        let result = HashMap<K, ArrayList<V>>()
        func putValue(k: K, value: V): Unit {
            match (result.get(k)) {
                case Some(list) => list.add(value)
                case None => result.add(k, ArrayList<V>.of(value))
            }
        }

        for (value in this) {
            putValue(keyFor(value), value)
        }

        return result.iterator().map { pair =>
            let (k, list) = pair
            (k, list.toArray())
        }
    }
}
