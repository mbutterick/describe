#lang setup/infotab
(define name "Describe")
(define collection "Describe")
(define blurb
  (list "This library provides routines to describe Racket objects."))
(define scribblings '(("describe.scrbl" ())))
(define categories '(io misc))
(define primary-file "describe.rkt")
(define release-notes
  (list "The function float->string is now exported. It was also extended "
        "to support big floats from the Math Library. Note that descriptions "
        "of big floats do not include the exact decimal value because of the "
        "possibility of extremely large value exhausting memory."))
(define repositories '("4.x"))
(define required-core-version "5.0")