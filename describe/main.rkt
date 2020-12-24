#lang racket/base
;;; main.rkt
;;; Copyright (c) 2009-2010 M. Douglas Williams
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;
;;; -----------------------------------------------------------------------------
;;;
;;; This file provides four procedures: variant, integer->string, describe,
;;; and description.
;;;
;;; (variant x) -> symbol?
;;;   x : any/c
;;; Returns a symbol identifying the type of any object.
;;; Examples:
;;;   (variant (λ (x) x)) -> procedure
;;;   (variant 1) -> fixnum-integer
;;;   (variant (let/cc k k)) -> continuation
;;;   (variant (let/ec k k)) -> escape-continuation
;;;
;;; (integer->string n) -> string?
;;;   n : exact-integer?
;;; Returns a string with the name of the exact integer n. This works for
;;; integers whose magnitude is less than 10e102.
;;; Examples:
;;; >(integer->string 0)
;;; "zero"
;;; >(integer->string (expt 2 16))
;;; "sixty-five thousand five hundred and thirty-six"
;;; > (integer->string (expt 10 100))
;;; "ten duotrigillion"
;;; > (integer->string (expt 10 150))
;;; "at least 10^102"
;;;
;;; (describe x) -> void?
;;;   x : any/c
;;; Prints a description of x to the current output port.
;;; Examples:
;;; >(describe (sqrt 10))
;;; 3.1622776601683795 is an inexact positive real number
;;; >(describe (sqrt -10))
;;; 0+3.1622776601683795i is an inexact positive imaginary number
;;; >(describe #\a)
;;; #\a is the character whose code-point number is 97(#x61) and general category is 'll (letter, lowercase)
;;; >(describe '(this is a proper list))
;;; (this is a proper list) is a proper immutable list of length 5
;;; >(describe car)
;;; #<procedure:car> is a primitive procedure named car that accepts 1 argument and returns 1 result
;;;
;;; (description x) -> string?
;;;   x : any/c
;;; Returns a string describing the object, x.
;;;
;;; -----------------------------------------------------------------------------
;;;
;;; Version  Date     Description
;;; 1.0.0    11/10/09 Initial Release to PLaneT (MDW)
;;; 2.0.0    10/27/10 Updated to Racket. (MDW)
;;; 2.0.1    08/26/13 Added exact decimal value for floats. (MDW)
;;; 2.0.1    09/26/13 Added bigfloat support to float->string. (MDW)

(require racket/contract/base
         racket/math
         racket/mpair)

;;; (variant x) -> symbol
;;;   x : any/c
;;; Returns a symbol identifying the type of any object. This is from a post on
;;; The PLT Scheme mailing list from Robby Findler. The following is a short
;;; explanation of its origin:
;;; I'm not sure about always, but at some point a while ago, Matthew
;;; decided that all values are structs (in the sense that you could have
;;; implemented everything with structs and scope, etc even if some of
;;; them are implemented in C) and adapted the primitives to make them
;;; behave accordingly.
;;; Examples:
;;;   (variant (λ (x) x)) -> procedure
;;;   (variant 1) -> fixnum-integer
;;;   (variant (let/cc k k)) -> continuation
;;;   (variant (let/ec k k)) -> escape-continuation
(define (variant x)
 (string->symbol
  (regexp-replace #rx"^struct:"
                  (symbol->string (vector-ref (struct->vector x) 0))
                  "")))

;;; (imaginary? z) -> boolean?
;;;   z : any/c
;;; Returns #t if z is an imaginary number. An imaginary number is a complex
;;; number whose real part is exactly zero and whose imaginary part is not
;;; zero.
(define (imaginary? z)
  (and (complex? z)
       (let ((zr (real-part z)))
         (and (exact? zr) (zero? zr)))
       ;(let ((zi (imag-part z)))
       ;  (not (and (exact? zi) (zero? zi))))
       ))

;;; (boolean-description bool) -> string?
;;;   bool : boolean?
;;; Returns a string describing the boolean, bool.
(define (boolean-description bool)
  (format "~s is a Boolean ~a"
          bool (if bool "true" "false")))

;;; small-integer-names : (vectorof string?)
;;; A vector of the names of the integers less than 20.
(define small-integer-names
  #("zero" ; not used
    "one"
    "two"
    "three"
    "four"
    "five"
    "six"
    "seven"
    "eight"
    "nine"
    "ten"
    "eleven"
    "twelve"
    "thirteen"
    "fourteen"
    "fifteen"
    "sixteen"
    "seventeen"
    "eighteen"
    "nineteen"))

;;; (integer-0-19->string n) -> string?
;;;   n : (and/c exact? (integer-in 0 19))
;;; Returns a string with the name of the number n, which must be between
;;; 0 and 19 (i.e., less than 20).
(define (integer-0-19->string n)
  (vector-ref small-integer-names n))

;;; decade-names : (vectorof string?)
;;; The names of the multiples of ten that are less than 100.
(define decade-names
  #("zero" ; not used
    "ten"
    "twenty"
    "thirty"
    "forty"
    "fifty"
    "sixty"
    "seventy"
    "eighty"
    "ninety"))

