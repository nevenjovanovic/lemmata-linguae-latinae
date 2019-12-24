(: for a lemma, retrieve URN :)
let $urn := "urn:cite2:croala:lemmata.v20191224:l234"
let $db := "lll-lemlat"
for $r in collection($db)//record
where $r[urn=$urn]
(: order by $r/n_id :)
(: where $r[n_id="f8188"] :)
return $r
