(:
 : 3. Kilövések negyedéves bontásban
 :)
xquery version "3.1";

import schema default element namespace "" at "quarter-launches.xsd";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:create-launch($launch as map(xs:string, item()*)) as element(launch) {
    <launch id="{$launch?id}" upcoming="{$launch?upcoming}">
        <name>{$launch?name}</name>
        <date>{$launch?date_utc}</date>
        {
            if (fn:exists($launch?details))
            then <description>{$launch?details}</description>
            else ()
        }
        {
            if (fn:exists($launch?links?youtube_id))
            then <video href="{"https://youtube.com/watch?v=" || $launch?links?youtube_id }" />
            else ()
        }
    </launch>
};

declare function local:get-launch-year($launch as map(xs:string, item()*)) as xs:integer {
    $launch?date_utc => xs:dateTime() => fn:year-from-dateTime()
};

declare function local:get-launch-quarter($launch as map(xs:string, item()*)) as xs:string {
    let $month := $launch?date_utc => xs:dateTime() => fn:month-from-dateTime()
    return 
        if ($month lt 4)
        then "Q1"
        else if ($month lt 7)
            then "Q2"
            else if ($month lt 10)
            then "Q3"
            else "Q4"
};

declare function local:create-quarters($launches as item()*) as map(*)* {
    for $launch in $launches
    group by $year := $launch => local:get-launch-year()
    return map {
        $year:
            for $items in $launch
            group by $quarter := $items => local:get-launch-quarter()
            return map {
                $quarter: $items
            }
    }
};

declare function local:create-years-with-quarters($launches as item()*) as element(year)* {
    let $yearGroups := $launches => local:create-quarters() => map:merge()
    return
        $yearGroups => map:for-each(function($year, $quarters) {
            let $total := 0
                + $quarters?Q1 => fn:count()
                + $quarters?Q2 => fn:count()
                + $quarters?Q3 => fn:count()
                + $quarters?Q4 => fn:count()

            return
                <year value="{$year}" launches="{$total}">
                    <Q1 launches="{$quarters?Q1 => fn:count()}">{$quarters?Q1 ! local:create-launch(.)}</Q1>
                    <Q2 launches="{$quarters?Q2 => fn:count()}">{$quarters?Q2 ! local:create-launch(.)}</Q2>
                    <Q3 launches="{$quarters?Q3 => fn:count()}">{$quarters?Q3 ! local:create-launch(.)}</Q3>
                    <Q4 launches="{$quarters?Q4 => fn:count()}">{$quarters?Q4 ! local:create-launch(.)}</Q4>
                </year>
    })
};

let $baseUrl := "https://api.spacexdata.com/v4"
let $launches := fn:json-doc($baseUrl || "/launches")?*
let $years := $launches => local:create-years-with-quarters()

return validate {
    document {
        comment { "Data is from the SpaceX API https://github.com/r-spacex/SpaceX-API/blob/master/docs/v4/README.md " },
        <years launches="{$launches => fn:count()}">
            {
                for $year in $years
                order by $year/@value descending
                return $year
            }
        </years>
    }
}



