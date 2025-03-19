#!r6rs
(library (harebrained bio private types)
  (export <bio>
          bio?
          <named>
          named?
          name)
  (import (rnrs base)
          (rnrs records syntactic))
  
  ;;the record type at the top of the hierarchy, with no fields
  (define-record-type (<bio> bio bio?))
  ;;record type for all object that naturally have a name
  (define-record-type (<named> make-named named?)
    (parent <bio>)
    (fields (immutable name name)))
) ;end library form
