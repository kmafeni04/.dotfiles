((content) @injection.content
 (#set! injection.language "html")
 (#set! injection.combined))

((expr) @injection.content
 (#set! injection.language "nelua")
 (#set! injection.combined))

((val) @injection.content
 (#set! injection.language "nelua"))

((nelt_comment_body) @injection.content
 (#set! injection.language "comment"))
