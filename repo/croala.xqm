module namespace croala = "http://croala.ffzg.unizg.hr";

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

(: add lost functions :)

(: open file/text from link :)
declare function croala:openfile($db,$filename){
  for $text in db:open($db,$filename)//*:text
  return $text
};

(: return list of documents in db, with paths, for anatomia :)
 declare function croala:analist($db) {
   (: list all documents in a collection, with link to a list of all their element names :)
element div {
element h1 { $db } ,
element ul {
for $d in collection($db)//*:TEI//*:text
let $path := db:path($d)
let $address := $db || '&amp;' || replace($path, '/', '&amp;')
return element li { 
element a {
  attribute href { '/basex/croala-ana/' || $address  } ,
  $path },
  croala:anatomia($address)//*:tr[@class='total']/*:td[2]
}
}
}
 };

declare function croala:homerlist1 ($file) {
   for $i in db:open('ilias6', $file)//*:seg
   let $adr := $i/@corresp
   return element li {
      element a { croala:homersent2(data($adr))}
}
 };
 
 declare function croala:homerlist2 ($urn) {
   for $i in db:open('ilias6')//*:seg[@corresp=$urn]
   return element div { 
   attribute class { "row"} ,
   element code {
   for $txt in $i//*:l//text()[parent::*:l or parent::*:corr]
   return   concat($txt, ' ')
} }
 };

(: bcv functions :)
declare function croala:bcv01 ($db , $string ) {
  (: bun-cob-vic-find - find any of several strings, return a list of l elements with strings marked, count results :)

let $qq := tokenize($string,' ')
let $res := element tbody {
for $d in db:open($db)//*:text//*:l 
where $d[descendant::text() contains text {$qq}  any]
return element tr {
  element td { data($d/@n) } ,
  element td { ft:mark($d[descendant::text() contains text {$qq}  any], 'code') } ,
  element td { db:path($d)}
}
}
let $countres := count($res//tr)
return element span {
element tr { 
element td { "Quaesitum: " || $string },
element td { "Inventum: " || $countres } },
$res
}
};
 
 (: return list of elements with info on parents / children :)
 declare function croala:anatomia($docpath) {
   (: for a specific file, return names of all elements below text and count their occurrences; return also names of parents or children of given element :)
let $d := collection(replace($docpath, '&amp;', '/'))/*:TEI//*:text//*[text()]
let $distinct := distinct-values($d/name())
return element tbody {
  element tr {
    attribute class {"total"},
element td {"OMNES"},
element td { count($distinct) },
element td {},
element td {}
},
 
for $i in $distinct
order by $i
let $occur := $d[name()=$i]
let $parent := $occur/../name()
let $child := $occur/*/name()
return element tr {
    element td { distinct-values($parent) },
  element td {
  element code { $i } } ,
    element td { count($occur) } , 
  element td { if ($child[1]) then distinct-values($child) else element small { "N/A" } } }
}

 };

(: make link to query in basex db :)
declare function croala:philo02 ($qw, $qdb) { 
let $qstring := "/basex/q/" || $qdb || "/"
return
  attribute href { $qstring || $qw } 

 };
 
 (: make link to next sentence :)
declare function croala:homersent2 ($naziv) { 
  attribute href { "/basex/homer/" || $naziv } , $naziv
};
(: make link to query in philologic / croala :)
declare function croala:philo01 ($qw, $qfile) { 
let $qstring := "http://croala.ffzg.unizg.hr/cgi-bin/search3t?dbname=croala&amp;word=REPLACEWORDXXX&amp;OUTPUT=conc&amp;&amp;CONJUNCT=PHRASE&amp;DISTANCE=3&amp;title=&amp;author=&amp;period=&amp;genre=&amp;DFPERIOD=1&amp;POLESPAN=5&amp;THMPRTLIMIT=1&amp;KWSS=1&amp;KWSSPRLIM=500&amp;trsortorder=author%2C+title&amp;dgdivhead=&amp;dgdivtype=&amp;dgdivlang=&amp;dgdivocauthor=&amp;dgdivocdateline=&amp;dgdivocsalutation=&amp;dgsubdivtag=&amp;filename=REPLACEFILEXXX"
return
  attribute href { replace(replace($qstring, 'REPLACEWORDXXX', $qw), 'REPLACEFILEXXX', $qfile) } 

 };

