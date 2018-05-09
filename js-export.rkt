#lang racket

(require "js-base.rkt")

(provide js-export% js-export?)

(define (js-export? a)
  (is-a? a js-export%))

(define js-export%
  (class js-base%
    (super-new)

    (inherit get-name/safe)

    (define/override (compile)
      (format "var ~a" (get-name/safe)))))
