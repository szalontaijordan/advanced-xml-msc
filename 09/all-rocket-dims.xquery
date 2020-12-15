(:
 : 9. Milyen hengerben férne el az összes rakéta egymásra pakolva?
 :)
xquery version "3.1";

declare namespace math = "http://www.w3.org/2005/xpath-functions/math";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

let $baseUrl := "https://api.spacexdata.com/v4"
let $rockets := fn:json-doc($baseUrl || "/rockets")?*

let $r := ($rockets?diameter?meters => fn:max()) div 2
let $height := $rockets?height?meters => fn:sum()

let $mass := $rockets?mass?kg => fn:sum()

return map {
    "dimensions": map {
        "$units": "meter",
        "r": $r,
        "h": $height
    },
    "surface_area": map {
        "$units": "squaremeter",
        "value": (2 * (math:pi() * $r * $height + math:pi() * $r => math:pow(2))) => fn:round(2)
    },
    "volume": map {
        "$units": "cubicmeter",
        "value": ($r => math:pow(2) * math:pi() * $height) => fn:round(2)
    },
    "rocket_mass": map {
        "$units": "kg",
        "value": $mass
    }
}
