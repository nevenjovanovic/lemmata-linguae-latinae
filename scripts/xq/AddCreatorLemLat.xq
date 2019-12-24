(: add concept URI for the Università Cattolica del Sacro Cuore to lemlat entries :)
let $db := "lll-lemlat"
for $r in collection($db)//record
return insert node element creator { "http://www.wikidata.org/entity/Q229022" } into $r
