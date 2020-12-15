(:
 : 1. Az aktív állomások és a hozzájuk tartozó kilövések
 :)
xquery version "3.1";

import schema default element namespace "" at "active-launchpads.xsd";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "xml";
declare option output:indent "yes";

declare function local:create-launchpad($pad as map(xs:string, item()*), $launches as item()*) as element(launchpad) {
    let $failures := $pad?launch_attempts - $pad?launch_successes

    return
        <launchpad id="{$pad?id}" status="{$pad?status}">
          <name>{$pad?full_name}</name>
          <coors>{$pad?latitude},{$pad?longitude}</coors>
          <attempts>{$pad?launch_attempts}</attempts>
          <failures>{$failures}</failures>
          <launches>
              {
                  for $launch in $launches
                  order by $launch?date_utc descending
                  return
                      if ($launch?launchpad eq $pad?id)
                      then $launch => local:create-launch()
                      else ()
              }
          </launches>
        </launchpad>
};

declare function local:create-launch($launch as map(xs:string, item()*)) as element(launch) {
    <launch id="{$launch?id}" upcoming="{$launch?upcoming}">
        <name>{$launch?name}</name>
        <date>{$launch?date_utc => xs:dateTime()}</date>
        <outcome>{$launch => local:get-launch-outcome()}</outcome>
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

declare function local:get-launch-outcome($launch as map(xs:string, item()*)) as xs:string {
    if ($launch?upcoming)
    then "TBD"
    else if ($launch?success)
        then "success"
        else "failure"
};

let $baseUrl := "https://api.spacexdata.com/v4"

let $launches := fn:json-doc($baseUrl || "/launches")?*
let $launchpads := fn:json-doc($baseUrl || "/launchpads")?*
let $status := "active"

let $activePads := $launchpads[?status eq $status]

return validate {
    document {
        comment { "Data is from the SpaceX API https://github.com/r-spacex/SpaceX-API/blob/master/docs/v4/README.md | " || fn:current-dateTime() },
        <launchpads total="{$activePads => fn:count()}">
            {
                for $pad in $activePads
                order by $pad?launch_attempts descending
                return $pad => local:create-launchpad($launches)
            }
        </launchpads>
    }
}






