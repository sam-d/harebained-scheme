;; scheme-test-unit.ss
;; ----
;; Copyright © 2020 by Mark Damon Hughes. All Rights Reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;; notice, this list of conditions and the following disclaimer.
;; 2. Redistributions in binary form must reproduce the above copyright
;; notice, this list of conditions and the following disclaimer in the
;; documentation and/or other materials provided with the distribution.
;; 3. Neither the name of the copyright holder nor the names of its
;; contributors may be used to endorse or promote products derived from
;; this software without specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;; TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;; PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;; LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;; ----

(library (harebrained tests runner)
(export
	scheme-test-runner
	scheme-test-configure)
(import (rnrs)
	(srfi :64))

(define (print . args) (for-each display args) )
(define (println . args) (for-each display args) (newline) )
(define (fprint port . args) (for-each (lambda (x) (display x port)) args) )
(define (fprintln port . args) (for-each (lambda (x) (display x port)) args) (newline port) )
(define add1(lambda (x) (+ x 1)))

(define (scheme-test-runner verbose filename)
	(let [ (runner (test-runner-null))
			(group-stack '())  (group #f)
			(group-pass 0)  (group-fail 0)
			(total-pass 0)  (total-fail 0)
			(port (if filename (open-output-file filename)  (current-output-port)) )
		]
		(test-runner-on-group-begin! runner (lambda (runner suite-name count)
			;; push old
			(set! group-stack (cons (list group group-pass group-fail) group-stack))
			;; start
			(set! group suite-name)
			(set! group-pass 0)
			(set! group-fail 0)
			(when verbose (fprintln port "*** " group " START"))
		))
		(test-runner-on-group-end! runner (lambda (runner)
			(fprintln port "*** " group " END, PASS: " group-pass " / FAIL: " group-fail)
			;; pop old
			(unless (null? group-stack)
				(let [ (g (car group-stack)) ]
					(set! group (car g))
					(set! group-pass (cadr g))
					(set! group-fail (caddr g))
				)
				(set! group-stack (cdr group-stack))
		)))
		(test-runner-on-test-end! runner (lambda (runner)
			(case (test-result-kind runner)
				[(pass xpass)
					(when verbose (fprintln port "+ " (test-runner-test-name runner)
						" [" (test-result-ref runner 'source-form) "]" ) )
					(set! group-pass (add1 group-pass))
					(set! total-pass (add1 total-pass))
				]
				[(fail xfail)
					(fprintln port "- " (test-runner-test-name runner)
						" [" (test-result-ref runner 'source-form) "]"
						" expected <<<" (test-result-ref runner 'expected-value)
						">>> but got <<<" (test-result-ref runner 'actual-value)
						">>>")
					(set! group-fail (add1 group-fail))
					(set! total-fail (add1 total-fail))
				]
				[(skip)  #t]
		)))
		(test-runner-on-final! runner (lambda (runner)
			(fprintln port "FINAL PASS: " total-pass " / FAIL: " total-fail)
			(when filename  (close-output-port port))
		))
		runner
))

(define (scheme-test-configure argv)
	(let [ (verbose #t)  (filename #f) ]
		(when (or (member "-?" argv) (member "--help" argv))
			(fprintln (current-error-port) "Usage: scheme-test-configure [-v|--verbose|-q|--quiet|-o FILENAME|--output FILENAME]")
			(exit 1)
		)
		(when (or (member "-v" argv) (member "--verbose" argv))  (set! verbose #t))
		(when (or (member "-q" argv) (member "--quiet" argv))  (set! verbose #f))
		(when (member "-o" argv)  (set! filename (cadr (member "-o" argv))) )
		(when (member "--output" argv)  (set! filename (cadr (member "--output" argv))) )

		;; default factory, use scheme-test-runner directly to set parameters
		(test-runner-factory (lambda ()
			(scheme-test-runner #t #f)
		))

		(test-runner-current (scheme-test-runner verbose filename))
))

) ;; end library scheme-test-unit
