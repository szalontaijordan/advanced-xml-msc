(:
 : 2. Egyes kilövések átlagos payload tömege
 :)
xquery version "3.1";

import schema default element namespace "" at "average-payload.xsd";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:get-avg-entry($id as xs:string, $payloads as item()*) as map(xs:string, item()*) {
    let $launchPayloads := $payloads[?launch eq $id]
    return
        map {
            $id: map {
                "kg": $launchPayloads?mass_kg => fn:avg() => fn:round(3),
                "lbs": $launchPayloads?mass_lbs => fn:avg() => fn:round(3),
                "payloads": $launchPayloads => fn:count()
            }
        }
};

declare function local:create-payload-map($launches as item()*, $payloads as item()*) as map(xs:string, item()*) {
    let $maps := $launches ! local:get-avg-entry(?id, $payloads)
    return
        $maps => map:merge()
};

let $baseUrl := "https://api.spacexdata.com/v4"

let $launches := fn:json-doc($baseUrl || "/launches")?*
let $payloads := fn:json-doc($baseUrl || "/payloads")?*
let $avgMap := local:create-payload-map($launches, $payloads)

let $summary := $avgMap => map:for-each(function($id, $avg) {
    let $kgs := if (fn:exists($avg?kg)) then $avg?kg else 0
    let $lbs := if (fn:exists($avg?lbs)) then $avg?lbs else 0
    return
        <launch id="{$id}" kgs="{$kgs}" lbs="{$lbs}" payload-count="{$avg?payloads}" />
})

return validate {
    document {
        comment { "Data is from the SpaceX API https://github.com/r-spacex/SpaceX-API/blob/master/docs/v4/README.md | " || fn:current-dateTime() },
        <payload-mass-summary>
            {
                for $launch in $summary
                order by $launch/@kgs descending
                return $launch
            }
        </payload-mass-summary>
    }
}

