#lang scribble/manual
@(require (for-label r6rs))

@title{A harebrained scheme}

@image["/harebrained/doc/logo/logo.png"]

(harebrained scheme) is a collections of libraries for scientific computing in R6RS scheme, with a focus on bioinformatics. This documentation is split into separate sections: 
@secref{gs} helps you along the first steps of using the library, @secref{ug} has some detailed prose about the design and usage of the library while @secref{lr} provides a consise reference to all functions exported by the different modules. Finally @secref{cb} shows examples on how to solve typical tasks with the functions provided by the library.

@table-of-contents[]
@section[#:tag "gs"]{Getting Started}

@subsection{Installation}

(harebrained scheme) is currently distributed as a @hyperlink["https://guix.gnu.org/"]{guix} package inside its source code repository.

@subsection{First steps}

First we will start a guix shell with the required packages to work in a chez-scheme environment:
@verbatim[]{
% guix shell -f guix.scm chez-scheme chez-srfi
% scheme
}

Inside chez-scheme we can then load the complete (harebrained scheme) package and start working:
@verbatim[]{
> (import (harebrained scheme))
> (bioseq->string (dna-reverse-complement (make-bioseq "ACTG")))
"CAGT"
}
@section[#:style '(toc) #:tag "ug"]{User Guide}
@local-table-of-contents[]
@subsection{Introduction}

I was fed up with some of the peculiarities of the R programming language at the same time that I started dipping my toes into the world of Scheme. The elegance of this language struck me. To be able for me to use it productively it would need to support scientific computing. So I started implementing libraries for bioinformatics, as I am most familiar with this field. I write this in the hope that it will get adopted and grow in popularity to the size of support scientific computing has in R or python. Surely this is a harebrained scheme!

Currently (harebrained scheme), as the library is called, contains procedures for bionformatics (in particular genomics). I plan to extend it with procudures for plotting.

@subsubsection{Supported schemes}
(harebrained scheme) is written in R6RS compliant scheme and requires only SRFI 43 support for vector operations not part of the standard. As such it should support most R6RS compliant Scheme implementations. It is currently tested on Chez, Racket (PLT scheme) and Guile. This should enable the user to choose the implementation most tailored to the target application.
R6RS was chosen in favour of the more recent R7RS mostly because it includes record types with single inheritance which (harebrained scheme) makes copious use of.

@subsection{Different use patterns}
(harbrained scheme) is supposed to be easy to use for explorative data analysis and at the same time also for use in writing safe and bug-free programs. These two uses are sometime in conflict and hence care was taken to make both reliable.

@subsection{Source code organization}

Naming of procedures follows scheme convention of prefixing procedure with the type e.g. @scheme[bioseq-map] and @scheme[biocol-map]. The following libraries are currently part of (harebrained scheme):

@itemlist[@item{(harebrained bio)}
          @item{(harebrained bio sequences)}
          @item{(harebrained bio collections)}
	  @item{(harebrained bio read)}
	  @item{(harebrained bio read fasta)}]

All libraries are documented in the @secref{lr}.

@subsection{Contributing}

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are *greatly appreciated*.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

@subsubsection{Coding style}

While R6RS introduces square brackets as alternatives to parens for increased legibility, we will not use this in the code. This is to make it easier to port to other schemes in the future.

General imports are declared before library imports. E.g. @scheme[(import (rnrs base) (harebrained bio sequences))] instead of @scheme[(import (harebrained bio sequences) (rnrs base))].
Public imports are listed before private imports.

Also imports should be as specific as possible @scheme[(import (rnrs io simple))] not @scheme[(import (rnrs))]. If only very few symbols are imported specify these using @scheme[(only (...) ... ...)] import declarations.

Do not use library versioning, support is spotty across implementations.
@subsection{License}

This code is distributed under the GNU General Public License v3 or later. See the file @code{LICENSE} in the source code repository for the complete license text. The test runner in (harebrained tests runner) is copyright by Mark Damon Hughes and licensed under the BSD License as found in the header of the file.

@section[#:style '(toc) #:tag "lr"]{Library Reference}

@local-table-of-contents[]

@subsection{(harebrained bio)}

These are libraries for bioinformatics/computational biology. @secref{bs} provides procedures dealing with biological sequences. @secref{bc} provides a general container format to be used throughout (harebrained bio). @secref{br} contains sublibraries to read common file formats in bioinformatics (e.g. FASTA).

The following graph shows the hierarchy of record types defined by (harebrained bio). The arrow denotes a "parent of" relationship of single heritance.
@image["/harebrained/doc/graph/record_hierarchy.png"]

@subsubsection[#:tag "bs"]{(harebrained bio sequences)}

@defthing[#:kind "record-type" <bioseq> bioseq? #:value (define-record-type <bioseq> (parent <named>))]{The record type to represent a biological sequence.}

@defthing[#:kind "record-type" <dna> dna? #:value (define-record-type <dna> (parent <bioseq>))]{A specialised record-type to represent DNA sequences. It is a child of @scheme[<bioseq>].}
@defthing[#:kind "record-type" <rna> rna? #:value (define-record-type <rna> (parent <bioseq>))]{A specialised record-type to represent RNA sequences. It is a child of @scheme[<bioseq>].}
@defthing[#:kind "record-type" <protein> protein? #:value (define-record-type <protein> (parent <bioseq>))]{A specialised record-type to represent amino acid sequences. It is a child of @scheme[<bioseq>].}

@defproc[(bioseq-length [bs bioseq?]) integer?]{Return the length of a @scheme[bioseq]}

@defproc[(bioseq-ref [bs bioseq?] [i integer?]) symbol?]{Return the symbol at position @scheme[i] of the @scheme[bioseq].}

@defproc[(bioseq->string [bs bioseq?]) string?]{Return the sequence represented by @scheme[bs] as a string.}

@defproc[(dna-complement [bs dna?]) dna?]{Return the complement of @scheme[bs].} 
@defproc[(bioseq-reverse [bs bioseq?]) bioseq?]{Return the reverse sequence of @scheme[bs]. } 
@defproc[(dna-reverse-complement [bs dna?]) dna?]{Return the reverse complement of @scheme[bs]. } 

@defproc[(bioseq-subsequence [bs bioseq?] [i integer?] [j integer?]) bioseq?]{Return the subsequence of @scheme[bs] from @scheme[i] (included) to @scheme[j] (excluded). Indices are 0 based.} 

@defproc[(dna->rna [dna dna?]) rna?]{Transcribe a DNA sequence into RNA by substituting all T nucleotides with U. Returns a bioseq of type @scheme[<rna>].}
@defproc[(rna->dna [dna rna?]) dna?]{Transcribe a RNA sequence into DNA by substituting all U nucleotides with T. Returns a bioseq of type @scheme[<dna>].}

@defproc[(bioseq-counts [bs bioseq?]) hashtable?]{Return a hashtable mapping the counts of each distinct symbol of the sequence.}
@defproc[(bioseq-rename [bs bioseq?] [name string?]) bioseq?]{Return a bioseq of same type with name @scheme[name].}

@subsubsection[#:tag "bc"]{(harebrained bio collections)}

@defthing[#:kind "record-type" <biocol> biocol? #:value (define-record-type <biocol> (parent <named>))]{A biocollection (short biocol) is a container data structure, that allows access by numeric index as well as string based index. As such it is both a sequence of values as well as a hash. A biocol maintains the insertion order of its elements. It is design to contain instances of @scheme[<named>] types, however this is not a requirement. Procedures that treat a @scheme[<biocol>] like a hash are listed in @secref{hash-based} and procedures that treat a @scheme[<biocol>] like a sequence are listed in @secref{seq-based} below.}

@defproc[(make-biocol [name string?] [values (or/c list? vector?)] [names (or/c (list-of string?) (vector-of string?)) (map name values)]) biocol?]{Procedure to create a @scheme[<biocol>] instance. The first argument is the name of the resulting instance. @scheme[values] is either a list or vector of objects to be inserted into the collection. The optional @scheme[names] argument is a list or vector of strings. If it is omitted, then we assume @scheme[values] only contain elements of type @scheme[<named>] and the name will be automatically extracted by applying the procedure @scheme[name] on each element.}

@defproc[(biocol-name [bc biocol?]) string?]{Return the name of a @scheme[<biocol>].}
@defproc[(biocol-rename [bc biocol?] [name string?]) biocol?]{Return a new @scheme[<biocol>] with name @scheme[name].}
@defproc[(biocol-copy [bc biocol?]) biocol?]{Return a deep copy of @scheme[bc]. @codeblock{(eq? bc (biocol-copy bc))} should return false for every biocol @scheme[bc].}
@defproc[(biocol-ref [bc biocol?] [index (or/c integer? string?)] [default thunk? (lambda() (error 'biocol-ref "key not found" index))]) any?]{Retrieve the value at index @scheme[index]. @scheme[index] can be a numeric index into the sequence of values or a string key within the association.}

@subsubsub*section[#:tag "hash-based"]{Hash based procedures}

@defproc[(biocol-contains? [bc biocol?] [index string?]) boolean?]{Returns @scheme[#t] if biocol @scheme[bc] contains the key @scheme[index] and @scheme[#f] otherwise.}

@defproc[(biocol-set [bc biocol?] [key string?] [val any?]) biocol?]{Either add a new association between @scheme[key] and @scheme[val] to the hash (and append val to the sequence) or set the value at @scheme[key] to a new value (and update the object in the sequence).}

@subsubsub*section[#:tag "seq-based"]{Sequence based procedures}

@defproc[(biocol-length [bc biocol?]) integer?]{Return the length of biocol @scheme[bc] i.e. the number of elements in biocol @scheme[bc].}

@subsubsection[#:tag "br"]{(harebrained bio read)}
The set of libraries under @scheme[(harebrained bio read)] collect procedures to read common biological file formats.

@subsubsub*section{(harebrained bio read fasta)}
@defproc[(read-fasta [file (or/c port? string?)]) (or/c bioseq? biocol?)]{Read a file in FASTA format. The @scheme[file] argument can either be a path to a file, or a textual input port or a binary input port (as from a gzip connection) in which case it is assumed to be UTF-8 encoded. If the file contains a single sequence, then a @scheme[bioseq] is returned. Else a @scheme[biocol] is returned. The names of each of the sequences parsed are the complete refline (i.e. everything after the '>' symbol).} 

@defproc[(make-bioseq [seq string?] [name string? ""]) bioseq?]{Create a @scheme[bioseq] from a string with name @scheme[name]. If @scheme[name] is omitted the empty string is used.}

@subsection[#:tag "private-bio"]{Private API}
The elements described in this section are not part of the public interface. They are used internally. However, for anyone wishing to extend (harebrained scheme) these procedures are documented in this section.
This interface is also considered unstable until release v1.0. 

@subsubsection{(harebrained bio private types)}

This library contains the record types at the top of the hierarchy. They are imported into all other libraries.

@defthing[#:kind "record-type" <bio> bio? #:value (define-record-type <bio> bio bio?)]{The top of the hierarchy of record types. It does not contain any fields and is used to identify all records that are part of (harebrained bio). The constructor is not exported from the library.}

@defthing[#:kind "record-type" <named> named? #:value (define-record-type <named> (parent <bio>) (fields (immutable name name)))]{@scheme[<named>] is a record type for all objects that naturally have a name. These are many in bioinformatics, e.g. genes, genomes and features. The constructor is not exported from the library. The name of any instance of @scheme[<name>] can be extracted with the @scheme[name] accessor function.}

@subsubsection{(harebrained bio read private utilities)}

This file contains some utilities functions that are useful when reading and parsing text file formats.
@defproc[(char->symbol [c char?]) symbol?]{Convert a character read via @scheme[read-char] to a symbol, hopefully somewhate efficiently by explicitely matching known biological characters.}

@defproc[(choose-alphabet [l (listof symbol?)]) (or/c dna rna protein bioseq)]{Procedure that returns the correct constructor for a bioseq given a list of symbols. It will infer whether @scheme[l] represents a DNA alphabet, RNA alphabet or amino acid alphabet.}

@section[#:tag "cb"]{Cookbook}
@local-table-of-contents[]

@subsection{How to parse a gzipped fasta file}

TODO
@section[#:tag "rn"]{Release notes}
List major changes and in particular backward breaking changes. Remember that the API might break anytime prior to the v1.0 release.

@subsection[#:style 'unnumbered]{v0.1}
Release (harebrained bio sequences), (harebrained bio read fasta) and a minimal interface to (harebrained bio collections).