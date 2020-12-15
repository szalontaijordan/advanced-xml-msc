(:
 : 7. A legénységgel rendelkező kilövések HTML oldala
 :)
xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:html-version "5.0";
declare option output:indent "yes";

declare function local:create-launch($launch as item()*, $crew as item()*) as element(div) {
    let $launchCrew := $crew[?id = $launch?crew]
    let $outcomeClassName := "outcome " || (if ($launch?success) then "success" else "failure")

    return
      <div id="launch-{$launch?id}">
          <div class="details">
              <div class="title">
                <h1>{$launch?name}</h1>
                <span class="date">{xs:dateTime($launch?date_utc) => fn:format-dateTime("[Y0001]. [M01]. [D01].")}</span>
              </div> 
              <img src="{$launch?links?patch?small}" alt="patch" />
              <img class="img-shadow" src="{$launch?links?patch?small}" alt="patch" />
              <p>{$launch?details}</p>
              <span class="{$outcomeClassName}" />
          </div>
          <div data-total="{fn:count($launchCrew)}" class="crew">
              {
                  for $person in $launchCrew
                  let $statusClassName := "status " || $person?status
                  return
                      <div class="person">
                          <a target="_blank" rel="noopener noreferrer" href="{$person?wikipedia}">
                              <span class="name">{$person?name} - {$person?agency}</span>
                              <span class="{$statusClassName}" />
                              <img src="{$person?image}" alt="{$person?name}" />
                          </a>
                      </div>
              }
          </div>
          <div class="placeholders">
              {
                for $placeholder in (0, 1)
                return
                    <div class="placeholder">?</div>
              }
          </div>
      </div>
};

declare function local:filter-launches($launches as item()*) as item()* {
    $launches[array:size(?crew) gt 0]
};

let $baseUrl := "https://api.spacexdata.com/v4"
let $crew :=  fn:json-doc($baseUrl || "/crew")?*
let $launches := fn:json-doc($baseUrl || "/launches")?*

return document {
    <html>
        <head>
            <title>SpaceX Crew</title>
            <link rel="stylesheet" href="./crew.css" />
            <link rel="preconnect" href="https://fonts.gstatic.com" />
            <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300&amp;display=swap" rel="stylesheet" />
        </head>
        <body>
            { comment { "Data is from the SpaceX API https://github.com/r-spacex/SpaceX-API/blob/master/docs/v4/README.md " } }
            <div class="main-title">
                <img src="./logo.png" alt="SpaceX" />
            </div>
            <ul class="launches">
            {
                for $launch in $launches => local:filter-launches()
                order by $launch?date_utc descending
                return
                    <li class="launch">{$launch => local:create-launch($crew)}</li>
            }
            </ul>
        </body>
    </html>
}





