#!r6rs
(library (harebrained bio collections)
  (export <biocol>
	  biocol?
          make-biocol
          biocol-name
          biocol-rename
          biocol-length
	  biocol-empty?
          biocol-ref
          biocol-set
	  biocol-add
          biocol-append
	  biocol-contains?
	  biocol-copy)
  (import (rnrs base)
          (rnrs lists)
          (rnrs sorting)
          (rnrs control)
          (rnrs hashtables)
          (rnrs io simple)
          (rnrs records syntactic)
	  (only (srfi :43) vector-append vector-copy vector-count vector-reverse-copy vector-fold vector-fold-right vector-index)
	  (harebrained bio private types))

  ;;; Biocollection
  ;;;A biocollection is a container that holds object which typically have a name associated. It's vector field 'seq' holds all elements in insert order an allows to query by index. It's hahsh-table field 'hash' maps the names of objects to its index in 'seq'. This allows retrieving values by name (i.e. a key of type string). It also stores all keys/names of each object in vector field 'names'
  ;;; It assumes all keys/names are unique but does not enforce this. A duplicated name will replace any previous entry in the hash table but not in the sequence. This might lead to unexpected behavious and should be avoided. 
  (define-record-type (<biocol> biocol biocol?)
    (parent <named>)
    (fields (immutable seq biocol-values)
	    (immutable names biocol-keys)
            (immutable hash biocol-hash)))

  ;;;; Core procedures
  (define (make-empty-biocol name)
    (biocol name (make-vector 0) (make-vector 0) (make-hashtable string-hash string=? 0)))

  (define make-biocol
    (case-lambda (() (make-empty-biocol ""))
		 ((nam) (make-empty-biocol nam))
		 ((nam l) (make-biocol nam l (if (vector? l) (vector-map name l) (map name l))))
                 ((nam l ln) (let* ((s (if (vector? l) l (list->vector l)))
				    (size (vector-length s))
				    (n (if (vector? ln) ln (list->vector ln)))
				    (h (make-hashtable string-hash string=? size)))
			       (do ((i 0 (+ i 1)))
                                ((= i size) (biocol nam s n h))
                              (hashtable-set! h (vector-ref n i) i))))))

  (define biocol-name name)
  (define (biocol-rename bc nam)
    (biocol nam (biocol-values bc) (biocol-keys bc) (biocol-hash bc)))

  ;;;; Sequence interface to biocollections
  (define (biocol-length bc) (vector-length (biocol-values bc)))
  (define (biocol-empty? bc) (= 0 (vector-length (biocol-values bc))))

  ;;;; Map/Hash interface to biocollections
  (define (biocol-contains? bc nam) (hashtable-contains? (biocol-hash bc) nam))
  (define (biocol-copy bc) (biocol (name bc) (vector-copy (biocol-values bc)) (vector-copy (biocol-keys bc)) (hashtable-copy (biocol-hash bc) #t))); create a copy.
  ;;; Sequence like interface:
  (define biocol-ref
    (case-lambda ((bc i-or-name) (biocol-ref bc i-or-name (lambda() (error 'biocol-ref "key not found" i-or-name))))
		 ((bc i-or-name default)
		  (if (integer? i-or-name) (vector-ref (biocol-values bc) i-or-name)
		      (if (biocol-contains? bc i-or-name) (vector-ref (biocol-values bc) (hashtable-ref (biocol-hash bc) i-or-name default)) default)))))
  (define (biocol-set bc key val)
    (let ((new-bc (biocol-copy bc)))
      (if (hashtable-contains? (biocol-hash new-bc) key)
	  (begin (vector-set! (biocol-values new-bc) (hashtable-ref (biocol-hash new-bc) key #f) val) new-bc)
	(biocol-add new-bc val key)))) ;; set an associate if it exists, add if not
  (define (biocol-append bc1 . bcs)
    (let* ((v (apply vector-append (biocol-values bc1) (map biocol-values bcs)))
	   (k (apply vector-append (biocol-keys bc1) (map biocol-keys bcs)))
	   (h (do ((i 0 (+ i 1))
		   (h (make-hashtable string-hash string=? (vector-length v))))
		  ((= i (vector-length k)) h)
		(hashtable-set! h (vector-ref k i) i))))
      (biocol (name bc1) v k h)));append several biocols one after the other TODO what should the object be named?? Currently name of first biocol
  (define biocol-add 
    (case-lambda ((bc e) (unless (named? e) (assertion-violation 'not-named "e needs to be a <named> type" e)) (biocol-append bc e (name e)))
		 ((bc e k)
		  (let ((h (hashtable-copy (biocol-hash bc) #t)))
		    (hashtable-set! h k (biocol-length bc))
		    (biocol (name bc) (vector-append (biocol-values bc) (vector e)) (vector-append (biocol-keys bc) (vector k)) h))))) ; add an element e to the end of a biocol under key k
);end of library form
