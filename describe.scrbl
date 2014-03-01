#lang scribble/doc

@(require scribble/manual
          (planet williams/describe/describe)
          (for-label
           racket
           (planet williams/describe/describe)))

@title[#:tag "describe"]{Describe}

M. Douglas Williams

@(author+email @tt{M. Douglas Williams} "doug@cognidrome.org")

This library provides functions to describe Racket objects. Currently, the following types of objects are described:

@itemize{
  @item{Booleans}
  @item{Numbers}
  @item{Strings}
  @item{Byte Strings}
  @item{Characters}
  @item{Symbols}
  @item{Regular Expressions}
  @item{Byte Regular Expressions}
  @item{Keywords}
  @item{Lists and Pairs}
  @item{Mutable Lists and Pairs}
  @item{Vectors}
  @item{Boxes}
  @item{Weak Boxes}
  @item{Hash Tables}
  @item{Procedures}
  @item{Ports}
  @item{Void}
  @item{EOF}
  @item{Path}
  @item{Structures}
  @item{Other Named Things}
  @item{Other (Unnamed) Things}
  }

The describe library is available from the PLaneT repository.

@defmodule[(planet williams/describe/describe)]

@table-of-contents[]

@section{Interface}

The describe library provides the following functions:

@defproc[(variant (x any/c)) symbol?]{
Returns a symbol identifying the type of @scheme[x]. This is from a post on the Racket mailing list from Robby Findler. The following is a short description of its origin:

... I'm not sure about always, but at some point a while ago, Matthew decided that all values are structs (in the sense that you could have implemented everything with structs and scope, etc even if some of them are implemented in C) and adapted the primitives to make them behave accordingly.}

Examples:

@scheme[(variant (λ (x) x))] -> procedure

@scheme[(variant 1)] -> fixnum-integer

@scheme[(variant (let/cc k k))] -> continuation

@scheme[(variant (let/ec k k))] -> escape-continuation

@defproc[(integer->string (n exact-integer?)) string?]{
Returns a string with the name of the exact integer @scheme[n]. This works for exact integers whose magnitudes are less than 10^102. For values whose magnitudes are greater than or equal to 10^102, the string "at least 10^102" (or "minus at least 10^102") is returned.}

Examples:

@scheme[(integer->string 0)] -> "zero"

@scheme[(integer->string (expt 2 16))] -> "sixty-five thousand five hundred and thirty-six"

@scheme[(integer->string (expt 10 100))] -> "ten duotrigillion"

@scheme[(integer->string (expt 10 150))] -> "at least 10^102"

@defproc[(float->string (x (or/c flonum? single-flonum? extflonum? bigfloat?))) string?]{
Returns a string with the exact decimal value of the floating-point number @scheme[x]. This works for single precision, double precision, extended precision, and big floating-point values. Note that internally @scheme[x] is converted to an exact rational number as part of converting to a string and the following warning from the Arbitrary-Precision Floating-Point Numbers (Bigfloats) section in the Math Library is important.

@bold{Be careful with exact conversions.} Bigfloats with large exponents may not fit in memory as integers or exact rationals. Worse, they might fit, but have all your RAM and swap space for lunch.
}

Examples:

@scheme[(float->string 0.0)] -> "0.0"

@scheme[(float->string 1.0)] -> "1.0"

@scheme[(float->string 0.1s0)] -> "0.100000001490116119384765625"

@scheme[(float->string 0.1)] -> "0.1000000000000000055511151231257827021181583404541015625"

@scheme[(float->string 0.1t0)] -> "0.1000000000000000000013552527156068805425093160010874271392822265625"

@scheme[(float->string (bf 1/10))] -> "0.10000000000000000000000000000000000000007346839692639296924804603357639035486366659729825547009429698164240107871592044830322265625"

@defproc[(describe (x any/c)) void?]{
Prints a description of @scheme[x] to the current output port.}

Examples:
@scheme[(describe (sqrt 10))] @linebreak[]
@schemefont{3.1622776601683795 is an inexact positive real number}

@scheme[(describe (sqrt -10))] @linebreak[]
@schemefont{0+3.1622776601683795i is an inexact positive imaginary number}

@scheme[(describe #\a)] @linebreak[]
@schemefont{#\a is the character whose code-point number is 97(#x61) and general category is 'll (letter, lowercase)}

@scheme[(describe '(this is a proper list))] @linebreak[]
@schemefont{(this is a proper list) is a proper immutable list of length 5}

@scheme[(describe car)] @linebreak[]
@schemefont{#<procedure:car> is a primitive procedure named car that accepts 1 argument and returns 1 result}

@defproc[(description (x any/c)) string?]{
Returns a string describing @scheme[x].}

@section{Example}

The following example demonstrates the varions function of the describe library.

@#reader scribble/comment-reader
(schememod
racket

(require scheme/mpair)
(require (planet williams/describe/describe))

;;; Booleans
(printf "~n--- Booleans ---~n")
(describe #t)
(describe #f)

;;; Numbers
(printf "~n--- Numbers ---~n")

(define (! n)
  (if (= n 0)
      1
      (* n (! (sub1 n)))))

(describe +inf.0)
(describe -inf.0)
(describe +nan.0)

(describe 0)
(describe (! 10))
(describe (! 40))
(describe (- (! 40) (! 41)))
(describe (! 100))
(describe (/ (! 10) (add1 (! 11))))
(describe -1+3i)

(describe 0.0)
(describe 0.1e0)
(describe 0.1f0)
(describe 0.1t0)
(describe (* (! 10) 1.0))
(describe 6.0221313e23)
(describe 6.0221313f23)
(describe 6.0221313t23)
(describe (exact->inexact (! 40)))
(describe (sqrt 10))
(describe (sqrt -10))
(describe (+ (sqrt 10) (sqrt -10)))

(describe (bf 1/10))
(describe (bf "15e200000000"))

;;; Strings

(printf "~n--- Strings ---~n")
(describe "abc")
(describe (string #\1 #\2 #\3))

;;; Byte Strings

(printf "~n--- Byte Strings ---~n")
(describe #"abc")
(describe (bytes 48 49 50))

;;; Characters

(printf "~n--- Characters ---~n")
(describe #\a)
(describe #\A)
(describe #\0)
(describe #\()

;;; Symbols

(printf "~n--- Symbols ---~n")
(describe 'abc)
(describe '|(a + b)|)
(describe (gensym))

;;; Regular Expressions

(printf "~n--- Regular Expressions ---~n")
(describe #rx"Ap*le")
(describe #px"Ap*le")

;;; Byte Regular Expressions

(printf "~n--- Byte Regular Expressions ---~n")
(describe #rx#"Ap*le")
(describe #px#"Ap*le")

;;; Keywords

(printf "~n--- Keywords ---~n")
(describe '#:key)

;;; Lists and Pairs

(printf "~n--- Lists and Pairs ---~n")
(describe '(this is a proper list))
(describe '(this is an improper . list))
(describe (list '(this . is) '(also . a) '(proper . list)))

;;; Mutable Lists and Pairs

(printf "~n--- Mutable Lists and Pairs ---~n")
(describe (mlist 'this 'is 'a 'proper 'list))
(describe (mcons 'this (mcons 'is (mcons 'an (mcons 'improper 'list)))))
(describe (mlist '(this . is) '(also . a) '(proper . list)))

;;; Vectors

(printf "~n--- Vectors ---~n")
(describe #(1 2 3))

;;; Boxes

(printf "~n--- Boxes ---~n")
(describe (box 12))
(describe (box (box 'a)))
(describe (box (sqrt 10)))

;;; Weak Boxes

(printf "~n--- Weak Boxes ---~n")
(describe (make-weak-box 12))
(describe (make-weak-box (make-weak-box 'a)))
(describe (make-weak-box (sqrt 10)))

;;; Hashes

(printf "~n--- Hashes ---~n")
(describe #hash((a . 12) (b . 14) (c . 16)))
(describe #hasheq((a . a) (b . b) (c . c)))
(describe #hasheqv((a . #\a) (b . #\b) (c . #\c)))

(define ht (make-hash))
(hash-set! ht 'a 12)
(hash-set! ht 'b 14)
(hash-set! ht 'c 16)
(describe ht)

(define wht (make-weak-hash))
(hash-set! wht 'a 12)
(hash-set! wht 'b 14)
(hash-set! wht 'c 16)
(describe wht)

;;; Procedures

(printf "~n--- Procedures ---~n")
(describe car)
(describe open-output-file)
(describe current-input-port)
(describe (lambda (x) x))

;;; Ports

(printf "~n--- Ports ---~n")
(describe (current-input-port))
(describe (current-output-port))

;;; Void

(printf "~n--- Void ---~n")
(describe (void))

;;; EOF

(printf "~n--- EOF ---~n")
(describe eof)

;;; Paths

(printf "~n--- Paths ---~n")
(describe (string->path "C:\\Program-files\\PLT"))
(describe (string->path "../dir/file.ext"))

;;; Structures

(printf "~n--- Structures ---~n")
(define-struct transparent-struct (a b c) #:transparent)
(define ts-1 (make-transparent-struct 'a 'b 'c))
(describe ts-1)

;;; Other Named Things (I.E., Opaque Structures)

(printf "~n--- Other Named Things ---~n")
(define-struct opaque-struct (a b c))
(define os-1 (make-opaque-struct 'a 'b 'c))
(describe os-1)
)

Produces the following output.

@verbatim{

--- Booleans ---
#t is a Boolean true
#f is a Boolean false

--- Numbers ---
+inf.0 is positive infinity
-inf.0 is negative infinity
+nan.0 is not-a-number
0 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) zero
3628800 is an exact positive integer fixnum three million six hundred twenty-eight thousand eight hundred
815915283247897734345611269596115894272000000000 is an exact positive integer eight hundred fifteen quattuordecillion nine hundred fifteen tredecillion two hundred eighty-three duodecillion two hundred forty-seven undecillion eight hundred ninety-seven decillion seven hundred thirty-four nonillion three hundred forty-five octillion six hundred eleven septillion two hundred sixty-nine sextillion five hundred ninety-six quintillion one hundred fifteen quadrillion eight hundred ninety-four trillion two hundred seventy-two billion
-32636611329915909373824450783844635770880000000000 is an exact negative integer minus thirty-two quindecillion six hundred thirty-six quattuordecillion six hundred eleven tredecillion three hundred twenty-nine duodecillion nine hundred fifteen undecillion nine hundred nine decillion three hundred seventy-three nonillion eight hundred twenty-four octillion four hundred fifty septillion seven hundred eighty-three sextillion eight hundred forty-four quintillion six hundred thirty-five quadrillion seven hundred seventy trillion eight hundred eighty billion
93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000 is an exact positive integer value whose absolute value is >= 10^102
3628800/39916801 is an exact positive rational number with a numerator of 3628800 and a denominator of 39916801
-1+3i is an exact complex number whose real part is -1 and whose imaginary part is 0+3i
0.0 is an inexact integer zero
0.1 is an inexact positive real number whose exact decimal value is .1000000000000000055511151231257827021181583404541015625
0.1f0 is an inexact positive real number whose exact decimal value is .100000001490116119384765625
0.1t0 is an extended precision (80-bit) floating point number whose exact decimal value is .1000000000000000000013552527156068805425093160010874271392822265625
3628800.0 is an inexact positive integer whose exact decimal value is 3628800.
6.0221313e+023 is an inexact positive integer whose exact decimal value is 602213130000000012517376.
6.0221313f+023 is an inexact positive integer whose exact decimal value is 602213127606262401335296.
6.0221313t+023 is an extended precision (80-bit) floating point number whose exact decimal value is 602213130000000000000000.
8.159152832478977e+047 is an inexact positive integer whose exact decimal value is 815915283247897683795548521301193790359984930816.
3.1622776601683795 is an inexact positive real number whose exact decimal value is 3.162277660168379522787063251598738133907318115234375
0+3.1622776601683795i is an inexact positive imaginary number whose exact decimal value is 0+3.162277660168379522787063251598738133907318115234375i
3.1622776601683795+3.1622776601683795i is an inexact complex number whose real part 3.1622776601683795 is an inexact positive real number whose exact decimal value is 3.162277660168379522787063251598738133907318115234375 and whose imaginary part 0+3.1622776601683795i is an inexact positive imaginary number whose exact decimal value is 0+3.162277660168379522787063251598738133907318115234375i
(bf #e0.1000000000000000000000000000000000000001) is a positive big float with 128 bits of precision
(bf "1.499999999999999999999999999999999999998e200000001") is a positive big float with 128 bits of precision

--- Strings ---
"abc" is an immutable string of length 3
"123" is a mutable string of length 3

--- Byte Strings ---
#"abc" is an immutable byte string of length 3
#"012" is a mutable byte string of length 3

--- Characters ---
#\a is a character whose code-point number is 97(#x61) and general category is 'll (letter, lowercase)
#\A is a character whose code-point number is 65(#x41) and general category is 'lu (letter, uppercase)
#\0 is a character whose code-point number is 48(#x30) and general category is 'nd (number, decimal digit)
#\( is a character whose code-point number is 40(#x28) and general category is 'ps (punctuation, open)

--- Symbols ---
abc is an interned symbol
|(a + b)| is an interned symbol
g1454 is an uninterned symbol

--- Regular Expressions ---
#rx"Ap*le" is a regular expression in regexp format
#px"Ap*le" is a regular expression in pregexp format

--- Byte Regular Expressions ---
#rx#"Ap*le" is a byte regular expression in regexp format
#px#"Ap*le" is a byte regular expression in pregexp format

--- Keywords ---
#:key is a keyword

--- Lists and Pairs ---
(this is a proper list) is a proper immutable list of length 5
(this is an improper . list) is an improper immutable list
((this . is) (also . a) (proper . list)) is a proper immutable list of length 3

--- Mutable Lists and Pairs ---
{this is a proper list} is a proper mutable list of length 5
{this is an improper . list} is an improper mutable list
{(this . is) (also . a) (proper . list)} is a proper mutable list of length 3

--- Vectors ---
#(1 2 3) is an immutable vector of length 3

--- Boxes ---
#&12 is a box containing 12, 12 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) twelve
#&#&a is a box containing #&a, #&a is a box containing a, a is an interned symbol
#&3.1622776601683795 is a box containing 3.1622776601683795, 3.1622776601683795 is an inexact positive real number whose exact decimal value is 3.162277660168379522787063251598738133907318115234375

--- Weak Boxes ---
#<weak-box> is a weak box containing 12, 12 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) twelve
#<weak-box> is a weak box containing #<weak-box>, #<weak-box> is a weak box containing a, a is an interned symbol
#<weak-box> is a weak box containing 3.1622776601683795, 3.1622776601683795 is an inexact positive real number whose exact decimal value is 3.162277660168379522787063251598738133907318115234375

--- Hashes ---
#hash((a . 12) (b . 14) (c . 16)) is an immutable hash table and that uses equal? to compare keys
  a : 12, 12 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) twelve
  b : 14, 14 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) fourteen
  c : 16, 16 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) sixteen
#hasheq((a . a) (b . b) (c . c)) is an immutable hash table and that uses eq? to compare keys
  a : a, a is an interned symbol
  b : b, b is an interned symbol
  c : c, c is an interned symbol
#hasheqv((a . #\a) (b . #\b) (c . #\c)) is an immutable hash table and that uses eqv? to compare keys
  a : #\a, #\a is a character whose code-point number is 97(#x61) and general category is 'll (letter, lowercase)
  b : #\b, #\b is a character whose code-point number is 98(#x62) and general category is 'll (letter, lowercase)
  c : #\c, #\c is a character whose code-point number is 99(#x63) and general category is 'll (letter, lowercase)
#hash((c . 16) (a . 12) (b . 14)) is a mutable hash table and that uses equal? to compare keys
  c : 16, 16 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) sixteen
  a : 12, 12 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) twelve
  b : 14, 14 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) fourteen
#<hash> is a mutable hash table that holds its keys weakly and that uses equal? to compare keys
  c : 16, 16 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) sixteen
  a : 12, 12 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) twelve
  b : 14, 14 is a byte (i.e., an exact positive integer fixnum between 0 and 255 inclusive) fourteen

--- Procedures ---
#<procedure:car> is a primitive procedure named car that accepts 1 argument and returns 1 result
#<procedure:open-output-file> is a procedure named open-output-file that accepts 1 argument plus optional keyword arguments #:exists and #:mode
#<procedure:current-input-port> is a primitive procedure named current-input-port that accepts 0 or 1 arguments and returns 1 result
#<procedure:...escribe-test.rkt:156:10> is a procedure named ...escribe-test.rkt:156:10 that accepts 1 argument

--- Ports ---
#<input-port:unsaved-editor326> is an open input port
#<output-port> is an open output port

--- Void ---
#<void> is void

--- EOF ---
#<eof> is an eof object

--- Paths ---
#<path:C:\Program-files\PLT> is a complete, absolute windows path
#<path:../dir/file.ext> is an incomplete, relative windows path

--- Structures ---
#(struct:transparent-struct a b c) is a structure of type transparent-struct
  1 : a, a is an interned symbol
  2 : b, b is an interned symbol
  3 : c, c is an interned symbol

--- Other Named Things ---
#<opaque-struct> is an object of type opaque-struct
}

@section{Issues and Comments}

There are undoubtably object types that I have missed and, since Racket is a language that is being actively developed, new object types are sometimes added. If you come across something that is missing, either send me an e-mail or post it on the Racket mailing list.

The @scheme[describe] function should probably have an optional or keyword argument to specify the output port.

It would be nice to come up with a way to allow developers to extend the describe library for new object types. Perhaps via something like a @schemefont{prop:custom-describe} structure type property.