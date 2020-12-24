#lang racket/base
;;; describe-test.rkt
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

(require racket/mpair
         "main.rkt")

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
(describe (* (! 10) 1.0))
(describe 6.0221313e23)
(describe 6.0221313f23)
(describe (exact->inexact (! 40)))
(describe (sqrt 10))
;; no good in Racket CS, for whatever reason
;;(describe (sqrt -10))
;;(describe (+ (sqrt 10) (sqrt -10)))


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
