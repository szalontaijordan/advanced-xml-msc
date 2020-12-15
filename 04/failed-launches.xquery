(:
 : 4. Sikertelen kilövések
 :)
xquery version "3.1";

import schema default element namespace "" at "failed-launches.xsd";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "xml";
declare option output:indent "yes";

let $baseUrl := "https://api.spacexdata.com/v4"
let $launches := fn:json-doc($baseUrl || "/launches")?*
let $failed := $launches[fn:not(?upcoming) and fn:not(?success)]

return validate {
    document {
        comment { "Data is from the SpaceX API https://github.com/r-spacex/SpaceX-API/blob/master/docs/v4/README.md " },
        <launches>
            {
                for $launch in $failed
                order by $launch?date_utc => xs:dateTime() descending
                return <launch id="{$launch?id}">
                    <name>{$launch?name}</name>
                    <date>{$launch?date_utc => xs:dateTime()}</date>
                    {
                        if ($launch?details => fn:exists())
                        then <description>{$launch?details}</description>
                        else ()
                    }
                    <failures total="{$launch?failures => array:size()}" had-crew="{$launch?crew => array:size() gt 0}">
                        {
                            for $failure in $launch?failures?*
                            order by $failure?time descending
                            return <failure at="{$failure?time}">{$failure?reason}</failure>
                        }
                    </failures>
                    <links>
                        {
                            if (fn:exists($launch?links?youtube_id))
                            then <video href="{"https://youtube.com/watch?v=" || $launch?links?youtube_id }" />
                            else ()
                        }
                        {
                            if (fn:exists($launch?links?article))
                            then <article href="{$launch?links?article}" />
                            else ()
                        }
                        <json href="{$baseUrl || "/launches/" || $launch?id}" />
                    </links>
                </launch>
            }
        </launches>
    }
}

