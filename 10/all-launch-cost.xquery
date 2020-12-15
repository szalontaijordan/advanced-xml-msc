(:
 : 10. Mennyibe került az eddigi összes kilövés? (tetszőleges pénznemben)
 :)
xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

declare function local:get-rate-for-USD($currency as xs:string) as xs:double {
    let $response := fn:json-doc("https://api.ratesapi.io/api/latest?base=USD")
    let $rate := $response?rates($currency => fn:upper-case()) => xs:double()
    let $valid := array { $response?rates => map:keys() } => fn:serialize(map { "method": "json" })

    return
        if ($rate => fn:exists())
        then $rate
        else fn:error(xs:QName("FOER0000"), "Invalid target currency. Valid currencies are: " || $valid)
};

let $currency := "HUF"
let $rate := $currency => local:get-rate-for-USD()

let $baseUrl := "https://api.spacexdata.com/v4"
let $launches := fn:json-doc($baseUrl ||"/launches")?*
let $rockets := fn:json-doc($baseUrl || "/rockets")?*

let $usedRockets := $launches => fn:for-each(function($launch) {
    map { $launch?name: $rockets[?id eq $launch?rocket]?cost_per_launch * $rate }
})

let $details := $usedRockets => map:merge()
let $totalUSD := $details => map:for-each(function($k, $v) { $v }) => fn:sum()

return map {
    "$currency": $currency => fn:upper-case(),
    "total": $totalUSD * $rate,
    "details": $details
}
