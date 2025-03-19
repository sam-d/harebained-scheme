(use-modules ((guix licenses) #:prefix license:)
	     (guix build-system copy)
	     (guix gexp)
	     (guix profiles)
	     (guix packages)
	     (gnu packages chez)
	     (gnu packages guile))

(define harebrained-scheme
  (package
    (name "harebrained-scheme")
    (version "0.1")
    (source (local-file (dirname (current-filename)) #:recursive? #t))
    (build-system copy-build-system)
    (arguments '(#:phases (modify-phases %standard-phases
			    (delete 'patch-shebangs)
			    (delete 'patch-usr-bin-file)
			    (delete 'patch-generated-file-shebangs)
			    (delete 'patch-source-shebangs))
		 #:install-plan '(("./harebrained" "lib/chez-scheme/") ;copy into chez-scheme library path
                                ("./harebrained" "share/guile/site/3.0/"))));copy into guile load path
    (native-inputs (list chez-scheme chez-srfi guile-3.0))
    (home-page "http://harebrained.sam-d.com")
    (synopsis "Harebrained scheme libraries for scientific computing")
    (description "(harebrained scheme) is a collections of libraries for scientific computing in R6RS scheme, with a focus on bioinformatics.")
    (license license:gpl3)))
harebrained-scheme
;;(packages->manifest (list harebrained-scheme chez-scheme chez-srfi guile-3.0))
