#lang racket

(require "js-base.rkt")

(provide js-declaration% js-declaration? js-declaration)

(define (js-declaration name [value "___none___"])
  (new js-declaration% [name name] [value value]))

(define (js-declaration? a)
  (is-a? a js-declaration%))

(define/contract js-declaration%
  (class/c [compile (->m string?)]
           (init [value (or/c string? number? js-base?)]))

  (class js-base%
    (init value)

    (super-new)

    (define self-value value)

    (inherit get-name/safe)

    (define/public (get-value)
      self-value)

    (define/public (set-value: value)
      (set! self-value value))

    (define/override (compile)
      (define name (get-name/safe))
      (define clean-value (cleanse self-value))
      (define value-string
        (if (js-declaration? clean-value)
            (send clean-value get-name/safe)
            (send clean-value compile)))
      (if (string=? value-string "\"___none___\"")
          (format "var ~a" name)
          (format "var ~a=~a" name value-string)))))
