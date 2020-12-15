(:
 : 8. Az aktív Starlink műholdak
 :)
xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:html-version "5.0";
declare option output:indent "yes";

declare function local:create-js-points($starlink as item()*) as xs:string {
    let $tmp := $starlink ! ("[" || ?latitude || "," || ?longitude || "]")
    return ("[" || $tmp => fn:string-join(",") || "]")
};

declare function local:get-between($starlink as item()*, $low as xs:integer, $high as xs:integer) as item()* {
    $starlink[?height_km le $high and ?height_km ge $low] => local:create-js-points()
};

let $baseUrl := "https://api.spacexdata.com/v4"
let $starlink := fn:json-doc($baseUrl || "/starlink")?*[fn:exists(?latitude)]

let $low := $starlink => local:get-between(0, 350)
let $medium := $starlink => local:get-between(350, 500)
let $high := $starlink => local:get-between(500, 100000)

return document {
    <html>
        <head>
            <title>Active Starlink Satelites</title>
            <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7/leaflet.css" />
            <link rel="stylesheet" href="starlink.css" />
            <script src="http://cdn.leafletjs.com/leaflet-0.7/leaflet.js" />
            <script src="https://d3js.org/d3.v3.min.js" type="text/javascript" />
        </head>
        <body>
            <div id="map">{ comment { "Data is from the SpaceX API https://github.com/r-spacex/SpaceX-API/blob/master/docs/v4/README.md " } }</div>
        </body>
        <script>const points = [{$low}, {$medium}, {$high}]</script>
        <script src="starlink.js" />
    </html>
}

