(: XQuery module for CroALa-Pelagios :)
module namespace cp = 'http://croala.ffzg.unizg.hr/croalapelagios';
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $cp:editions := ("urn:cts:croala:bunic02.croala1761880.croala-lat2w", 
"urn:cts:croala:crije02.croala292491.croala-lat2w", 
"urn:cts:croala:marul01.croala754085.croala-lat2w",
"urn:cts:croala:nikolamodr01.croala1394919.croala-lat2loci",
"urn:cts:croala:crije01.croala789994.croala-lat2w");

declare variable $cp:cite_namespace := "http://croala.ffzg.unizg.hr/basex/cite/";

declare variable $cp:ann := map {
  "ZS" : "http://orcid.org/0000-0003-1457-7081",
  "NJ" : "http://orcid.org/0000-0002-9119-399X",
  "AS" : "http://orcid.org/0000-0001-5515-6545",
  "NČ" : "http://orcid.org/0000-0002-0438-6049",
  "NJ/NČ" : "http://orcid.org/0000-0002-0438-6049",
  "AS/NČ" : "http://orcid.org/0000-0002-0438-6049",
  "CROALA/NČ" : "http://orcid.org/0000-0002-0438-6049",
  "AŽ" : "http://orcid.org/0000-0002-2135-6343"
};

declare variable $cp:estlocus_info := map {
  "estlocus0" : "This is not a reference to a named place.",
  "estlocus1" : "This is a clear and unambiguous reference to a named place.",
  "estlocus2" : "This is a part of a multi-word expression referring to a named place.",
  "estlocus3" : "This is not a place name, but it is used rhetorically to refer to a named place.",
  "estlocus4" : "This is a complex use which should be investigated further.",
  "estlocusX" : "This is a potential place reference, it has not yet been analysed."
};

(: helper function - message  :)
declare function cp:deest(){
  element tr {
    element td { "URN deest in collectionibus nostris." }
  }
};

(: helper function - calculate percentage :)
declare function cp:percent($a , $b){
  round ($a div $b * 100)
};

(: helper function for table :)
declare function cp:table ($headings, $body){
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    if ($headings="") then ()
    else
    element thead {
      element tr {
        for $h in $headings return element th { $h }
      }
    },
    element tbody {
      $body
    }
  }
};

(: helper function for header, with meta :)
declare function cp:htmlheadserver($title, $content, $keywords) {
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
<link rel="stylesheet" type="text/css" href="/basex/static/dist/css/cp3.css"/>
<link rel="stylesheet" type="text/css" href="/basex/static/dist/font-awesome-4.7.0/css/font-awesome.min.css"/>
</head>

};

(: helper function - footer :)
declare function cp:footerserver () {
let $f := <footer class="footer">
<div class="container">
<h1 class="text-center"><span class="glyphicon glyphicon-leaf" aria-hidden="true"></span> <a href="http://croala.ffzg.unizg.hr">CroALa</a></h1>
<div class="row"> 
<div  class="col-md-6">
<h3 class="text-center"><a href="http://www.ffzg.unizg.hr"><img src="/basex/static/gfx/ffzghrlogo.png"/> Filozofski fakultet</a> Sveučilišta u Zagrebu</h3> 
<p class="text-center"><i class="fa fa-github fa-lg fa-fw"></i>
            <span class="network-name">Github</span>: <a href="https://github.com/nevenjovanovic/lemmata-linguae-latinae">/lemmata-linguae-latinae</a></p>
</div>

<div  class="col-md-6">
<p class="text-center"></p></div></div>
</div>
</footer>
return $f
};

declare function cp:makeelement($e, $name){
  element {$name} { data($e) }
};

declare function cp:annotator ($parsed) { 
  cp:makeelement(
  map:get($cp:ann, upper-case($parsed/ANNOTATOR_INITIALS)), "creator"
)
};

