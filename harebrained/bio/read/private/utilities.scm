#!r6rs
(library (harebrained bio read private utilities)
  (export char->symbol
	  dna-alphabet
	  rna-alphabet
	  aa-alphabet
	  choose-alphabet)
  (import (rnrs base)
          (rnrs enums)
	  (only (rnrs unicode) char-ci=?)
	  (only (harebrained bio sequences) dna rna protein bioseq))

  (define (char->symbol c)
    (cond ((char-ci=? c #\A) 'A )
          ((char-ci=? c #\C) 'C )
          ((char-ci=? c #\G) 'G )
          ((char-ci=? c #\T) 'T )
          ((char-ci=? c #\B) 'B )
          ((char-ci=? c #\S) 'S )
          ((char-ci=? c #\M) 'M )
          ((char-ci=? c #\I) 'I )
          ((char-ci=? c #\L) 'L )
          ((char-ci=? c #\W) 'W )
          ((char-ci=? c #\H) 'H )
          ((char-ci=? c #\Y) 'Y )
          ((char-ci=? c #\K) 'K )
          ((char-ci=? c #\R) 'R )
          ((char-ci=? c #\F) 'F )
          ((char-ci=? c #\V) 'V )
          ((char-ci=? c #\P) 'P )
          ((char-ci=? c #\D) 'D )
          ((char-ci=? c #\Q) 'Q )
          ((char-ci=? c #\N) 'N )
          ((char-ci=? c #\E) 'E )
          (else (string->symbol (string c)))));read all non-special characters and convert to symbol

  ;;choose type based on list of characters
  (define dna-alphabet (make-enumeration (list 'A 'T 'C 'G)))
  (define rna-alphabet (make-enumeration (list 'A 'U 'C 'G)))
  (define aa-alphabet (make-enumeration (list 'A 'R 'N 'D 'C 'Q 'E 'G 'H 'I 'L 'K 'M 'F 'P 'S 'T 'W 'Y 'V)))

  (define (choose-alphabet l)
    (let ([enum (make-enumeration l)])
      (cond [(enum-set-subset? enum rna-alphabet) rna]
            [(enum-set-subset? enum dna-alphabet) dna]
            [(enum-set-subset? enum aa-alphabet) protein]
            [else bioseq])))

) ;end library form