(: for given path list distinct values, return them and count of occurrences :)

declare function croala:facet3 ( $path, $naziv ) {
  let $i := xquery:eval($path, map { '': db:open('croalabib') })
let $cname := $naziv
let $ci := distinct-values($i)
for $item in $ci
let $count := $i[.=$item]
order by $item
return element div {
  attribute class { "col-md-3"} ,
  element code { 
   $item },
   " (" || count($count) || ")"
}
};


(: Homer :)
(: formatting - footer :)
declare function croala:footerhomer () {
let $f := <footer class="footer">
<div class="container">
<h3> </h3>
<h1 class="text-center"><span class="glyphicon glyphicon-leaf" aria-hidden="true"></span> <a href="http://www.ffzg.unizg.hr/klafil">Odsjek za </a> klasičnu filologiju</h1>
<div class="row">
<div  class="col-md-6">
<p class="text-center"><a href="http://www.ffzg.unizg.hr"><img src="/static/gfx/ffzghrlogo.png"/> Filozofski fakultet</a> Sveučilišta u Zagrebu</p> </div>
</div>
</div>
</footer>
return $f
};


(: to here :)
(: concatenate multiple entries :)
declare function croala:is-multiel ($terms) {
  if (some $str in $terms satisfies ($str[2]) ) then concat(data($terms) , ' ')
else data($terms)
};



(: total wcs, nicely formatted :)
declare function croala:wcsve ($db) {
  format-number(
  sum(for $i in collection($db)//*:text[not(descendant::*:text)]
  return count(ft:tokenize($i)) ), "#,##0")
};

(: make link to file in philologic :)
declare function croala:solraddr ($db, $txtnode) { 
  attribute href { "http://solr.ffzg.hr/basex/node/" || $db || "/" || data($txtnode) } 

 };
(: make link to file in philologic :)
declare function croala:localnode ($db, $txtnode) { 
  attribute href { "/node/" || $db || "/" || data($txtnode) } 

 };
 
 (: make link to file in db :)
declare function croala:filenode ($db, $txtnode) { 
element a {
  attribute href { "/basex/documentum/" || $db || "/" || data($txtnode) } ,
  $txtnode
}

 };

(: return counts for individual texts, order by word count descending :)
declare function croala:wc () { 
for $dc in collection("croalalattywc2-txts")//div
let $db := data($dc/db)
let $name := data($dc/name)
let $txtnode := data($dc/id)
let $wc := xs:integer($dc/tok)
order by $wc descending
return element tr { 
element td {
  attribute class { $db },
  $db
},
element td { 
element a { 
  croala:solraddr($db, $txtnode),
  $name
}
},
element td { attribute class {"clausula"} , format-number($wc, "#,##0") }
}
};

declare function croala:ttrfilter ($time , $x , $y ) {
  
  (: filter index database on period and ttr :)
let $csv := 
element table {
  attribute class { "table-striped  table-hover table-centered"},
element thead {
  element tr {
    element td { "TTR" },
    element td { "Div"},
    element td { "Div in CroALa"},
    element td { "Doc in CroALa"},
    element td { "Div in LatTy"},
    element td { "Doc in LatTy"},
    element td { "Sectiones lege in periodo " || $time }
  }
},
element tbody { for $i in collection("cl-idx-divs")//div[contains(per,$time)]
let $ttr := round(number($i/ttr) * 10) div 10
where $ttr lt $y and $ttr gt $x
group by $ttr
order by $ttr descending
return element tr { 
element td { $ttr } , 
element td {
  attribute class {"clausula"} , 
  count($i)} , 
element td { 
  attribute class {"clausula"} , 
  count($i/db[.="croala"])},
element td { 
  attribute class {"clausula"} , 
  count(distinct-values($i[db="croala"]/name )) } , 
element td { 
  attribute class {"clausula"} , 
  count($i/db[.="latty"])}, 
element td { 
  attribute class {"clausula"} , 
  count(distinct-values($i[db="latty"]/name )) },
element td {
  element a {
    attribute href { "/ttr2/" || $time || "/" || $ttr },
  "Sectiones ubi TTR est " || $ttr || "."
}
}
  }
}
}
return $csv

};