;;; (integer-0-99->string n) -> string?
;;;   n : (and/c exact? (integer-in 0 99))
;;; Returns a string with the name of the integer n, which must be between
;;; 0 and 99 (i.e., less than 100).
(define (integer-0-99->string n)
  (if (< n 20)
      (integer-0-19->string n)
      (let-values (((q10 r10) (quotient/remainder n 10)))
        (if (= r10 0)
            (vector-ref decade-names q10)
            (string-append (vector-ref decade-names q10)
                           "-"
                           (vector-ref small-integer-names r10))))))

;;; (integer-0-999->string n include-and?) -> string?
;;;   n : (and/c exact? (integer-in 0 999))
;;;   include-and? : boolean? = #f
;;; Returns a string with the name of the integer n, which must be between
;;; 0 and 999 (i.e., less than 1000). If include-and? is true, the British
;;; convention of including and after the hundreds is used.
(define (integer-0-999->string n (include-and? #f))
  (if (< n 100)
      (integer-0-99->string n)
      (let-values (((q100 r100) (quotient/remainder n 100)))
        (string-append (vector-ref small-integer-names q100)
                       " hundred"
                       (if (= r100 0)
                           ""
                           (string-append (if include-and? " and " " ")
                                          (integer-0-99->string r100)))))))

;;; thousands-names : (vectorof string?)
;;; The names of powers of a thousand up to 10^99, so they can be used for
;;; integers less than 10^102.
(define thousands-names
  #("zero" ; not used
    "thousand"
    "million"
    "billion"
    "trillion"
    "quadrillion"
    "quintillion"
    "sextillion"
    "septillion"
    "octillion"
    "nonillion"
    "decillion"
    "undecillion"
    "duodecillion"
    "tredecillion"
    "quattuordecillion"
    "quindecillion"
    "sexdecillion"
    "septemdecillion"
    "octdecillion"
    "novemdecillion"
    "vigintillion"
    "unvigintillion"
    "duovigintillion"
    "tresvigintillion"
    "quattuorvigintillion"
    "quinquavigintillion"
    "sesvigintillion"
    "septenviginitillion"
    "octovigintillion"
    "novemvigintillion"
    "trigintillion"
    "untrigillion"
    "duotrigillion"))

;;; max-integer->string : exact-positive-integer? = (expt 10 102)
;;; The limit for returning the name of an integer.
(define max-integer->string (expt 10 102))

;;; (integer->string n) -> string?
;;;   n : exact-integer?
;;; Returns a string with the name of the exact integer n. This works for
;;; integers whose magnitude is less than 10e102.
(define (integer->string n)
  (cond ((zero? n)
         "zero")
        ((negative? n)
         (string-append "minus " (integer->string (abs n))))
        ((< n 1000)
         (integer-0-999->string n #t))
        ((< n max-integer->string)
         (let/ec exit
           (let loop ((str "")
                      (thousand-power 0)
                      (n n))
             (if (= n 0)
                 (exit str)
                 (let-values (((q1000 r1000) (quotient/remainder n 1000)))
                   (loop (if (= thousand-power 0)
                             (if (= r1000 0)
                                 ""
                                 (if (< r1000 20)
                                     (string-append "and "
                                                    (integer-0-19->string r1000))
                                     (integer-0-999->string r1000 #t)))
                             (if (= r1000 0)
                                 str
                                 (string-append (integer-0-999->string r1000)
                                                " "
                                                (vector-ref thousands-names thousand-power)
                                                (if (> (string-length str) 0) " " "")
                                                str)))
                         (+ thousand-power 1)
                         q1000))))))
        (else
         "at least 10^102")))

;;; (exact-number-description z) -=> string?
;;;   z : (and/c number? exact?)
;;; Returns a string describing the exact number, z.
(define (exact-number-description z)
  (cond ((fixnum? z)
         (if (zero? z)
             (format "~a is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) zero" z)
             (if (byte? z)
                 (format "~s is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) ~a"
                     z (integer->string z))
                 (format "~s is an exact ~a integer fixnum ~a"
                         z (if (negative? z) "negative" "positive")
                         (integer->string z)))))
        ((and (integer? z) (< z max-integer->string))
         (format "~s is an exact ~a integer ~a"
                 z (if (negative? z) "negative" "positive")
                 (integer->string z)))
        ((integer? z)
         (format "~s is an exact ~a integer value whose absolute value is >= 10^102"
                 z (if (negative? z) "negative" "positive")))
        ((rational? z)
         (format "~s is an exact ~a rational number with a numerator of ~a and a denominator of ~a"
                 z (if (negative? z) "negative" "positive")
                 (numerator z) (denominator z)))
        ((imaginary? z)
         (format "~s is an exact ~a imaginary number"
                 z (if (negative? (imag-part z)) "negative" "positive")))
        ((complex? z)
         (format "~s is an exact complex number whose real part is ~a and whose imaginary part is 0+~ai"
                 z (real-part z) (imag-part z)))
        (else
         (format "~s is an exact number" z))))

;;; (float->string x) -> string?
;;;   x : (or/c flonum? single-flonum? bigfloat?)
;;; Returns a string with the exact decimal representation of x. This is only
;;; guaranteed for floats - single, double, or extended precision, which are
;;; never repeating decimals.
(define (float->string x)
  (define (int->string int)
    (if (= int 0)
        "0"
        (let loop ((str "")
                   (n int))
          (cond ((= n 0)
                 str)
                (else
                 (define-values (q r) (quotient/remainder n 10))
                 (loop (string-append (number->string r) str) q))))))
  (define (frac->string frac)
    (if (= frac 0)
        ".0"
        (let loop ((str ".")
                   (f frac))
          (cond ((= f 0)
                 str)
                (else
                 (define ten-f (* f 10))
                 (define ten-f-int (truncate ten-f))
                 (define ten-f-frac (- ten-f ten-f-int))
                 (loop (string-append str (number->string ten-f-int)) ten-f-frac))))))
  ;(define sign (sgn x))
  ;(define sign (if (extflonum? x)
  ;                 (cond ((extfl< x 0.0t0) -1.0)
  ;                       ((extfl> x 0.0t0) +1.0)
  ;                       (else 0.0))
  ;                 (sgn x)))
  (define sign (cond ((extflonum? x)
                      (cond ((extfl< x 0.0t0) -1.0)
                            ((extfl> x 0.0t0) +1.0)
                            (else 0.0)))
                     (else
                      (sgn x))))
  ;(define exact-x (abs (inexact->exact x)))
  ;(define exact-x (if (extflonum? x)
  ;                    (abs (extfl->exact x))
  ;                    (abs (inexact->exact x))))
  (define exact-x (cond ((extflonum? x) (abs (extfl->exact x)))
                        (else (inexact->exact x))))
  (define int (truncate exact-x))
  (define frac (- exact-x int))
  (string-append
   (if (= sign -1) "-" "")
   (int->string int)
   (frac->string frac)))

;;; (inexact-number-description z) -> string?
;;;   z : (and/c number? inexact?)
;;; Returns a string describing the inexact number, z.
(define (inexact-number-description z)
  (cond ((integer? z)
         (if (zero? z)
             (format "~a is an inexact integer zero" z)
             (format "~s is an inexact ~a integer whose exact decimal value is ~a"
                     z (if (negative? z) "negative" "positive")
                     (float->string z))))
        ((real? z)
         (format "~s is an inexact ~a real number whose exact decimal value is ~a"
                 z (if (negative? z) "negative" "positive")
                 (float->string z)))
        ((imaginary? z)
         (format "~s is an inexact ~a imaginary number whose exact decimal value is 0+~ai"
                 z (if (negative? (imag-part z)) "negative" "positive")
                 (float->string (imag-part z))))
        ((complex? z)
         (format "~s is an inexact complex number whose real part ~a and whose imaginary part ~a"
                 z (description (real-part z))
                 (description (make-rectangular 0 (imag-part z)))))
        (else
         (format "~s is an inexact number whose exact decimal value is ~a"
                 z (float->string z)))))

;;; (number-description z) -> string?
;;;   z : number?
;;; Returns a string describing the number, z. It handles infinities and
;;; not-a-number directly and dispatches to handle exact or inexact numbers.
(define (number-description z)
  (cond ((eqv? z +inf.0)
         (format "~s is positive infinity" z))
        ((eqv? z -inf.0)
         (format "~s is negative infinity" z))
        ((eqv? z +nan.0)
         (format "~s is not-a-number" z))
        ((exact? z)
         (exact-number-description z))
        ((inexact? z)
         (inexact-number-description z))
        (else
         (format "~s is a number" z))))


;;; 201223 Racket CS update
;;; Racket CS does not support extflonums
;;; so we remove racket/extflonum from dependencies
;;; and make the extflonum functions into no-ops
(define (extflonum? x) #false)
(define (extfl< . xs) #false)
(define (extfl> . xs) #false)
(define (extfl->exact x) 0)

;;; (extflonum-description x) -> string
;;;   x : extflonum?
;;; Returns a string describing the extended precision floating point number, x.
(define (extflonum-description x)
  (cond ((eqv? x +inf.t)
         (format "~s is positive infinity" x))
        ((eqv? x -inf.t)
         (format "~s is negative infinity" x))
        ((eqv? x +nan.t)
         (format "~s is not-a-number" x))
        (else
         (format "~s is an extended precision (80-bit) floating point number whose exact decimal value is ~a"
                 x (float->string x)))))


;;; (string-description str) -> string?
;;;   str : string?
;;; Returns a string describing the string, str.
(define (string-description str)
  (let ((len (string-length str)))
    (if (= len 0)
        (format "~s is an empty string" str)
        (format "~s is ~a string of length ~a"
                str (if (immutable? str) "an immutable" "a mutable") len))))

;;; (byte-string-description bstr) -> string?
;;;   bstr : string?
;;; Returns a string describing the string, bstr.
(define (byte-string-description bstr)
  (let ((len (bytes-length bstr)))
    (if (= len 0)
        (format "~s is an empty byte string" bstr)
        (format "~s is ~a byte string of length ~a"
                bstr (if (immutable? bstr) "an immutable" "a mutable") len))))

;;; general-category-alist : (list-of (cons/c symbol? string?))
;;; An association list mapping a Unicode general category (as returned by
;;; char-general-category) to a string describing it.
(define general-category-alist
  '((lu . "letter, uppercase")
    (ll . "letter, lowercase")
    (lt . "letter, titlecase")
    (lm . "letter, modifier")
    (lo . "letter, other")
    (mn . "mark, nonspacing")
    (mc . "mark, space combining")
    (me . "mark, enclosing")
    (nd . "number, decimal digit")
    (nl . "number, letter")
    (no . "number, other")
    (ps . "punctuation, open")
    (pe . "punctuation, close")
    (pi . "punctuation, initial quote")
    (pf . "punctuation, final quote")
    (pd . "punctuation, dash")
    (pc . "punctuation, connector")
    (po . "punctuation, other")
    (sc . "symbol, currency")
    (sm . "symbol, math")
    (sk . "symbol, modifier")
    (so . "symbol, other")
    (zs . "separator, space")
    (zp . "separator, paragraph")
    (zl . "separator, line")
    (cc . "other, control")
    (cf . "other, format")
    (cs . "other, surrogate")
    (co . "other, private use")
    (cn . "other, not assigned")))

;;; (general-category->string category) -> string?
;;;   category : symbol?
;;; Returns a string with the definition of Unicode general category, category,
;;; or "unknown" is category is not known.
(define (general-category->string category)
  (let ((category-assoc (assq category general-category-alist)))
    (if category-assoc
        (cdr category-assoc)
        "unknown")))

;;; (character-description char) -> string?
;;;   char : character?
;;; Returns a string describing the character, char.
(define (character-description char)
  (let ((code-point (char->integer char))
        (general-category (char-general-category char)))
    (format "~s is a character whose code-point number is ~a(#x~x) and general category is '~a (~a)"
            char code-point code-point
            general-category (general-category->string general-category))))

;;; symbol-description sym) -> string?
;;;   sym : symbol?
;;; Returns a string describing the symbol, sym.
(define (symbol-description sym)
  (format "~s is ~a symbol"
          sym (if (symbol-interned? sym) "an interned" "an uninterned")))

;;; (regexp-description regexp) -> string?
;;;   regexp : regexp?
;;; Returns a string describinbg the regular expression, regexp.
(define (regexp-description regexp)
  (format "~s is a regular expression in ~a format"
          regexp (if (pregexp? regexp) "pregexp" "regexp")))

;;; (byte-regexp-description byte-regexp) -> string?
;;;   byte-regexp : buteregexp?
;;; Returns a string describing the byte regular expression, byte-regexp.
(define (byte-regexp-description byte-regexp)
  (format "~s is a byte regular expression in ~a format"
          byte-regexp (if (byte-pregexp? byte-regexp) "pregexp" "regexp")))

;;; (keyword-description kw) -> string?
;;;   kw : keyword?
;;; Returns a string describing the keyword, kw.
(define (keyword-description kw)
  (format "~s is a keyword" kw))

;;; (list-description lst) -> string?
;;;   lst : list?
;;; Returns a string describing the proper immutable list, lst.
(define (list-description lst)
  (if (null? lst)
      (format "~s is an empty list" lst)
      (format "~s is a proper immutable list of length ~a"
              lst (length lst))))

;;; (pair-desc pair) -> string?
;;;   pair : pair?
;;; Returns a string describing the improper immutable list, pair. Any pair that
;;; is not a proper list is an improper list.
(define (pair-description pair)
  (format "~a is an improper immutable list" pair))

;;; (mlist-description mlst) -> string?
;;;   mlst : mlist?
;;; Returns a string describing the proper mutable list, mlst.
(define (mlist-description mlst)
  (format "~s is a proper mutable list of length ~a"
          mlst (mlength mlst)))

;;; (mpair-desc mpair) -> string?
;;;   mpair : mpair?
;;; Returns a string describing the improper mutable list, mpair. Any mpair that
;;; is not a proper mlist is an improper mlist.
(define (mpair-description mpair)
  (format "~a is an improper mutable list" mpair))

;;; (vector-description v) -> string?
;;;   v : vector?
;;; Returns a string describing the vector, v.
(define (vector-description v)
  (let ((len (vector-length v)))
    (if (= len 0)
        (format "~s is an empty vector" v)
        (format "~s is ~a vector of length ~a"
                v (if (immutable? v) "an immutable" "a mutable") len))))

;;; (box-description box) -> string?
;;;   box : box?
;;; Returns a string describing the boxed value, box, and its contents.
(define (box-description box)
  (format "~s is a box containing ~s, ~a"
          box (unbox box) (description (unbox box))))

;;; (weak-box-description weak-box) -> string?
;;;   weak-box : weak-box?
;;; Returns a string describing the weak-box value, weak-box, and its contents.
(define (weak-box-description weak-box)
  (format "~s is a weak box containing ~s, ~a"
          weak-box (weak-box-value weak-box) (description (weak-box-value weak-box))))

;;; (ephemeron-description eph) -> string?
;;;   eph : box?
;;; Returns a string describing the ephemeron value, eph, and its contents.
(define (ephemeron-description eph)
  (format "~s is an ephemeron containing ~s, ~a"
          eph (ephemeron-value eph) (description (ephemeron-value eph))))

;;; (hash-description hash) -> string?
;;;   hash : hash?
;;; Returns a string describing the hash table, hash.
(define (hash-description hash)
  (if (= (hash-count hash) 0)
      (let ((type (if (hash-weak? hash)
                      "an empty mutable hash table that holds its keys weakly"
                      (if (immutable? hash)
                          "an empty immutable hash table"
                          "a empty mutable hash table")))
            (compare (if (hash-eq? hash)
                         "eq?"
                         (if (hash-eqv? hash)
                             "eqv?"
                             "equal?"))))
        (format "~s is ~a and that uses ~a to compare keys"
                hash type compare))
      (let ((type (if (hash-weak? hash)
                      "a mutable hash table that holds its keys weakly"
                      (if (immutable? hash)
                          "an immutable hash table"
                          "a mutable hash table")))
            (compare (if (hash-eq? hash)
                         "eq?"
                         (if (hash-eqv? hash)
                             "eqv?"
                             "equal?"))))
        (format "~s is ~a and that uses ~a to compare keys~a"
                hash type compare
                (for/fold ((key-text ""))
                          (((key value) (in-hash hash)))
                  (string-append key-text
                                 (format "~n  ~s : ~s, ~a"
                                         key value (description value))))))))

;;; (arity->string arity) -> string?
;;;   arity : (or/c exact-nonnegative-integer?
;;;                 arity-at-least?
;;;                 (list-of (or/c exact-nonnegative-integer?
;;;                                arity-at-least?)))
;;; Returns a string describing the arity of a function as returned by
;;; procedure-arity.
(define (arity->string arity)
  (cond ((integer? arity)
         (number->string arity))
        ((arity-at-least? arity)
         (format "at least ~a" (arity-at-least-value arity)))
        (else
         (let loop ((str "")
                    (tail arity))
           (let ((arity (car tail)))
             (if (null? (cdr tail))
                 (string-append str " or " (arity->string arity))
                 (loop (string-append str
                                      (if (> (string-length str) 0) ", " "")
                                      (arity->string arity))
                       (cdr tail))))))))

;;; (keyword-list->string kw-lst) -> string?
;;;   kw-lst : (list-of keyword?)
;;; Returns a string with the keywords from the keyword list, kw-lst.
(define (keyword-list->string kw-lst)
  (cond ((= (length kw-lst) 0)
         "")
        ((= (length kw-lst) 1)
         (string-append "#:" (keyword->string (car kw-lst))))
        (else
         (let/ec exit
           (let loop ((str "")
                      (tail kw-lst))
             (if (null? (cdr tail))
                 (exit (string-append str
                                      " and "
                                      "#:" (keyword->string (car tail))))
                 (loop (string-append str
                                      (if (> (string-length str) 0) ", " "")
                                      "#:" (keyword->string (car tail)))
                       (cdr tail))))))))

;;; (procedure-arguments->string proc) -> string?
;;;   proc : procedure?
;;; Returns a string describing the arguments of the procedure, proc.
(define (procedure-arguments->string proc)
  (let ((arity (procedure-arity proc)))
    (let-values (((required accepted) (procedure-keywords proc)))
      (format "accepts ~a ~a~a~a"
              (arity->string arity) (if (eqv? arity 1) "argument" "arguments")
              (if (null? required)
                  ""
                  (format " with keyword ~a ~a"
                          (if (= (length required) 1) "argument" "arguments")
                          (keyword-list->string required)))
              (if (null? accepted)
                  ""
                  (format " plus optional keyword ~a ~a"
                          (if (= (length accepted) 1) "argument" "arguments")
                          (keyword-list->string accepted)))))))

;;; (primitive-results->string prim) -> string
;;;   prim : primitive?
;;; Returns a string describing the results of the primitive procedure, prim.
(define (primitive-results->string prim)
  (let ((arity (primitive-result-arity prim)))
    (format "returns ~a ~a"
            (arity->string arity) (if (eqv? arity 1) "result" "results"))))

;;; (procedure-description proc) -> string?
;;;   proc : procedure?
;;; Returns a string describing the procedure, proc.
(define (procedure-description proc)
  (cond ((primitive? proc)
         (let ((result-arity (procedure-arity proc)))
           (format "~s is a primitive procedure ~athat ~a and ~a"
                   proc
                   (let ((name (object-name proc)))
                     (if name
                         (string-append "named "
                                        (symbol->string name)
                                        " ")
                         ""))
                   (procedure-arguments->string proc)
                   (primitive-results->string proc))))
        ((primitive-closure? proc)
         (format "~s is a primitive closure ~athat ~a"
                 proc
                 (let ((name (object-name proc)))
                   (if name
                       (string-append "named "
                                      (symbol->string name))
                       ""))
                 (procedure-arguments->string proc)))
        (else
         (format "~s is a procedure ~athat ~a"
                 proc
                 (let ((name (object-name proc)))
                   (if name
                       (string-append "named "
                                      (symbol->string name)
                                      " ")
                       ""))
                 (procedure-arguments->string proc)))))

;;; (port-description port) -> string?
;;;   port : port?
;;; Returns a string describing the port, port.
(define (port-description port)
  (let ((direction (if (input-port? port)
                       (if (output-port? port)
                           "input-output"
                           "input")
                       (if (output-port? port)
                           "output"
                           "unknown"))))
    (format "~s is ~a ~a port"
            port (if (port-closed? port) "a closed" "an open")
            direction)))

(define (path-description path)
  (let ((convention (path-convention-type path)))
    (format "~s is ~a ~a ~a path"
            path
            (if (complete-path? path) "a complete," "an incomplete,")
            (if (absolute-path? path)
                "absolute"
                (if (relative-path? path)
                    "relative"
                    "unknown"))
            convention)))

;;; (structure-description struct) -> string
(define (structure-description struct)
  (let ((name (object-name struct)))
    (format "~s is a structure~a~a"
            struct
            (if name (format " of type ~a" name) "")
            (for/fold ((str ""))
                      ((field (in-vector (struct->vector struct)))
                       (i (in-naturals)))
              (cond ((= i 0)
                     "")
                    ((eq? field '...)
                     (string-append str (format "~n  ...")))
                    (else
                     (string-append str (format "~n  ~a : ~a, ~a"
                                                i field (description field)))))))))

;;; (description x) -> string
;;;   x : any/c
;;; Returns a string describing x.
(define (description x)
  (cond ((boolean? x)
         (boolean-description x))
        ((number? x)
         (number-description x))
        ((extflonum? x)
         (extflonum-description x))
        ((string? x)
         (string-description x))
        ((bytes? x)
         (byte-string-description x))
        ((char? x)
         (character-description x))
        ((symbol? x)
         (symbol-description x))
        ((regexp? x)
         (regexp-description x))
        ((byte-regexp? x)
         (byte-regexp-description x))
        ((keyword? x)
         (keyword-description x))
        ((list? x)
         (list-description x))
        ((pair? x)
         (pair-description x))
        ((mlist? x)
         (mlist-description x))
        ((mpair? x)
         (mpair-description x))
        ((vector? x)
         (vector-description x))
        ((box? x)
         (box-description x))
        ((weak-box? x)
         (weak-box-description x))
        ((hash? x)
         (hash-description x))
        ((procedure? x)
         (procedure-description x))
        ((port? x)
         (port-description x))
        ((void? x)
         (format "~s is void" x))
        ((eof-object? x)
         (format "~s is an eof object" x))
        ((path? x)
         (path-description x))
        ((struct? x)
         (structure-description x))
        (else
         (let ((type (variant x))
               (name (object-name x)))
           (if (and object-name
                    (not (eq? type name)))
               (format "~s is an object of type ~a named ~a"
                       x type name)
               (format "~s is an object of type ~a"
                 x (variant x)))))))

;;; (describe x) -> void?
;;;   x : any/c
;;; Prints a description of x.
(define (describe x)
  (printf "~a~n" (description x)))

;;; Module Contracts

(provide/contract
 (variant
  (-> any/c symbol?))
 (integer->string
  (-> exact-integer? string?))
 (float->string
  (-> (or/c flonum? single-flonum?) string?))
 (description
  (-> any/c string?))
 (describe
  (-> any/c void?)))
