#!r6rs
(library (harebrained bio sequences)
  (export <bioseq>
          bioseq
          bioseq?
          bioseq-name
          <dna>
          dna
          dna?
          <rna>
          rna
          rna?
          <protein>
          protein
          protein?
          bioseq-length
          bioseq-ref
          bioseq->string
          dna-complement
          bioseq-subsequence
          bioseq-reverse
          dna-reverse-complement
          dna->rna
          rna->dna
          bioseq-counts
          bioseq-rename)
  (import (rnrs base)
          (rnrs io simple)
          (rnrs io ports)
          (rnrs lists)
          (rnrs control)
          (rnrs hashtables)
          (rnrs records syntactic)
	  (harebrained bio private types))

  (define-record-type (<bioseq> bioseq bioseq?)
    (parent <named>)
    (fields (immutable seq bioseq-seq)))
  (define-record-type (<dna> dna dna?)(parent <bioseq>))
  (define-record-type (<rna> rna rna?)(parent <bioseq>))
  (define-record-type (<protein> protein protein?)(parent <bioseq>))
  (define-record-type (<read> make-read read?)
    (parent <bioseq>)
    (fields (immutable qual read-qual)))

  (define (choose-type t)
    (cond ((dna? t) dna)
          ((rna? t) rna)
          ((protein? t) protein)
          ((bioseq? t) bioseq)
          (else (error 'choose-type "not a sequence type" t))))

  (define bioseq-name name)

  (define (bioseq-length bs)
    (vector-length (bioseq-seq bs)))

  (define (bioseq-ref bs i)
    (vector-ref (bioseq-seq bs) i))

  (define (bioseq->string bs)
    (call-with-string-output-port
     (lambda (p) (vector-for-each (lambda (e) (display (symbol->string e) p)) (bioseq-seq bs)))))

  (define (bioseq-reverse bs)
    (bioseq-rev-comp bs #f))

  (define (dna-reverse-complement bs)
    (unless (dna? bs) (assertion-violation 'dna-reverse-complement "can only work on bioseq of type <dna>" bs))
    (bioseq-rev-comp bs #t))

  (define (bioseq-rev-comp bs complement?)
    (do ((from (- (bioseq-length bs) 1) (- from 1))
         (to 0 (+ to 1))
         (vec (make-vector (bioseq-length bs))))
	((< from 0) ((choose-type bs) (bioseq-name bs) vec))
      (vector-set! vec to (if complement? (get-complement (bioseq-ref bs from)) (bioseq-ref bs from)))))

  (define (get-complement e)
    (cond ((eq? e 'A) 'T)
          ((eq? e 'C) 'G)
          ((eq? e 'G) 'C)
          ((eq? e 'T) 'A)
          (else (assertion-violation 'get-complement "must be from dna-alphabet:" e))))

  (define (dna-complement bs)
    (unless (dna? bs) (assertion-violation 'dna-complement "can only complement bioseq of type <dna>" bs))
    (dna (bioseq-name bs) (vector-map get-complement (bioseq-seq bs))))

  (define (bioseq-subsequence bs i j)
    (unless (and (< i j) (<= j (bioseq-length bs))) (assertion-violation 'bioseq-subsequence "bounds need to be in order and within range of bioseq" bs i j))
    ((choose-type bs) (name bs) (do ((cnt i (+ cnt 1))
                                     (vcnt 0 (+ vcnt 1))
                                     (v (make-vector (- j i))))
                                    ((>= cnt j) v)
                                  (vector-set! v vcnt (bioseq-ref bs cnt)))))

  ;; (-> dna? rna?)
  (define (dna->rna dna)
    (unless (dna? dna) (assertion-violation 'dna->rna "input needs to be <dna> type"))
    (rna (bioseq-name dna) (vector-map (lambda (x) (if (eq? 'T x) 'U x)) (bioseq-seq dna))))
  ;; (-> rna? dna?)
  (define (rna->dna rna)
    (unless (rna? rna) (assertion-violation 'rna->dna "input needs to be <rna> type"))
    (dna (bioseq-name rna) (vector-map (lambda (x) (if (eq? 'U x) 'T x)) (bioseq-seq rna))))

  (define (bioseq-counts bs)
    (let ((h (make-eq-hashtable)))
      (vector-map (lambda (e) (hashtable-set! h e (+ 1 (hashtable-ref h e 0)))) (bioseq-seq bs))
      h))

  (define (bioseq-rename bc name)
    ((choose-type bc) name (bioseq-seq bc)))

);end of library form