declare function croala:ttrfiltershow ($time , $x ) {
  
  (: show links to divs filtered for period and ttr in croala and latty :)
let $csv := 
element table {
  attribute class { "table-striped  table-hover table-centered"},
element thead {
  element tr {
    element td { "DB" },
    element td { "Doc"},
    element td { "Verborum numerus"},
    element td { "Lemmatum numerus"}
  }
},
element tbody { for $i in collection("cl-idx-divs")//div[contains(per,$time)]
let $ttr := round(number($i/ttr) * 10) div 10
let $tok := number($i/tok)
where $ttr eq $x
order by $tok descending
return element tr { 
element td {  
  attribute class {data($i/db)} , 
  $i/db } , 
element td {
  element a {
    croala:localnode(data($i/db),data($i/id)) ,
  data($i/name)
} } ,
element td { 
  attribute class {"clausula"} , 
  $i/tok } , 
element td { 
  attribute class {"clausula"} , 
  $i/typ}
  }
}
}
return $csv

};

(: count verses and words in verses in documents :)
declare function croala:versecount() {
let $db := ("croala", "latty")
for $d in $db
for $t in collection($d)//*:text[not(descendant::*:text) and descendant::*:l[not(ancestor::*:note)]]
let $name := db:path($t)
let $id := db:node-pre($t)
let $ll := $t//*:l[not(ancestor::*:note)]
let $lc := count($ll)
let $lwc := count(for $stih in $ll return ft:tokenize($stih))
order by $lc descending , $lwc descending
return element tr {
  element td {
      attribute class { $d },
    $d
  },
  element td {
     element a {
    croala:localnode($d,data($id)) ,
    $name
  }
  },
  element td {
    attribute class {"clausula"} , 
    format-number($lc, "#,##0")
  },
  element td {
    attribute class {"clausula"} , 
    format-number($lwc, "#,##0")
  }
}
};

