#lang racket/base

(require "main.rkt")

(printf "--- Using literals (single precision) ---~n")
(describe 0.1s0)
(describe 0.2s0)
(describe 0.3s0)
(describe 0.4s0)
(describe 0.5s0)
(describe 0.6s0)
(describe 0.7s0)
(describe 0.8s0)
(describe 0.9s0)
(describe 1.0s0)

(printf "--- Using summation (single precision) ---~n")
(for/fold ((sum 0.0s0))
          ((i (in-range 10)))
  (define new-sum (+ sum 0.1s0))
  (describe new-sum)
  new-sum)

(printf "--- Using product (single precision) ---~n")
(for ((i (in-range 1 11)))
  (describe (* i 0.1s0)))
