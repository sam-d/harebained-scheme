#!r6rs
;;; Library to read fasta formatted files
(library (harebrained bio read fasta)
  (export read-fasta
          make-bioseq)
  (import (rnrs base)
          (rnrs io simple)
          (rnrs io ports)
          (rnrs control)
          (harebrained bio collections)
          (harebrained bio sequences)
	  (harebrained bio read private utilities))
  
  (define (read-fasta f)
    (let ((l (cond ((and (port? f) (textual-port? f)) (read-bioseq-from-multiline-fasta f))
		   ((and (port? f) (binary-port? f)) (read-bioseq-from-multiline-fasta (transcoded-port f (make-transcoder (utf-8-codec))))) 	;assume binary port from compressed file in utf8 encoding e.g. from library (compression gzip)
                   (else (call-with-input-file f read-bioseq-from-multiline-fasta)))))
                 ;if only 1 sequence in file return it, else return the reversed list because it is built by consing
      (if (= 1 (length l)) (car l) (make-biocol (if (string? f) f "") (reverse l)))))

  (define (read-bioseq-from-port port name seq ret)
    (let ((c (read-char port)))
      (cond ((eof-object? c) (cons ((choose-alphabet seq) name (apply vector (reverse seq))) ret))
            ((char=? c #\>) (read-bioseq-from-port port (get-line port) '() (cons ((choose-alphabet seq) name (apply vector (reverse seq))) ret))) ;when reading #\> instantiate new object
            ((char=? c #\newline) (read-bioseq-from-port port name seq ret)) ;ignore newlines
            ((char=? c #\;) (get-line port)(read-bioseq-from-port port name seq ret)) ;ignore lines starting with comment ';'
            (else (read-bioseq-from-port port name (cons (char->symbol c) seq) ret))))) 

  (define (read-bioseq-from-multiline-fasta port)
    (let ((c (read-char port)))
      (if (char=? c #\>) (read-bioseq-from-port port (get-line port) '() '()) (begin (get-line port) (read-bioseq-from-multiline-fasta port))))) ;discard all lines until the first one starting with >

  ;;simple function to work in REPL and convert a string to a bioseq
  (define make-bioseq
    (case-lambda ((str) (make-bioseq str ""))
		 ((str name)
		  (car (call-with-port (open-string-input-port str) (lambda (p) (read-bioseq-from-port p name '() '())))))))
);end library form