declare function croala:versussaec1 () {
  (: count verses and words in verses in documents :)
let $db := ("latty", "croala")
for $d in $db
for $t in collection($d)//*:TEI[descendant::*:l]
let $dbn := db:name($t)
let $saec := replace($t//*:profileDesc[1]/*:creation/*:date[1]/@period, '_third', '')
let $lc := count($t//*:l)
let $lwc := count(for $w in $t//*:l return ft:tokenize($w))
group by $dbn , $saec
order by $saec
return element tr {
  element td {
      attribute class { $dbn },
    $dbn
  },
  element td {
    element a { 
attribute href { "/versus/" || $saec } ,
    $saec
  }
  },
  element td {
    attribute class {"clausula"} , 
    count($d)
  },
  element td {
    attribute class {"clausula"} , 
    format-number(sum($lc), "#,##0")
  },
  element td {
    attribute class {"clausula"} , 
    format-number(sum($lwc), "#,##0")
  }
}

};

declare function croala:translate($g) {
  let $genrelat := map {
 "Brief": "prosa oratio - epistula",
 "Dichtung": "poesis",
 "Dichtung Gelegenheitsdichtung": "poesis poesis - sylva",
 "Dichtung Lehrgedicht": "poesis poesis - didactica",
 "Dichtung Epik": "poesis poesis - epica",
 "Epik" : "poesis - epica",
 "Gelegenheitsdichtung": "poesis - sylva",
 "Lehrgedicht" : "poesis - didactica",
 "Geschichtsschreibung": "prosa oratio - historia",
 "Theater": "poesis - drama"
}
return if (map:contains($genrelat,$g)) then map:get($genrelat,$g) else $g
};

(: find all docs with verses in a period :)
declare function croala:versusperiodx ($x) {
  (: count verses and words in verses in documents :)


let $db := ("latty", "croala")
for $d in $db
for $t in collection($d)//*:TEI[descendant::*:l]
where $t//*:profileDesc[1]/*:creation/*:date[1]/@period[contains(.,$x)]
let $n := db:path($t)
let $aet := $t//*:profileDesc[1]/*:creation/*:date[1]/@period
let $typus := for $terms in $t//*:profileDesc/*:textClass/*:keywords[@scheme='typus']/*:term
              return croala:is-multiel($terms)
let $genre := for $terms2 in $t//*:profileDesc/*:textClass/*:keywords[@scheme='genre']/*:term
              return croala:is-multiel($terms2)
let $genretr := for $g in $genre return croala:translate($g)
let $id := db:node-pre($t)
let $lc := count($t//*:l)
let $lwc := count(for $w in $t//*:l return ft:tokenize($w))
order by data($aet) , $lc descending
return element tr {
  element td {
      attribute class { $d },
    $d
  },
  element td {
    replace(data($aet), 'third', 'tertia')
  },
  element td {
    element a {
    croala:solraddr($d,$id) ,
    $n }
  },
  element td {
    $typus
  },
  element td {
    $genretr
  },
 
  element td {
    attribute class {"clausula"} , 
    format-number(sum($lc), "#,##0")
  },
  element td {
    attribute class {"clausula"} , 
    format-number(sum($lwc), "#,##0")
  }
}

};

declare function croala:listclaus ($db , $dbc ) {
  (: return a list of clausulae in dbc for a db :)
for $a in collection($dbc)//c
return element tr { 
element td {
element a {
  attribute href { "http://solr.ffzg.hr/basex/node/" || $db || "/"  || data($a/@id) },
$db }
},
element td { 
attribute class {"clausula"} , data($a) }
}
};

(: use text index of db to find literally repeated clausulae :)
declare function croala:repetclaus ($dbc) {
  for $a in index:texts($dbc)
  where $a[xs:integer(@count) gt 1]
  order by xs:integer($a/@count) descending
  return element tr { 
  element td { data($a/@count) } ,
  element td { data($a) } 
}
};

(: return word count and ttrs for a table :)
(: fields name, period, wc, ttr :)

declare function croala:ttrwc2 ($coll, $db) {
for $d in collection($coll)//div[db=$db]
let $ttr := $d/ttr
order by number($ttr)
return element tr {
  element td { data($d/name)},
  element td { data($d/per)} ,
  element td { attribute class {"clausula"} , data($d/tok)},
  element td { attribute class {"clausula"} , data($ttr) }
}
};



(: count titles total :)
declare function croala:bibcount() {
count( collection("croalabib")//*:listBibl/(*:bibl|*:biblStruct)
)
};
(: count persons total :)
declare function croala:perscount() {
count( collection("croalabib")//*:listPerson/*:person
)
};
(: count mss total :)
declare function croala:mscount() {
count( collection("croalabib")//*:msDesc
)
};
(: list all works:)
declare function croala:oplist(){
  element tbody {
  for $opus in collection("croalabib")//*:listBibl[matches(@ana,'croala.opera')]//(*:bibl|*:biblStruct)[@xml:id]
  order by $opus/*:author[1] collation "?lang=hr"
  return element tr {
    element td { data($opus/@xml:id) },
    element td { 
    if ($opus/*:title) then normalize-space(data($opus/*:title[1])) else "S. t." },
    element td { if ($opus/*:author) then $opus/*:author[1] else "S. a." } ,
    element td { 
    if ($opus/*:date/@period) then data($opus/*:date/@period) else "S. d." }
  }
}
};
(: count works total :)
declare function croala:opcount() {
count( croala:oplist()//*:tr
)
};
(: count exemplars total :)
declare function croala:itemcount() {
count( collection("croalabib")//*:relatedItem[*:ref/@target]
)
};
(: count digital total :)
declare function croala:digicount() {
count( collection("croalabib")//*:relatedItem[descendant-or-self::*[contains(@type, "internet")]]
)
};

(: formatting - footer :)
declare function croala:footer () {
let $f := <footer class="footer">
<div class="container">
<h3> </h3>
<h1 class="text-center"><span class="glyphicon glyphicon-leaf" aria-hidden="true"></span> <a href="http://solr.ffzg.hr/dokuwiki/doku.php/start">Croatica et</a> Tyrolensia</h1>
<div class="row">
<div  class="col-md-3">
<a href="http://www.ukf.hr/"><img src="/static/gfx/ukflogo.gif"/></a></div> 
<div  class="col-md-6">
<p class="text-center"><a href="http://www.ffzg.unizg.hr"><img src="/static/gfx/ffzghrlogo.png"/> Filozofski fakultet</a> Sveučilišta u Zagrebu</p> 
<p class="text-center">Ludwig Boltzmann <a href="http://neolatin.lbg.ac.at/">Institut für Neulateinische Studien, Innsbruck</a> <img src="http://lbicr.lbg.ac.at/files/sites/lbicr/images/bildlogo_farbe_weiss.jpg" width="60"/></p></div>
<div  class="col-md-3"><p  class="text-center"><a href="https://www.tirol.gv.at/bildung/wissenschaftsfonds/"><img src="/static/gfx/tirollogo.png"/></a></p></div></div>
</div>
</footer>
return $f
};

(: formatting - footer on solr :)
declare function croala:footerserver () {
let $f := <footer class="footer">
<div class="container">
<h3> </h3>
<h1 class="text-center"><span class="glyphicon glyphicon-leaf" aria-hidden="true"></span> <a href="http://solr.ffzg.hr/dokuwiki/doku.php/start">Croatica et</a> Tyrolensia</h1>
<div class="row">
<div  class="col-md-3">
<a href="http://www.ukf.hr/"><img src="/basex/static/gfx/ukflogo.gif"/></a></div> 
<div  class="col-md-6">
<p class="text-center"><a href="http://www.ffzg.unizg.hr"><img src="/basex/static/gfx/ffzghrlogo.png"/> Filozofski fakultet</a> Sveučilišta u Zagrebu</p> 
<p class="text-center">Ludwig Boltzmann <a href="http://neolatin.lbg.ac.at/">Institut für Neulateinische Studien, Innsbruck</a> <img src="http://lbicr.lbg.ac.at/files/sites/lbicr/images/bildlogo_farbe_weiss.jpg" width="60"/></p></div>
<div  class="col-md-3"><p  class="text-center"><a href="https://www.tirol.gv.at/bildung/wissenschaftsfonds/"><img src="/basex/static/gfx/tirollogo.png"/></a></p></div></div>
</div>
</footer>
return $f
};


(: script for tablesorter, Croatian sorting order :)
declare function croala:tablescript () {
  let $script := element script {
    "
    $(function() {
  // define sugar.js Croatian sort order
  Array.AlphanumericSortOrder = 'AaBbCcČčĆćDdÐđEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsŠšTtUuVvWwZzŽžXxYy';
  Array.AlphanumericSortIgnoreCase = true;
  // see https://github.com/andrewplummer/Sugar/issues/382#issuecomment-41526957
  Array.AlphanumericSortEquivalents = {};
  
  $('table').tablesorter({
    theme : 'blue',
    // table = table object; get config options from table.config
    // column is the column index (zero-based)
    ignoreCase : false,
    textSorter : {
      1 : Array.AlphanumericSort,     // alphanumeric sort from sugar (http://sugarjs.com/arrays#sorting)
      
    }
  });
});
    "
    }
    return $script
};

declare function croala:facet ( $naziv ) {
  let $map := map {
    "zapisi" : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]',
    "autori" : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]//*:author',
    "osobe" : '//*:body/*:listBibl[@type="croala.drama"]//*:persName',
    'organizacije' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]//*:orgName', 
    'razdoblja' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]//*:date/@period', 
    'datumi' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]//*:date', 
     'naselja' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]//*:placeName',
     'lokacije' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]//*:address',
    'bibliografija' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]/*:relatedItem/*:listBibl/*:bibl', 
   'RHK' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]/*:ref', 
   'naslovi_latinski' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]/*:title[@xml:lang="lat" and text()]', 
  'naslovi_hrvatski' : '//*:body/*:listBibl[@type="croala.drama"]/*:bibl[@type="drama"]/*:title[@xml:lang="hrv" and text()]',
   'bibliografija_naslovi' : '//*:body/*:listBibl[@type="croala.drama.sekundarna"]/*:bibl'
  }
  let $i := xquery:eval(map:get($map,$naziv), map { '': db:open('croalabib', 'manifestacije/tisak/drame.xml') })
for $ci in distinct-values($i)
let $cic := count($i[.=$ci])
order by $ci collation "?lang=hr"
return element div { 
  attribute class { "col-md-3"},
  element code { $ci || " (" || $cic || ")" 
}

}
};

declare function croala:facet2 ( $expr, $naziv ) {
  let $i := xquery:eval($expr, map { '': db:open('croalabib', 'manifestacije/tisak/drame.xml') })
let $cname := $naziv
let $ci := count(distinct-values($i))
return element div {
  attribute class { "col-md-3"} ,
  element code { 
  element a { croala:facetlink($cname) } , " (" || $ci || ")" }
}
};

(: make link to next facet :)
declare function croala:facetlink ($naziv) { 
  attribute href { "/basex/croalabib2/facet/" || $naziv } , $naziv

 };

(: make link to next facet :)
declare function croala:facetlink1 ($naziv) { 
  attribute href { "/croalabib2/facet/" || $naziv } , $naziv

 };
(: hrefs for authority files :)
declare function croala:authidhref($type, $target) {
let $aid := map {
  "viaf": "http://viaf.org/viaf/",
  "pnd": "http://d-nb.info/gnd/",
  "lc": "http://id.loc.gov/authorities/names/",
  "cerl": "http://thesaurus.cerl.org/record/",
  "croala.typ": "#"
}
return map:get($aid , $type) || data($target)
};

(: make link to query in basex db :)
declare function croala:philo02a ($qw, $qdb) { 
let $qstring := "/basex/q/" || $qdb || "/"
return
  attribute href { $qstring || $qw } 

 };
 
 declare function croala:infodb($dbname) {
  (: return info on croalabib db, with Latin field names :)
let $week := map {
  "name": "nomen",
  "documents": "documenta",
  "timestamp": "de dato"
}
return element table { 
attribute class { "pull-right"},
let $i := db:info($dbname)/databaseproperties
  for $n in ('name','documents','timestamp')
  return 
   element tr {
    element td { map:get($week, $n) } ,
    element td { $i/*[name()=$n] }
  }
}
};
declare function croala:htmlhead($title) {
  (: return html template to be filled with title :)
  (: title should be declared as variable in xq :)

<head><title> { $title } </title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link rel="icon" href="/static/gfx/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="/static/dist/css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="/static/dist/css/basexc.css"/>
</head>

};

declare function croala:htmlhead-tablesorter($title) {
  (: return html template to be filled with title :)
  (: title should be declared as variable in xq :)
(: call scripts tablesorter, sugar :)
<head><title> { $title } </title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link rel="icon" href="/static/gfx/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="/static/dist/css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="/static/dist/css/basexc.css"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script src="/static/dist/js/bootstrap.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sugar/1.4.1/sugar.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.tablesorter/2.23.5/js/jquery.tablesorter.min.js"></script>
</head>

};

(: the same, for server / basex :)
declare function croala:htmlhead-tablesorter-server($title) {
  (: return html template to be filled with title :)
  (: title should be declared as variable in xq :)
(: call scripts tablesorter, sugar :)
<head><title> { $title } </title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link rel="icon" href="/basex/static/gfx/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="/basex/static/dist/css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="/basex/static/dist/css/basexc.css"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sugar/1.4.1/sugar.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.tablesorter/2.23.5/js/jquery.tablesorter.min.js"></script>
</head>

};

declare function croala:htmlheadserver($title) {
  (: return html template to be filled with title :)
  (: title should be declared as variable in xq :)

<head><title> { $title } </title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link rel="icon" href="/basex/static/gfx/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="/basex/static/dist/css/bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="/basex/static/dist/css/basexc.css"/>
</head>

};

declare function croala:getwdatapersons() {
  element table { 
  element thead {
    element tr {
      element td {"Nomina"},
      element td {"Wikidata"},
      element td {"In fabula"}
    } },
  element tbody {
  for $i in collection("croalabib")//*:person[not(@sameAs) and *:bibl/*:relatedItem/*:ref[contains(@target,'wikidata')]]
  let $q := $i/*:bibl/*:relatedItem/*:ref[contains(@target,'wikidata')]
  return element tr { element td { $i/*:persName[1] } , 
  element td {
    element a {
      attribute href { $q/@target } ,
      replace($q[1]/@target,'https://www.wikidata.org/wiki/','')
    }
  },
  element td {
    if ($i/*:note/*:ref/@target) then
    for $drama in $i/*:note/*:ref/@target
    return 
    element a {
      attribute href {
        "/basex/dramata" || replace($drama, '#', '/')
      },
      replace(data($drama),'#','')
    }
    else if ($i//*:event[@ana='drama']/*:desc/*:name/@ref) then
    for $drama2 in $i//*:event[@ana='drama']/*:desc/*:name/@ref
    return 
    element a {
      attribute href {
        "/basex/dramata" || replace($drama2, '#', '/')
      },
      replace(data($drama2),'#','')
    }
    else "N/A"
  }  }
}
}
};

(: a page for each drama :)
declare function croala:dramatitlepage($dramaid) {
  let $i := collection('croalabib')//*:bibl[@xml:id=$dramaid]
  return element div {
    attribute class { "dramainfo"},
    $i
  }
};

declare function croala:croalabiblist(){
  for $r in collection("croalabib")//tei:listBibl[@type="croala.libri.digital"]/tei:bibl
  order by $r/tei:author[1] collation "?lang=hr"
return 
element tr { 
element td { 
element span { 
attribute class {"bibline"} ,
element b { "A: "},
for $a in $r/tei:author return $a } ,
element span { 
attribute class {"bibline"} ,
for $t in $r/tei:title return $t },
element span { 
attribute class {"bibline"} ,
element b { "E: "},
for $e in $r/tei:editor return 
$e },

for $i in $r/tei:relatedItem return 
element span { 
attribute class {"bibline"} , $i ,
element a { 
attribute href {$i/tei:ref/@target} , "Lege" } ,
element a { 
attribute href { replace("http://solr.ffzg.hr/philo4/croala0/query?report=bibliography&amp;method=proxy&amp;colloc_filter_choice=frequency&amp;filter_frequency=100&amp;year_interval=10&amp;filename=REPLACEXXXX&amp;start=0&amp;end=0","REPLACEXXXX", replace($i/tei:ref/@target,"#","")) } , "Scrutare" }
}
}
 }
};