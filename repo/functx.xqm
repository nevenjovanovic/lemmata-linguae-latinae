module namespace functx = "http://www.functx.com";

declare function functx:escape-for-regex
  ( $arg ) {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;
 
declare function functx:substring-after-last
  ( $arg ,
    $delim ) {

   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 } ;
 
 declare function functx:substring-before-last
  ( $arg ,
    $delim ) {

   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;

declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {

   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;
 
 declare function functx:index-of-node
  ( $nodes ,
    $nodeToFind ) {

  for $seq in (1 to count($nodes))
  return $seq[$nodes[$seq] is $nodeToFind]
 } ;