declare function cp:input-field2($id, $r){
  element input { 
      attribute size { "15"},
      attribute id { $id },
      attribute value { $r } } , 
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

(: pretty printing of text :)
declare function cp:prettyp($settext, $ctsadr, $word) {
  element tr {
    element td { cp:metadata(
      functx:substring-before-last($ctsadr, ":")) },
    element td { $word },
    element td {
  replace(replace($settext, ' ([,).:;?!])', '$1'), '([(]) ', '$1')
}
}
};
(: pretty printing of CTS URN list with link :)
declare function cp:prettycts($citeadr , $ctsadr, $word) {
  element tr {
    element td {
      $citeadr
    },
    element td { 
    element a { 
    attribute href { "http://croala.ffzg.unizg.hr/basex/ctsp/" || $ctsadr } , 
    $ctsadr } },
    element td { $word }
}
};

declare function cp:simple_link($link, $word){
  element a {
    attribute href { $link },
    $word
  }
};

declare function cp:prettylink($link, $word, $prefix) {
    element td { 
    element a { 
    attribute href { $prefix || $link } , 
    $word } }
};

(: helper function - list of all documents with place annotations :)

declare function cp:list_corpus($cts_set){
  let $doc_urns := distinct-values(
  for $cts in $cts_set
  let $base := functx:substring-before-last($cts, ":")
  return $base )
  return ("corpus" , $doc_urns )
};

(: list all CTS URNs :)
declare function cp:listurn () {
  for $address in db:open("cp-placename-idx")//*:w
  let $citeadr := "urn:cite:croala:loci.estlocus" || data($address/@xml:id)
let $ctsadr := data($address/@n)
let $word := $address/text()
order by $word
return cp:prettycts($citeadr , $ctsadr, $word)
};

(: from a CTS URN retrieve text in s parent element :)
declare function cp:openurn ($ctsadr) {
let $w := db:open("cp-cts-urns")//*:w[@n=$ctsadr]
return if ($w) then
let $pre := $w/@xml:id
let $citeurn := if (db:exists("cp-cite-loci") and collection("cp-cite-loci")//record[ctsurn=$ctsadr]) then $cp:cite_namespace || collection("cp-cite-loci")//record[ctsurn=$ctsadr]/citeurn/string()
else $cp:cite_namespace || "ZZZZZZ"
let $word := cp:simple_link($citeurn , $w/text())
let $text := if (db:exists("cp-cite-urns") and db:open("cp-cite-urns")//w[@n=$ctsadr]) then data(db:open("cp-cite-urns")//w[@n=$ctsadr]/context) else normalize-space(data(db:open-id("cp-2-texts", $pre)/parent::*))
return cp:prettyp($text, $ctsadr, $word)
else cp:deest()
};

(: make node quickly :)
declare function cp:td($node) {
  element td {
    data($node)
  }
};
(: pretty printing of a URN list :)
(: send to /$domain/$urn, where the CITE body or CTS is displayed :)
declare function cp:prettycitebody($citeurn , $cts, $domain) {
  element td {
    element a { 
    attribute href { "http://croala.ffzg.unizg.hr/basex/" || $domain || $cts } , 
    data($citeurn) }
  }
};
(: list CITE URNs linking to their bodies, and their CTS equivalents :)
declare function cp:citelist(){
let $citedb := collection("cp-cts-cite-idx")
let $citelistbody := element tbody { for $r in $citedb//record
let $ctsurn := cp:prettycitebody($r/entry[4], "ctsp/", $r/entry[4])
let $citeurn := cp:prettycitebody($r/entry[5], "cite/", $r/entry[5])
let $label := cp:td($r/entry[2])
let $citeanaex := element td { "CITE Analytical exemplar" }
return element tr {
  $label , $citeurn , $ctsurn
}
}
return $citelistbody
};

declare function cp:listcitebodies(){
  (: for a given CITE URN, display record :)
(: to be made into cp:openciteurn function :)
(: relies on the cp-citebody db :)
let $citeurn := element div {
  attribute class {"table-responsive"},
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    element thead {
      element tr {
        element td { "CITE Body URN"},
        element td { "Place Reference"},
        element td { "Place Referred To"},
        element td {"Period Referred To"},
        element td { "Note Created By"},
        element td { "File Last Modified On"}
      }
    },
    element tbody {
let $idx := collection("cp-citebody")
for $r in $idx//r
let $citebodyurn := $r/note/entry
let $placeref := for $e in $r/place/entry return element a { attribute href {$e}, for $txt in tokenize($e, '/')[last()] return $txt }
let $placereflabel := data($r/label/entry)
let $periodref := for $p in $r/period/entry return element a { attribute href {$p} , $r/periodlabel/entry }
let $creator := $r/creator/entry
order by $placereflabel
return 
    element tr { 
  element td { data($citebodyurn)},
  element td { $placeref },
  element td { $placereflabel } ,
  element td { $periodref },
  element td { element a { attribute href {$creator}, replace($creator, 'https?://orcid.org/' , '')} },
  element td { file:last-modified("/home/croala/croala-pelagios/csv/modrtub-idx-citebodies.xml") }
}
}}
}
return $citeurn
};

declare function cp:listciteplaces($lemma){
  (: display all available CITE URNs for places :)
(: relies on the cp-loci db :)
let $citeurn := element div {
  attribute class {"table-responsive"},
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    element thead {
      element tr {
        element td { "CITE Body URN"},
        element td { "CITE ID Part"},
        element td { "Latin Lemma"},
        element td { "Place Referred To"},
        element td { "URI"}
      }
    },
    element tbody {
     
let $idx := collection("cp-loci")//record[matches(nomen/text(), $lemma)]
return if ($idx) then
for $r in $idx
let $lemma := element td { data($r/nomen) }
let $citeid := replace($r/@citeid/string(), "locid", "")
let $citevalue := element td { $r/citebody/@citeurn/string() }
let $id := generate-id($r)
let $citebodyurn := element td { cp:input-field2($id, $citeid) }
let $placeref := element td { 
element a {
  attribute href { data($r/uri) } , replace(data($r/uri), "http://", "") } }
let $placereflabel := element td { data($r/label) }
order by $lemma
return 
    element tr { 
    $citevalue ,
    $citebodyurn ,
    $lemma ,
    $placereflabel ,
    $placeref
}

else cp:deest()
}}
}
return $citeurn
};

declare function cp:listciteperiods(){
  (: display all available CITE URNs for periods :)
(: relies on the cp-aetates db :)
let $citeurn := element div {
  attribute class {"table-responsive"},
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    element caption {
      attribute class { "heading"},
      "Periods recorded: " ,
      let $r := collection("cp-aetates")//record
      return count($r)
    },
    element thead {
      element tr {
        element th { 
        attribute class { "col-md-2" } , 
        "CITE URN Short Id" },
        element th { "CITE URN"},
        element th { "Period Description"},
        element th { "Period URN"}
      }
    },
    element tbody {
let $idx := collection("cp-aetates")
for $r in $idx//record
let $citebodyurn := replace(data($r/@xml:id), "aetas", "")
let $id := generate-id($r)
let $citebodyurn2 := element td { cp:input-field2($id, $citebodyurn) }
let $cite_urn := data($r/citebody/@citeurn)
let $placeref := data($r/uri)
let $placereflabel := data($r/label)
order by $placereflabel
return 
    element tr { 
   $citebodyurn2 ,
   element td { 
  attribute class { "cts_cite"},
  cp:simple_link($cp:cite_namespace || $cite_urn , $cite_urn ) },
  element td { $placereflabel } ,
  element td { element a { attribute href {$placeref}, replace($placeref, 'https?://' , '')} }
}
}}
}
return $citeurn
};

declare function cp:estlocus_grand_tot($set) {
  let $all_estlocus := $set//*[matches(@ana,"^estlocus")]
  return element tr { 
  attribute class { "success"},
  element td { "ALL VALUES"},
  element td { count($all_estlocus) }
}
};

declare function cp:estlocus_tot($set, $urn) {
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    attribute id { "estlocus" },
    element caption {
      element b { "Codes" } , ": 0 = not a place; 1 = definitely a place; 2 = part of a multi-word expression denoting place; 3 = rhetorical (figurative) reference; 4 = a complex case; X = requires further work."
    },
    element thead {
      element tr {
        element th { "ESTLOCUS"},
        element th { "TOTAL IN CORPUS"}
      }
      
    },
    element tbody {
      cp:estlocus_grand_tot($set),
      for $count in $set//*[matches(@ana,"^estlocus")]
      let $estlocus := $count/@ana
      group by $estlocus
      order by $estlocus
      return element tr {
        element td { replace($estlocus, "estlocus", "est locus ") },
        cp:prettylink($estlocus, count($count), "http://croala.ffzg.unizg.hr/basex/cp-loci/" || $urn || "/")
      }
    }
  }
};

declare function cp:estlocus_xml_totals(){
  for $doc in db:open("cp-2-texts")//*:TEI[descendant::*:w[matches(@ana,"estlocus")]]
  let $urn := $doc//*:text/@xml:base/string()
  let $path := db:path($doc)
  return element div {
    attribute class {"table-responsive"},
  element h1 { $urn } , 
  cp:estlocus_tot(db:open("cp-2-texts", $path), $urn)
}
};

declare function cp:estlocus_index($cts_urn, $value){
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    attribute id { $value },
    element caption { $cts_urn } ,
  element thead {
    element tr {
      element th { "CITE URN"} ,
      element th { "CTS URN"},
      element th { "Word"}
    }
  },
  element tbody {
    let $set := if ($cts_urn="corpus") then db:open("cp-cts-urns")//*:w[@ana=$value]
    else if (starts-with($cts_urn, "urn:cts:croala")) then db:open("cp-cts-urns")//*:w[starts-with(@n, $cts_urn) and @ana=$value]
    else element b { "URN deest in collectionibus nostris." }
  for $w in $set
  let $word := if ($w/string()) then $w/string() else ()
  let $cts_urn_seg := if ($w/@n) then $w/@n/string() else ()
  let $cite_urn_seg := if ($w/@n) then db:open("cp-cite-urns")//w[@n=$w/@n/string()]/@locusurn/string() else "ZZZZZ"
  let $cite_urn_seg_link := cp:simple_link($cp:cite_namespace || $cite_urn_seg, $cite_urn_seg)
  return if ($cts_urn_seg) then
  cp:prettycts($cite_urn_seg_link , $cts_urn_seg, $word)
  else element tr {
    element td { $word }
  }
}
}
};

