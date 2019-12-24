let $db := "lll-lemlat"
for $r in collection($db)//record
return insert node element urn { "urn:cite2:croala:lemmata.v20191224:l" || $r/id_lemma/string() } into $r
