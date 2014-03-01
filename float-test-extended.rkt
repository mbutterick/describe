#lang racket

(require racket/extflonum)
(require (planet williams/describe/describe))

(printf "--- Using literals (extended precision) ---~n")
(describe 0.1t0)
(describe 0.2t0)
(describe 0.3t0)
(describe 0.4t0)
(describe 0.5t0)
(describe 0.6t0)
(describe 0.7t0)
(describe 0.8t0)
(describe 0.9t0)
(describe 1.0t0)

(printf "--- Using summation (extended precision) ---~n")
(for/fold ((sum 0.0t0))
          ((i (in-range 10)))
  (define new-sum (extfl+ sum 0.1t0))
  (describe new-sum)
  new-sum)

(printf "--- Using product (single precision) ---~n")
(for ((i (in-range 1 11)))
  (describe (extfl* (->extfl i) 0.1t0)))
