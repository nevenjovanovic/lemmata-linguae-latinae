module namespace cite = "http://croala.ffzg.unizg.hr/cite";
import module namespace functx = "http://www.functx.com" at "functx.xqm";
import module namespace cp = 'http://croala.ffzg.unizg.hr/croalapelagios' at "croalapelagios2.xqm";
declare namespace ti = "http://chs.harvard.edu/xmlns/cts";

(: helper function for header, with meta :)
declare function cite:htmlheadtsorter($title, $content, $keywords) {
  (: return html template to be filled with title :)
  (: title should be declared as variable in xq :)

<head><title> { $title } </title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<meta name="keywords" content="{ $keywords }"/>
<meta name="description" content="{$content}"/>
<meta name="revised" content="{ current-date()}"/>
<meta name="author" content="Neven Jovanović, CroALa" />
<link rel="icon" href="/basex/static/gfx/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="/basex/static/dist/css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="/basex/static/dist/css/basexc.css"/>
</head>

};


declare function cite:validate-cts($cts){
  let $result :=
    if (matches($cts, "urn:cts:croala:[a-z0-9.\-]+:[a-z0-9.\-]+$")) then true()
    else if  (matches($cts, "urn:cts:croala:[a-z0-9.\-]+$")) then true()
    else false()
  return $result
};

declare function cite:validate-cite($cite){
  let $result :=
    if (matches($cite, "urn:cite:croala:[a-z0-9.]+[0-9]+$")) then true()
    else if  (matches($cite, "^[A-Z][a-z]+$")) then true()
    else false()
  return $result
};

declare function cite:urn-exists($urn){
    
  if (starts-with($urn, "urn:cts:croala:")) then 
     if (collection("cp-cts-urns")//w[@n=$urn]) then collection("cp-cts-urns")//w[@n=$urn]/@xml:id/string()
     else "URN deest in collectionibus nostris."
     
  else if (starts-with($urn, "urn:cite:croala:loci")) then 
    if (collection("cp-cite-urns")//w[@citeurn=$urn]) then collection("cp-cite-urns")//w[@citeurn=$urn]
    else "URN deest in collectionibus nostris."
    
  else if (matches($urn, "^[A-Z]")) then 
    if (collection("cp-loci")//w[label=$urn]) then collection("cp-loci")//w[label=$urn]/citebody/string()
    else  "URN deest in collectionibus nostris."
    
  else if (starts-with($urn, "urn:cite:croala:latlexent.") or starts-with($urn, "urn:cite:perseus:latlexent.")) then
    if (collection("cp-latlexents")//record[entry[1]=$urn]) then collection("cp-latlexents")//record[entry[1]=$urn]/entry[2]
    else "URN deest in collectionibus nostris."
  else if ($urn=()) then "URN deest in collectionibus nostris."
  else "URN deest in collectionibus nostris."
};

declare function cite:geturn($urn) {
  element table {
    element thead {
      element tr {
        element td { "URN"},
        element td { "Name"}
      }
    },
    element tbody {
let $dbs := (collection("cp-latlexents"), collection("cp-latmorph"))
for $r in $dbs//record
let $name := ("morphcode", "lemma")
let $name2 := ("lemma", "label")
let $id := generate-id($r)
where $r/*[name()=$name and @citeurn=$urn]
return element tr {
  element td { cite:input-field($id, $r) },
  element td { $r/*[name()=$name2]/string() }
}
}
}
};

declare function cite:queryname ($q) {
  let $dbs := collection("cp-latlexents")
  let $list := $dbs//record
  let $result := $list[lemma[matches(string(), '^' || upper-case($q) )]]
  return if ($result) then
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    element thead {
      element tr {
        element th { "URN"},
        element th { "Verbum"}
      }
    },
    element tbody {

for $r in $result
let $id := generate-id($r)
return element tr {
  element td { 
    cite:input-field($id, $r)
    },
  element td { $r/lemma/string() }
}
}
}
else element table { cp:deest() }
};

declare function cite:queryname2 ($urn) {
  let $dbs := collection("lll-lemlat")
  let $list := $dbs//record[urn=$urn]
  return if ($list) then
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    element thead {
      element tr {
        element th { "URN"},
        element th { "Descriptio"}
      }
    },
    element tbody {
 element tr {
  element td { 
    element tr {
  element td { 
    element span { $urn }
    },
  element td { 
  for $l in $list/*
  return element span {  
  attribute class {"urn-row"} , $l }
   }
}
}}
}
}
else element table { cp:deest() }
};

declare function cite:input-field($id, $r){
  element input { 
      attribute size { "45"},
      attribute id { $id },
      attribute value { $r/*[name()=("lemma", "morphcode")]/@citeurn/string() } } , 
    element button { 
      attribute class { "btn" } ,
      attribute aria-label { "Recordare!"},
      attribute data-clipboard-target { "#" || $id },
      element span { 
        attribute class { "glyphicon glyphicon-copy"},
        attribute aria-hidden {"true"},
        attribute aria-label { "Recordare!" }
      }
    }
};

declare function cite:getlemmata(){
for $r in collection("cp-cite-lemmata")//list
return $r
};

declare function cite:listlemmata($records){
  element tbody {
for $r in $records//record
  let $cts := data($r/seg/@cts)
  let $citeurn := cp:prettycitebody($cts , $cts, "ctsp/")
  let $word := data($r/seg)
  let $lemma := data($r/lemma)
  let $lemmaurn := cp:prettycitebody(data($r/lemma/@citeurn), data($r/lemma/@citeurn) , "cite/")
  let $annotator := data($r/creator)
  let $annotatorlink := cp:prettylink($annotator, replace($annotator, "http://", ""), "")
  let $datecreated := data($r/datecreated)
  order by $lemma
  return
    element tr {
      $citeurn,
      element td { $word },
      element td { $lemma },
      $lemmaurn ,
      $annotatorlink ,
      element td { $datecreated }
    }
  }
};

declare function cite:getmorphanno() {
  element csv {
  let $c := collection("cp-cite-morphs")
  for $r in $c//record
  return $r
}
};

declare function cite:getmorphtable($csv) {
  element tbody {
    for $r in $csv//record
    let $cts := data($r/entry[1])
    let $citeurn := cp:prettycitebody(data($r/entry[3]) , $cts, "ctsp/")
    let $word := data($r/entry[2])
    let $citemorph := data($r/entry[5])
    let $desc := cp:prettycitebody(data($r/entry[4]), $citemorph , "cite/")
    where not($desc="")
    order by $desc , $word
    return
    element tr {
        $citeurn,
      element td {
        $word
      },
        $desc
    }
  }
};