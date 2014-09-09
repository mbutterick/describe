#lang racket/base

(require "main.rkt")

(printf "--- Using literals (double precision) ---~n")
(describe 0.1)
(describe 0.2)
(describe 0.3)
(describe 0.4)
(describe 0.5)
(describe 0.6)
(describe 0.7)
(describe 0.8)
(describe 0.9)
(describe 1.0)

(printf "--- Using summation (double precision) ---~n")
(for/fold ((sum 0.0))
          ((i (in-range 10)))
  (define new-sum (+ sum 0.1))
  (describe new-sum)
  new-sum)

(printf "--- Using product (double precision) ---~n")
(for ((i (in-range 1 11)))
  (describe (* i 0.1)))
