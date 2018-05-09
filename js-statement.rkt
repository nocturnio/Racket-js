#lang racket

(require "js-function.rkt")

(provide (all-defined-out))

(define (js-statement? a)
  (is-a? a js-statement%))

(define (js-statement name . params)
  (new js-statement% [name name] [params params]))

(define js-statement%
  (class js-function%
    (super-new)

    (inherit get-param-strings)
    (inherit get-name)

    (define/override (compile)
      (format "~a ~a" (get-name) (string-join (get-param-strings) " ")))))