declare function cp:group_lemmata($set){
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    attribute id { "lemmata" },
    element caption { $set } ,
  element thead {
    element tr {
      element th { "Lemma"},
      element th { "Occurrences"}
    }
  },
  element tbody {
    let $result_set := if ($set="corpus") then db:open("cp-cite-lemmata")//*:record
    else if (starts-with($set, "urn:cts:croala")) then db:open("cp-cite-lemmata")//*:record[starts-with(seg/@cts, $set)]
    else element b { "CITE URN deest in collectionibus nostris." }
  return if ($result_set/lemma) then
  for $r in $result_set  
  let $lemma := $r/lemma
  let $lemma_cite := $r/lemma/@citeurn/string()
  group by $lemma
  order by $lemma
  return element tr {
    cp:prettylink(distinct-values($lemma_cite), $lemma, $cp:cite_namespace),
    cp:prettylink($set || "/" || distinct-values($lemma_cite), count($r), "http://croala.ffzg.unizg.hr/basex/cpciteindex/")}
  else element tr{
    element td { $result_set }
  }
}
}
};

(: return counts of lemmata and lemmatized words :)

declare function cp:count_lemma_all($cts){
  let $set := if ($cts="corpus") then db:open("cp-cite-lemmata")//record[lemma] else if (starts-with($cts, "urn:cts:croala:")) then db:open("cp-cite-lemmata")//record[lemma and starts-with(seg/@cts, $cts)] else element b { "CTS URN abest in collectionibus nostris" }
let $r := $set
let $lemmatized_count := count($r)
let $lemma_count := count(distinct-values($r/lemma/@citeurn))
return element tr {
  cp:prettylink($cts, $cts, "http://croala.ffzg.unizg.hr/basex/cp-cite-lemmata/" ),
  element td { if ($lemma_count=0) then $r else $lemma_count },
  element td { if ($lemma_count=0) then "" else $lemmatized_count },
  element td { if ($lemma_count=0) then "" else format-number($lemmatized_count div $lemma_count, ".00") }
}
};

(: display counts of lemmata for corpus and all docs :)

declare function cp:count-lemmata(){
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    attribute id { "lemmata" },
    element caption { "Counts of lemmata in the whole corpus and in individual documents." } ,
  element thead {
    element th { "Document"},
    element th { "Lemmata"},
    element th { "Lemmatized words"},
    element th { "Average frequency of lemmata"}
  },
  element tbody {
  
for $d in cp:list_corpus(db:open("cp-cite-lemmata")//record/seg/@cts)
return cp:count_lemma_all($d)
}
}
};

