(: CroALa Lemma list :)
(: for a URN, retrieve lemma in our CITE collection :)
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace croala2 = "http://croala.ffzg.unizg.hr" at "../../repo/croala2.xqm";
import module namespace cp2 = "http://croala.ffzg.unizg.hr/croalapelagios" at "../../repo/croalapelagios2.xqm";
import module namespace cite2 = "http://croala.ffzg.unizg.hr/cite" at '../../repo/croalacite2.xqm';

declare namespace page = 'http://basex.org/examples/web-page';

declare variable $title := 'Lemma vocabuli Latini';
declare variable $content := "Lemma Latinum CITE URN titulo descriptum. Latin lemma identified by a CITE URN.";
declare variable $keywords := "Latin language, Latin literature, CTS / CITE architecture, linguistic analysis, literary analysis, scholarly edition, lemma, lexicon, lexical analysis, vocabulary, dictionary";

(:~
 : This function returns an XML response message.
 :)
declare
  %rest:path("cite2lemma/{$urn}")
  %output:method(
  "xhtml"
)
  %output:omit-xml-declaration(
  "no"
)
  %output:doctype-public(
  "-//W3C//DTD XHTML 1.0 Transitional//EN"
)
  %output:doctype-system(
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
)
  function page:croalalemmatacite2lemma($urn)
{
  (: HTML template starts here :)

<html>
{ cp2:htmlheadserver($title, $content, $keywords) }
<body text="#000000">

<div class="jumbotron">
<h1><span class="fa fa-th fa-fw" aria-hidden="true"></span>{ $title }</h1>
<div class="container-fluid">
<div class="col-md-6">
<p>Linguae Latinae lemmata, { current-date() }.</p>
<p><a href="http://orcid.org/0000-0002-9119-399X">Neven Jovanović</a>.</p>
<p>Lemma identificatur ope indiculi CITE URN.</p>
<p>Functio nominatur: {rest:uri()}.</p>
</div>
<div class="col-md-6">
{croala2:infodb('lll-lemlat')}
</div>
</div>
</div>
<div class="container-fluid">
<blockquote class="croala">

{ cite2:queryname2($urn) }

</blockquote>
     <p/>
     </div>
<hr/>
{ cp2:footerserver() }
</body>
</html>
};

return
