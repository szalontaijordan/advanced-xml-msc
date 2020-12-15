(:
 : 5. A legalább kétszer újrahasznált kapszulák tömbje
 :)
xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

declare function local:expand-launches($capsule as map(xs:string, item()*), $launches as item()*) as map(xs:string, item()*) {
    let $expandedLaunches := $capsule?launches => array:for-each(function($id) { $launches[?id eq $id] })

    let $tmp := map {
        "launches": $expandedLaunches => array:for-each(function($launch) {
            map {
                "id": $launch?id,
                "name": $launch?name,
                "date": $launch?date_utc
            }
        })
    }
    
    return ($capsule, $tmp) => map:merge(map { "duplicates": "use-last" })
};

let $baseUrl := "https://api.spacexdata.com/v4"

let $launches := fn:json-doc($baseUrl || "/launches")?*
let $capsules := fn:json-doc($baseUrl || "/capsules")?*[?reuse_count gt 1]

return array {$capsules ! local:expand-launches(., $launches)}
