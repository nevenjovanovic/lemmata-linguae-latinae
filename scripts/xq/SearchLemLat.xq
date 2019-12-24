let $db := "lll-lemlat"
for $r in collection($db)//record
where $r[ends-with(lemma, "rinus")]
(: where $r[lemma="sybota"] :)
(: order by $r/n_id :)
(: where $r[n_id="f8188"] :)
return $r