declare function cp:index_lemmata($cts, $cite_urn){
  element h3 { $cts || ": " || db:open("cp-latlexents")//record/lemma[@citeurn=$cite_urn]/string() },
  element table {
    attribute class {"table-striped  table-hover table-centered"},
    attribute id { "list_occurrences" },
    element caption { $cite_urn || ": " || db:open("cp-latlexents")//record/lemma[@citeurn=$cite_urn]/string() } ,
  element thead {
    element tr {
      element th { "Occurrence" },
      element th { "CTS URN"}
    }
  },
  element tbody {
  for $r in db:open("cp-cite-lemmata")//record[starts-with(seg/@cts,$cts) and lemma/@citeurn=$cite_urn]
  return element tr {
    element td { $r/seg/string()},
    cp:prettylink( $r/seg/@cts/string(), $r/seg/@cts/string(), "http://croala.ffzg.unizg.hr/basex/ctsp/" )
  }
}
}
};

(: return count of places identified in corpus and in each document :)
declare function cp:count_places($corpus) {
  let $count_places := if ($corpus="corpus") then db:open("cp-cite-loci")//record/citelocus 
  else if (starts-with($corpus, "urn:cts:croala")) then db:open("cp-cite-loci")//record[starts-with(ctsurn, $corpus)]/citelocus 
  else element b { "CTS URN abest in collectionibus nostris."}
  let $total := count($count_places)
  let $distinct := count(distinct-values($count_places))
  return if ($total <= 1) then 
  element table {
  element tbody {
    element tr { 
    element td { $count_places }
  }
} }
 else 
 element table {
    attribute class {"table-striped  table-hover table-centered"},
  element thead {
    element tr {
      element th { 
      attribute class { "col-md-8" },
      $corpus },
      element th { 
      attribute class { "col-md-4" },
      "Current count"}
    }
  },
  element tbody {
  element tr {
    element td { "Identified places" },
    cp:prettylink( $corpus, $distinct, "http://croala.ffzg.unizg.hr/basex/cp-loci-id/" )
  },
  element tr {
    element td { "Mentions of places" },
    element td { $total }
  }
} }
};

declare function cp:report_count_places(){
  element div { 
  attribute class { "table-responsive" } ,
  element h2 { "Commented place names in texts"},
  element table {
    attribute class { "table-striped  table-hover table-centered" },
    element tbody {
  for $d in cp:list_corpus(db:open("cp-cite-loci")//record/ctsurn)
  return element tr {
    element td {
  element div { 
  attribute class { "table-responsive" } ,
  cp:count_places($d)
}
}
}
}
}
}
};

declare function cp:loci-id-index($cts){
  let $list_places := if ($cts="corpus") then db:open("cp-cite-loci")//record/citelocus 
  else if (starts-with($cts, "urn:cts:croala")) then db:open("cp-cite-loci")//record[starts-with(ctsurn, $cts)]/citelocus 
  else element b { "CTS URN abest in collectionibus nostris."}
  for $place in distinct-values($list_places)
  let $place_record := db:open("cp-loci")//record[citebody/@citeurn=$place]
  let $place_label := $place_record/label
  let $place_uri := $place_record/uri
  let $occurrences := if ($cts="corpus") then db:open("cp-cite-loci")//record[citelocus=$place] else if (starts-with($cts, "urn:cts:croala:")) then db:open("cp-cite-loci")//record[citelocus=$place and starts-with(ctsurn, $cts)] else ()
  let $count_occurrences := count($occurrences)
  let $list_cts := $occurrences/ctsurn
  order by $place_label
  return if (count($list_places) <= 1) then 
    element tr { 
    element td { $place }
  }
 else 
 
    element tr {
      element td { if ($place_label) then cp:simple_link($place_uri , $place_label/string()) else "NOMEN LOCI DEEST" },
      element td { cp:simple_link($cp:cite_namespace || $place , $place) }, 
  element td { $count_occurrences },
  element td { for $c in $list_cts return cp:simple_link("http://croala.ffzg.unizg.hr/basex/ctsp/" || $c , functx:substring-after-last($c, ":")) }
}
};

(: all annotations connected with a CTS URN :)
(: the CTS URN becomes its own CITE :)
declare function cp:openciteurn_ana($urn) {
  let $tbody :=
  if (starts-with($urn, "urn:cite:croala:loci.ana")) then
  let $collections := ("cp-cite-loci", "cp-cite-aetates", "cp-cite-lemmata", "cp-cite-morphs")
  let $cite_set := for $c in $collections return collection($c)//record[citeurn=$urn or seg/@citeurn=$urn]
  
  let $cts_urn := (
    distinct-values($cite_set//ctsurn) ,
    distinct-values($cite_set//seg/@cts) )
  let $word_form := distinct-values($cite_set//seg)
  let $estlocus := db:open("cp-cts-urns")//w[@n=$cts_urn]
  let $estlocus_value := distinct-values($estlocus/@ana/string())
  let $cite_set_all := ($cite_set , $estlocus )
  let $cite_set_count := count($cite_set_all)
  let $tbody2 := (
    cp:simple_link ( "http://croala.ffzg.unizg.hr/basex/cp-loci/corpus/" || $cite_set_all/@ana/string() , $cite_set_all/@ana/string()) , 
    cp:simple_link( $cp:cite_namespace || $cite_set_all/lemma/@citeurn , data($cite_set_all/lemma))  , 
    cp:simple_link( $cp:cite_namespace || $cite_set_all/morph/@citeurn , data($cite_set_all/morph) ) , 
    for $c in $cite_set_all/citelocus return 
    cp:simple_link( $cp:cite_namespace || data($c) , collection("cp-loci")//record[citebody/@citeurn=$c]/label/string() ) ,
    for $a in $cite_set_all/citeaetas return 
    cp:simple_link( $cp:cite_namespace || data($a) , data(collection("cp-aetates")//record[citebody/@citeurn=$a]/label) )
  )
  
  return element tr {
    element td { $urn },
    element td { 
    attribute class { "cts"},
    for $u in distinct-values($cts_urn) return cp:simple_link("http://croala.ffzg.unizg.hr/basex/ctsp/" || $u , $u )  },
    element td { $word_form },
    element td { $cite_set_count },
    element td { 
    cp:table ("",
    for $t in $tbody2
    return element tr {
      attribute class { "table-success" },
      element td { $t }
    } ) }
  }
  else cp:deest()
  
  let $thead := ("CITE URN", "CTS URN", "Word form", "Number of annotations", "Annotations")
  return cp:table($thead, $tbody)
};

(: open a CITE URN for a place, display CITE body "content" :)
declare function cp:openciteurn_locid($citeurn){
  (: for a given CITE URN, display record :)
  let $tbody :=
   if (starts-with($citeurn, "urn:cite:croala:loci.locid")) then
let $idx := collection("cp-loci")
for $r in $idx//record[citebody[@citeurn=$citeurn]]
let $nomen := $r/nomen
let $label := $r/label
let $uri := $r/uri
let $loci_set := db:open("cp-cite-loci")//record[citelocus=$citeurn]
let $loci_set_count := count($loci_set)
let $creator := $r/creator
let $datecreated := $r/datecreated

return element tr { 
  element td { $citeurn },
  element td { data($nomen) },
  cp:prettylink("", data($label), $uri) ,
  cp:prettylink($citeurn, $loci_set_count, "http://croala.ffzg.unizg.hr/basex/cp-loci-cite/"),
  element td { element a { attribute href {$creator}, replace($creator, 'https?://orcid.org/' , '')} },
  element td { data($datecreated) }
}

else cp:deest()
let $thead := ("CITE URN", "Place Name (Latin)", "Place Name (Standard)" , "Annotations in corpus" , "Note Created By", "Creation Date")
return cp:table ( $thead , $tbody)

};

declare function cp:opencite_morph($urn) {
  let $tbody :=
  if (starts-with($urn, "urn:cite:croala:latmorph.morph")) then
  for $r in collection("cp-latmorph")//record[morphcode/@citeurn=$urn]
  let $morph_set := db:open("cp-cite-morphs")//record[morph/@citeurn=$urn]
  let $morph_set_count := count($morph_set)
  return 
  element tr {
    element td { $urn },
    element td { data($r/morphcode) },
    element td { data($r/label)},
    cp:prettylink($urn , $morph_set_count, "http://croala.ffzg.unizg.hr/basex/cp-morph-cite/" )
  }
  else cp:deest()
  let $thead := ("CITE URN", "Morphology code", "Morphology configuration" , "Annotations in corpus")
  return cp:table ( $thead , $tbody)
};

declare function cp:opencite_latlexent($urn){
  let $tbody :=
  if (starts-with($urn, "urn:cite:croala:latlexent.lex")) then
  for $r in collection("cp-latlexents")//record[lemma/@citeurn=$urn]
  let $lemma_set := db:open("cp-cite-lemmata")//record[lemma/@citeurn=$urn]
  let $lemma_set_count := count($lemma_set)
  return 
  element tr {
    element td { $urn },
    element td { data($r/lemma) },
    cp:prettylink($urn , $lemma_set_count, "http://croala.ffzg.unizg.hr/basex/cp-lemma-cite/" ),
    cp:prettylink("", replace(data($r/creator), "https?://orcid.org/", ""), data($r/creator)),
    element td { data($r/datecreated) }
  }
  else cp:deest()
  let $thead := ("CITE URN", "Lemma", "In annotations" , "Creator", "Date created")
  return cp:table ( $thead , $tbody)
};

declare function cp:opencite_aetas($urn) {
  let $tbody :=
  if (starts-with($urn, "urn:cite:croala:loci.aetas")) then
  for $r in collection("cp-aetates")//record[citebody/@citeurn=$urn]
  let $aetas_uri := $r/uri
  let $aetas_set := db:open("cp-cite-aetates")//record[citeaetas=$urn]
  let $aetas_set_count := count($aetas_set)
  return 
  element tr {
    element td { $urn },
    cp:prettylink("", data($r/label), data($aetas_uri) ),
    element td { data($r/description)},
    cp:prettylink($urn , $aetas_set_count, "http://croala.ffzg.unizg.hr/basex/cp-aetas-cite/" ),
    cp:prettylink("", replace(data($r/creator), "https?://orcid.org/", ""), data($r/creator)),
    element td { data($r/datecreated) }
  }
  else cp:deest()
  let $thead := ("CITE URN", "Period", "Desc" , "In annotations" , "Creator", "Date created")
  return cp:table ( $thead , $tbody)
};

declare function cp:opencite_estlocus($urn) {
  let $id := "ana" || substring-after($urn, "estlocus")
  let $cts := collection("cp-cite-urns")//w[@xml:id=$id]/@n
  let $headings := ("Opus", "Forma", "Contextus")
  let $tbody := cp:openurn($cts)
  return cp:table($headings, $tbody)
};

declare function cp:opencite_aetas_nova($urn) {
  let $aetas := substring-after($urn,"urn:cite:croala:aetates.")
  let $record := collection("cp-aetates")//record[@xml:id=$aetas]
  return if ($record) then 
  cp:table (
    ( $record//label ) ,
  ( 
  element tr { 
  element td { $record//description } } ,
  element tr { 
  element td { "Creator: " , cp:simple_link( $record//creator , replace($record//creator, "https?://", "") ) } } ,
  element tr { 
  element td { "Date created: " || $record//datecreated }  } )
)
  else cp:deest()
};

declare function cp:open_citeurn($urn){
  if (starts-with($urn, "urn:cite:croala:loci.locid" )) then cp:openciteurn_locid($urn)
  else if (starts-with($urn, "urn:cite:croala:loci.ana" )) then cp:openciteurn_ana($urn)
  else if (starts-with($urn, "urn:cite:croala:latmorph"))  then cp:opencite_morph($urn)
  else if (starts-with($urn, "urn:cite:croala:latlexent")) then cp:opencite_latlexent($urn)
  else if (starts-with($urn, "urn:cite:croala:loci.aetas")) then cp:opencite_aetas($urn)
  else if (starts-with($urn, "urn:cite:croala:aetates.aetas")) then cp:opencite_aetas_nova($urn)
  else if (starts-with($urn, "urn:cite:croala:loci.estlocus")) then cp:opencite_estlocus($urn)
  else cp:deest()
};

(: for a CTS, return capitalized lemma as link to the lemma record :)
declare function cp:lemma_link ($cts) {
  let $lemma := db:open("cp-cite-lemmata")//*:record[seg/@cts=$cts]//lemma
  return if ($lemma) then cp:simple_link($cp:cite_namespace || $lemma/@citeurn , upper-case($lemma))
  else cp:deest()
};

(: display all occurrences of a CITE URN locid value :)
(: URL: cp-loci-cite/{$urn} :)

(: 1 - display standard name / with link to source and number of annotated occurrences as table head :)

declare function cp:loci_head($locid_urn){
  let $tbody :=
  if (starts-with($locid_urn, "urn:cite:croala:loci.locid")) then
  for $r in collection("cp-loci")//record[citebody/@citeurn=$locid_urn]
  let $place_label := $r/label
  let $place_uri := $r/uri
  let $count_occur := count(collection("cp-cite-loci")//record[citelocus=$locid_urn])
  return element h3 { "Place: " , cp:simple_link( data($place_uri) , data($place_label) ) , " &#8212; In annotations: " , xs:string($count_occur) }
  else cp:deest()
  return $tbody
};

(: 2 - display list of occurrencees :)
declare function cp:loci_cite($locid_urn){
  let $tbody :=
  if (starts-with($locid_urn, "urn:cite:croala:loci.locid")) then
  for $r in collection("cp-cite-loci")//record[citelocus=$locid_urn]
  let $lemma_record := cp:lemma_link($r/ctsurn)
  let $period_record := collection("cp-cite-aetates")//record[citeurn=$r/citeurn]/citeaetas
  let $period_label := collection("cp-aetates")//record[citebody/@citeurn=$period_record]/label
  return element tr {
    element td { 
    attribute class { "cts_cite"} ,
    cp:simple_link($cp:cite_namespace || data($r/citeurn), data($r/ctsurn)) },
    cp:openurn (data( $r/ctsurn))//td[not(parent::tr[@class]) and position()>1] ,
    element td {
      attribute class { "period"},
      if ($period_label) then cp:simple_link( $cp:cite_namespace || $period_record , data($period_label) ) else ()
    },
    element td { 
    attribute class { "lemma"},
    $lemma_record },
    element td { cp:simple_link(data($r/creator), replace(data($r/creator), "https?://orcid.org/", ""))}
  }
  else cp:deest()
  let $thead := ("CTS URN", "Form", "Context" , "Period" , "Lemma" , "Annotation Creator")
  return cp:table($thead , $tbody)
};

(: title for showing occurrences of period :)
declare function cp:aetas_head($aetas_urn){
  let $tbody :=
  if (starts-with($aetas_urn, "urn:cite:croala:loci.aetas")) then
  for $r in collection("cp-aetates")//record[citebody/@citeurn=$aetas_urn]
  let $aetas_label := $r/label
  let $aetas_uri := $r/uri
  let $count_occur := count(collection("cp-cite-aetates")//record[citeaetas=$aetas_urn])
  return element h3 { "Period: " , cp:simple_link( data($aetas_uri) , data($aetas_label) ) , " &#8212; In annotations:" , xs:string($count_occur) }
  else cp:deest()
  return $tbody
};

(: 2 - display list of annotations :)
declare function cp:aetas_cite($aetas_urn){
  let $tbody :=
  if (starts-with($aetas_urn, "urn:cite:croala:loci.aetas")) then
  for $r in collection("cp-cite-aetates")//record[citeaetas=$aetas_urn]
  let $lemma_record := cp:lemma_link($r/ctsurn)
  let $locus_record := collection("cp-cite-loci")//record[citeurn=$r/citeurn]/citelocus
  let $locus_label := collection("cp-loci")//record[citebody/@citeurn=$locus_record]/label
  return element tr {
    element td { 
    attribute class { "cts_cite"} ,
    cp:simple_link($cp:cite_namespace || data($r/citeurn), data($r/ctsurn)) },
    
    element td { 
    attribute class { "lemma"},
    $lemma_record },
    cp:openurn (data( $r/ctsurn))//td[3] ,
    element td {
      attribute class { "period"},
      if ($locus_label) then cp:simple_link( $cp:cite_namespace || $locus_record , data($locus_label) ) else ()
    },
    
    element td { cp:simple_link(data($r/creator), replace(data($r/creator), "https?://orcid.org/", ""))}
  }
  else cp:deest()
  let $thead := ("CTS URN", "Lemma", "Context" , "Place" , "Annotation Creator")
  return cp:table($thead , $tbody)
};

(: title for showing occurrences of lemma :)
declare function cp:lemma_head($lemma_urn){
  let $tbody :=
  if (starts-with($lemma_urn, "urn:cite:croala:latlexent.lex")) then
  for $r in collection("cp-latlexents")//record[lemma/@citeurn=$lemma_urn]
  let $lemma_label := $r/lemma
  let $count_occur := count(collection("cp-cite-lemmata")//record[lemma/@citeurn=$lemma_urn])
  return element h3 { "Lemma:" , data($lemma_label) , "&#8212; In annotations:" , xs:string($count_occur) }
  else cp:deest()
  return $tbody
};

(: 2 - display list of annotations :)
declare function cp:lemma_cite($lemma_urn){
  let $tbody :=
  if (starts-with($lemma_urn, "urn:cite:croala:latlexent.lex")) then
  for $r in collection("cp-cite-lemmata")//record[lemma/@citeurn=$lemma_urn]
  let $morph_record := data(collection("cp-cite-morphs")//record[seg/@citeurn=$r/seg/@citeurn]/morph)
  let $locus_record := collection("cp-cite-loci")//record[ctsurn=$r/seg/@cts]/citelocus
  let $locus_label := collection("cp-loci")//record[citebody/@citeurn=$locus_record]/label
  
  let $period_record := collection("cp-cite-aetates")//record[citeurn=$r/seg/@citeurn]/citeaetas
  let $period_label := collection("cp-aetates")//record[citebody/@citeurn=$period_record]/label
  
  return element tr {
    element td { 
    attribute class { "cts_cite"} ,
    cp:simple_link($cp:cite_namespace || data($r/seg/@citeurn), data($r/seg/@cts)) },
    
    element td { 
    attribute class { "morph"},
    $morph_record },
    
    cp:openurn (data( $r/seg/@cts ))//td[3] ,
    
    element td {
      attribute class { "locus"},
      if ($locus_label) then cp:simple_link( $cp:cite_namespace || $locus_record , data($locus_label) ) else ()
    },
    
    element td {
      attribute class { "period"},
      if ($period_label) then cp:simple_link( $cp:cite_namespace || $period_record , data($period_label) ) else ()
    },
    
    element td { cp:simple_link(data($r/creator), replace(data($r/creator), "https?://orcid.org/", ""))}
  }
  else cp:deest()
  let $thead := ("CTS URN", "Morphology", "Context" , "Place" , "Period" , "Annotation Creator")
  return cp:table($thead , $tbody)
};

(: title for showing occurrences of morph combination :)
declare function cp:morph_head($morph_urn){
  let $tbody :=
  if (starts-with($morph_urn, "urn:cite:croala:latmorph.morph")) then
  for $r in collection("cp-latmorph")//record[morphcode/@citeurn=$morph_urn]
  let $morph_label := $r/label
  let $count_occur := count(collection("cp-cite-morphs")//record[morph/@citeurn=$morph_urn])
  return element h3 { "Morphology combination:" , data($morph_label) , "&#8212; In annotations:" , xs:string($count_occur) }
  else cp:deest()
  return $tbody
};

(: 2 - display list of annotations with this morph combination :)
declare function cp:morph_cite($morph_urn){
  let $tbody :=
  if (starts-with($morph_urn, "urn:cite:croala:latmorph.morph")) then
  for $r in collection("cp-cite-morphs")//record[morph/@citeurn=$morph_urn]
  let $lemma_record := collection("cp-cite-lemmata")//record[seg/@citeurn=$r/seg/@citeurn]/lemma/@citeurn
  let $lemma_label := collection("cp-latlexents")//record[lemma/@citeurn=$lemma_record]/lemma
  
  let $locus_record := collection("cp-cite-loci")//record[ctsurn=$r/seg/@cts]/citelocus
  let $locus_label := collection("cp-loci")//record[citebody/@citeurn=$locus_record]/label
  
  let $period_record := collection("cp-cite-aetates")//record[citeurn=$r/seg/@citeurn]/citeaetas
  let $period_label := collection("cp-aetates")//record[citebody/@citeurn=$period_record]/label
  
  return element tr {
    element td { 
    attribute class { "cts_cite"} ,
    cp:simple_link($cp:cite_namespace || data($r/seg/@citeurn), data($r/seg/@cts)) },
    
    element td { 
    attribute class { "lemma"},
    cp:simple_link($cp:cite_namespace || $lemma_record , data($lemma_label) ) },
    
    cp:openurn (data( $r/seg/@cts ))//td[3] ,
    
    element td {
      attribute class { "locus"},
      if ($locus_label) then cp:simple_link( $cp:cite_namespace || $locus_record , data($locus_label) ) else ()
    },
    
    element td {
      attribute class { "period"},
      if ($period_label) then cp:simple_link( $cp:cite_namespace || $period_record , data($period_label) ) else ()
    },
    
    element td { cp:simple_link(data($r/creator), replace(data($r/creator), "https?://orcid.org/", ""))}
  }
  else cp:deest()
  let $thead := ("CTS URN", "Lemma", "Context" , "Place" , "Period" , "Annotation Creator")
  return cp:table($thead , $tbody)
};

(: statistics 1 - count annotations / records :)
(: returns sequence of five numbers - L M Loc Aet estloc :)
declare function cp:count_annotations_db (){
  let $count1 :=
  let $annotations := ("cp-cite-lemmata", "cp-cite-morphs", "cp-cite-loci", "cp-cite-aetates")

for $a in $annotations
let $count := count(db:open($a)//record)
return element { $a } { $count }
let $count2 := count(db:open("cp-cite-urns")//w[@ana])
return element counts { $count1 , element cp-cite-urns { $count2 } }
};

(: statistics 2 - sum of all annotation records :)
(: input - sequence of numbers :)
declare function cp:sum_annotations_db($a_counts){
 sum(data($a_counts//*))
};

(: statistics 3 - count all CTS URNs :)
declare function cp:count_cts (){
  count(collection("cp-cts-urns")//w[@n])
};

(: statistics 4 - count places, periods, latlexents , morph forms :)

declare function cp:count_entities_db (){
  let $count1 :=
  let $annotations := ("cp-loci", "cp-aetates", "cp-latlexents", "cp-latmorph")

for $a in $annotations
let $count := count(db:open($a)//record)
return element { $a } { $count }
return element counts { $count1 }
};

declare function cp:count_annotations_table ($annotations) {
  let $dbs := map { 
  "cp-loci" : "Places",
  "cp-aetates" : "Periods" ,
  "cp-latlexents" : "Lemmata" ,
  "cp-latmorph" : "Morphological configurations",
  "cp-cite-lemmata" : "Lexical annotations",
  "cp-cite-morphs" : "Morphological annotations" ,
  "cp-cite-loci" : "Toponymical annotations" ,
  "cp-cite-aetates" : "Temporal annotations",
  "cp-cite-urns" : "Qualifying annotations"}
  let $rows :=
  for $a in $annotations//*
  let $db := $a/name()
  let $count := data($a)
  return element tr { 
  element td { 
  attribute class { "col-md-8" },
  map:get($dbs, $db) || " (" ||  $db || ")" },
  element td { 
  attribute class { "col-md-4" },
  $count }
}
let $head := ("Type of record" , "Current count")
return cp:table ($head, $rows)
};

declare function cp:loca_textus_head($text_urn){
  let $tbody :=
  if (starts-with($text_urn, "urn:cts:croala:")) then
  let $cts_count := collection("cp-cite-loci")//record[starts-with(ctsurn,$text_urn)]
  let $count_place_distinct := count( distinct-values($cts_count/citelocus) )
  let $cts_label := collection("cp-2-texts")//*:edition[@urn=$text_urn]/*:label
  return element h3 { "Text:" , data($cts_label) , "&#8212; Place names:" , $count_place_distinct  , "&#8212; Mentions of place names:" , count($cts_count) }
  else if ($text_urn="corpus") then
  let $cts_count := collection("cp-cite-loci")//record
  let $count_place_distinct := count( distinct-values($cts_count/citelocus) )
  return element h3 { "Whole corpus &#8212; Place names:" , $count_place_distinct  , "&#8212; Mentions of place names:" , count($cts_count) }
  else cp:deest()
  return $tbody
};

(: From CTS TI description, return textgroup / author name for URN :)
declare function cp:textgroup($urn){
  let $group := substring-before($urn, ".")
  let $author := collection("cp-2-texts")//*:textgroup[@urn=$group]
  return $author//*:groupname/*:persName[1]
};

(: From CTS TI description, return author, title, edition :)
declare function cp:metadata($urn){
  if (collection("cp-2-texts")//*:edition[@urn=$urn]) then
  for $cts in collection("cp-2-texts")//*:edition[@urn=$urn]
return cp:table ( "" ,  (
element tr { 
attribute class { "table-success"},
element td { "Author / Group"} ,
element td { data(cp:textgroup($urn)) } } , 
element tr { 
attribute class { "table-success"},
element td { "Work"} ,
element td { data($cts/..//*:title) } } , 
element tr { 
attribute class { "table-success"},
element td { "Edition"} ,
element td { data($cts/*:label) }  } )
)
else cp:deest()
};

declare function cp:estlocus_show_info ($urn , $estlocus){
  let $definition := map:get($cp:estlocus_info, $estlocus)
  return element h1 {
    "Certainty: " || $estlocus || " &#8212; " || $definition || " &#8212; Occurrences: " || count(cp:estlocus_index($urn,  $estlocus)//tr )
  }
};

(: For a CITE URN, return label and uri for a place :)
declare function cp:locus_data($locus) {
  let $locus_data := collection("cp-loci")//record[citebody/@citeurn=$locus]
  let $locus_label := $locus_data/label
  let $locus_uri := $locus_data/uri
  return if ($locus_data) then element tr { 
  element td { $locus_uri , $locus_label }
}
  else cp:deest()
};

(: Join cp-cite-loci and cp-cite-urns on CTS :)
(: cp-cite-urns must have a ctsurn element :)
declare function cp:estlocus_locus(){
  element list {
for $estlocus_place in (collection("cp-cite-urns"), collection("cp-cite-loci"))//*[name()=("w", "record")]
let $cts := $estlocus_place/ctsurn
group by $cts
return element tr { 
element cts { $cts } , element estlocus { $estlocus_place/@ana/string() } , $estlocus_place/citelocus }
}
};

(: for estlocus[1] return as link the cts[1] etc :)
declare function cp:use_parallel_position($a_b, $url){
  for $est in $a_b/estlocus
  let $pos := functx:index-of-node($a_b//estlocus, $est)
  let $cts := $url || $a_b/cts[position()=$pos]
  return if ($est) then cp:simple_link ( $cts , $est/string() )
  else cp:deest()
};

(: Join the cp-cite-loci and cp-cite-urns dbs, return place CITE URN and label, with all instances of estlocus for a place :)
(: Enables analysis of different categorizations for a place :)
declare function cp:join_locus_estlocus(){
for $cts_set in cp:estlocus_locus()//tr
let $locus := $cts_set/citelocus
group by $locus
order by count($cts_set) descending
return if ($locus) then element tr {
  element td { cp:simple_link("http://croala.ffzg.unizg.hr/basex/cite/" || $locus , $locus) } ,
  (: for a place, return label and link :)
  let $locus_name := cp:locus_data($locus)
  return element td { cp:simple_link($locus_name//uri , $locus_name//label/string() ) } ,
  
  element td { count($cts_set) } ,
  element td {
  (: for the first estlocus, get first cts etc. :)
  let $r := element td { 
  $cts_set/estlocus ,
  $cts_set/cts }
  return cp:use_parallel_position ( $r , "http://croala.ffzg.unizg.hr/basex/ctsp/" )
}
}
else()
};

(: return table with a legend of certainty levels :)
declare function cp:estlocus_info_all() {
let $estlocus := ("estlocus0", "estlocus1", "estlocus2", "estlocus3", "estlocus4", "estlocusX")
for $e in $estlocus
return element tr { 
element td { $e }, element td { map:get($cp:estlocus_info, $e)}
}
};

(: For a CITE URN of a place or period, return label and uri :)
declare function cp:cite_data($cite_urn) {
  let $cite_map := map {
    "urn:cite:croala:loci.aetas" : "cp-aetates",
    "urn:cite:croala:loci.locid" : "cp-loci"
  }
  let $collection := map:get($cite_map , replace($cite_urn, "[0-9]+", ""))
  let $cite_data := collection($collection)//record[citebody/@citeurn=$cite_urn]
  let $cite_label := $cite_data/label
  let $cite_uri := element uri { "http://croala.ffzg.unizg.hr/basex/cite/" || $cite_urn }
  return if ($cite_data) then element tr { 
  element td { $cite_uri , $cite_label }
}
  else cp:deest()
};

(: return table with rows cts[1] , citeurn[1] , citeaetas[1] etc :)
declare function cp:use_parallel_position_period($a_b){
  for $est in $a_b/cts
  let $pos := functx:index-of-node($a_b//cts, $est)
  let $citeurn := $a_b/citeurn[position()=$pos]
  let $citeaetas := $a_b/citeaetas[position()=$pos]
  return if ($est) then element tr { 
  element td { cp:simple_link ( "http://croala.ffzg.unizg.hr/basex/ctsp/" || $est , $est/string() ) } , 
  element td { cp:simple_link ( "http://croala.ffzg.unizg.hr/basex/cite/" || $citeurn , $citeurn/string() ) } , 
  element td { cp:simple_link ( "http://croala.ffzg.unizg.hr/basex/cite/" || $citeaetas , $citeaetas/string() ) } }
  else cp:deest()
};

(: Join cp-cite-loci and cp-cite-aetates on CTS :)
declare function cp:locus_aetas(){
  element list {
for $period_place in (
  collection("cp-cite-aetates"), 
  collection("cp-cite-loci")
)//record
let $cts := $period_place/ctsurn
group by $cts
return if ($period_place/citeaetas and $period_place/citelocus) then element tr { 
element cts { $cts } , 
element citeurn { distinct-values($period_place/citeurn) } , 
$period_place/citeaetas , 
$period_place/citelocus }
else()
}
};

(: Join the cp-cite-loci and cp-cite-aetates dbs, return place CITE URN and label, with all instances of a period for a place :)
(: First version, see below cp:locus_aetates :)
(: Enables analysis of different periods for a place :)
declare function cp:join_locus_aetas(){
for $cts_set in cp:locus_aetas()//tr
let $locus := $cts_set/citelocus
group by $locus
order by count($cts_set) descending
return element tr {
  (: for a place, return label and link :)
  let $locus_name := cp:cite_data($locus)
  return element td { cp:simple_link($locus_name//uri , $locus_name//label/string() ) } ,
  element td { count($cts_set[citeaetas]) } ,
  element td { 
  for $cite_uri_ae in distinct-values($cts_set/citeaetas)
  let $aetas_name := cp:cite_data($cite_uri_ae)
  return if ($aetas_name//label) 
    then cp:simple_link($aetas_name//uri , $aetas_name//label/string() ) 
    else()
},
  element td {
    cp:table ( "", (
    for $c in $cts_set   
    return cp:use_parallel_position_period($c)
)
)
}
}
};

(: Visualize annotated segments in divs :)
(: Build a CTS for a div segment :)
declare function cp:wordtree($word, $ctsname) {
let $tree := string-join(data($word/ancestor-or-self::*[@n]/@n),'.')
return attribute href { 
element ctsurn { "http://croala.ffzg.unizg.hr/basex/ctsp/" || functx:substring-before-last($ctsname, ":") || ":" || $tree } }
};

(: replace w elements with + or - :)
declare function cp:plus($div, $ctsdiv){
element div {
 attribute class { "graph-inner"},
 element h2 { cp:cts_metadata_simple($ctsdiv) } ,
  let $names := ("l", "s")
  for $l in $div//*[name()=$names]
    let $wnames := ("w", "tei:w", "name", "tei:name", "placeName", "tei:placeName")
    let $lines := for $w in $l/*[name()=$wnames]
      let $ctsurn := cp:wordtree($w, $ctsdiv)
    return if ($w/@ana) then element a { $ctsurn , "+" } else "-"
  return element p { $lines }
  }
};

(: from CTS, open div -- need cp-div-cts for that :)
declare function cp:openctsdiv($ctsdiv){
  let $divnode := collection("cp-div-cts")//record[ctsurn=$ctsdiv]
  let $pre := $divnode/@xml:id
  return if ($divnode) then db:open-id("cp-2-texts", $pre)
    else cp:deest()
};

(: return just author / textgroup and title for a CTS URN :)
declare function cp:cts_metadata_simple($urn){
  let $edition := functx:substring-before-last(
    functx:substring-before-last($urn, ":"), 
    ".")
  let $title :=  collection("cp-2-texts")//*:work[@urn=$edition]
  let $author := collection("cp-2-texts")//*:textgroup[@urn=$title/@groupUrn/string()]
  let $metadata := normalize-space($author || $title//*:title)
  return ( 
  element span { attribute class { "work"} , $metadata } ,
  element small {
    attribute class { "text-muted"},
    normalize-space(
    string-join(
      cp:openctsdiv($urn)/*:head[1]//text()[not(ancestor::*:note)], 
      " "))
    }
)
};

(: return word count for an edition / sequence of editions :)
declare function cp:count_words_edition($editions_cts){
  element tbody {
  for $e in $editions_cts
let $names := ("w", "tei:w", "name", "placeName")
let $words := collection("cp-2-texts")//*:text[@xml:base=$e]//*[name()=$names]
let $wc := count($words)
order by $wc descending
return element tr {
  element td { 
  attribute class { "edition"},
  $e } , 
  element td { 
  attribute class {"words"} ,
  $wc }
} }
};
(: EDA - return totals for estlocus in documents :)
declare function cp:estlocus_total($edition, $string){
  element tbody {
let $t := collection("cp-cite-urns")//w[matches(@ana, $string) and starts-with(@n, $edition)]
let $t_total := collection("cp-cite-urns")//w[matches(@ana, "estlocus") and starts-with(@n, $edition)]
return element tr { 
attribute class { "total"},
element td { $edition } , 
element td { $string },
element td { element b { count($t) } },
element td { count($t_total)},
element td { cp:percent( count($t), count($t_total)) || "%"} ,
element td {
  attribute class { "allwords"},
  element b {
  cp:percent(
  count($t_total) , cp:count_words_edition($edition)//tr/td[2] ) || "%"
}
}
}
}
};

(: EDA - return counts and percentages of annotated estlocus segments for each document :)
declare function cp:percent_annotated($edition, $totals){
  element tbody {
    for $e in collection("cp-cite-urns")//w[matches(@ana, "estlocus") and starts-with(@n, $edition)]
    let $ana := $e/@ana/string()
    group by $ana
    order by $ana
    return element tr { 
    attribute class { "individual"},
      element td { $edition },
      element td { $ana } ,
      element td { element b { count($e) } },
      element td { 
      "Annotated segments: " ||
        cp:percent( count($e) , $totals//tr[td=$edition]/td[3] ) || "%" } ,
      element td { 
      "Marked segments: " ||
        cp:percent( count($e), $totals//tr[td=$edition]/td[4]) || "%" },
        element td {}
} }
};

(: EDA - make table of totals and individual categories for each document :)
declare function cp:eda_estlocus_table($ed_cts){
for $edition in $ed_cts
let $totals := cp:estlocus_total($edition, "estlocus[0-4]")
let $results := cp:percent_annotated($edition, $totals)
let $table := ( $totals//tr[td[1]=$edition] , $results//tr[td[1]=$edition] )
let $headings := ("CTS URN", "Certainty code", "Segment count", "C4", "C5", "% of all words")
return cp:table($headings , $table)
};

(: return places with multiple periods :)
declare function cp:label($collection , $citeurn){
  let $l := collection($collection)//record[citebody/@citeurn=$citeurn]
  return $l/label/string()
};

declare function cp:locus_aetates() {
let $join_locus_aetas := element list {
let $set := (collection("cp-cite-aetates"), collection("cp-cite-loci"))
for $record in $set//record
let $citeurn := $record/citeurn
group by $citeurn
where $record/citelocus and $record/citeaetas
return element r { 
$record/citelocus, 
$record/citeaetas }
}
let $loci := element l {
for $r in $join_locus_aetas//r
let $locus := $r/citelocus
group by $locus
return element l {
  element citelocus { $locus } ,
  $r/citeaetas
}
}
let $la := element result {
for $l in $loci//l
where $l/citeaetas[2] and $l/citelocus[text()]
return element tr  {
  element td {
    cp:simple_link(
      "http://croala.ffzg.unizg.hr/basex/cite/" || $l/citelocus/string() ,
cp:label("cp-loci" , $l/citelocus/string())
) } , 
element td {
for $a in distinct-values($l/citeaetas)
return element citeaetas { 
cp:simple_link("http://croala.ffzg.unizg.hr/basex/cite/" || $a , cp:label("cp-aetates" , $a)) } } }
}
for $lar in $la//tr
where $lar/td[2]/citeaetas[2]
let $c := count($lar/td[2]/citeaetas)
order by $c descending
return $lar 
};

(: return places with multiple lemmata :)
declare function cp:label2($collection , $citeurn){
  let $l := collection($collection)//record[lemma/@citeurn=$citeurn]
  return $l/lemma/string()
};

declare function cp:locus_lemma() {
let $join_locus_lemma := element list {
let $set := (collection("cp-cite-lemmata-2"), collection("cp-cite-loci"))
for $record in $set//record
let $citeurn := $record/citeurn
group by $citeurn
where $record/citelocus and $record/citelemma
return element r { 
$record/citelocus, 
$record/citelemma }
}
let $loci := element l {
for $r in $join_locus_lemma//r
let $locus := $r/citelocus
group by $locus
return element l {
  element citelocus { $locus } ,
  $r/citelemma
}
}
let $la := element result {
for $l in $loci//l
where $l/citelemma[2] and $l/citelocus[text()]
return element tr  {
  element td {
    cp:simple_link(
      "http://croala.ffzg.unizg.hr/basex/cite/" || $l/citelocus/string() ,
cp:label("cp-loci" , $l/citelocus/string())
) } , 
element td {
for $a in distinct-values($l/citelemma)
return element citelemma { 
cp:simple_link("http://croala.ffzg.unizg.hr/basex/cite/" || $a , cp:label2("cp-latlexents" , $a)) }
 } }
} 
for $lar in $la//tr
where $lar/td[2]/citelemma[2]
let $c := count($lar/td[2]/citelemma)
order by $c descending
return $lar 
};