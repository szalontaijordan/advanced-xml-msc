(:
 : 6. Egyes kilövőállásokon történt kilövések sikerének aránya
 :)
xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";


let $baseUrl := "https://api.spacexdata.com/v4"
let $launchpads := fn:json-doc($baseUrl || "/launchpads")?*[?launch_attempts gt 0]

return $launchpads => fn:for-each(function($pad) {
    let $total := xs:double($pad?launch_attempts)
    let $successes := xs:double($pad?launch_successes)

    return map {
        (($pad?name, $pad?locality, $pad?region) => fn:string-join(", ")): (($successes div $total)  * 100) => fn:round(2) || "%"
    }
}) => map:merge()
