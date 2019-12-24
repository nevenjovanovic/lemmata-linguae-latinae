let $parent := replace(file:parent(static-base-uri()), '/scripts/xq/', '') 
let $path := $parent || "/csv/lemlat/lemmario.csv" 
let $csv := csv:parse(file:read-text($path), map { 'header': true(), 'separator': 'comma' })
return db:create("lll-lemlat", $csv, "lemmario.xml")
(: return $csv :)