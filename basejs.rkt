#lang racket

(require "modulejs.rkt")

(provide basejs)

(module/js basejs

  (provide js-boolean?)
  (provide js-integer?)
  (provide js-display)
  (provide js-displayln)
  (provide js-number?)
  (provide js-procedure?)
  (provide js-error)
  (provide js-undefined?)
  (provide js-even?)
  (provide js-odd?)

  (define (js-undefined? v)
    (string=? (typeof v) "undefined"))

  (define (js-boolean? v)
    (string=? (typeof v) "boolean"))

  (define (js-integer? v)
    (equal? (parse-int v) v))

  (define (js-display datum)
    (send console log datum))

  (define (js-displayln datum)
    (send console log datum))

  (define (js-number? v)
    (string=? (typeof v) "number"))

  (define (js-procedure? v)
    (string=? (typeof v) "function"))

  (define (js-error e)
    (throw e)
    null)

  (define (js-even? v)
    (= (modulo v 2) 0))

  (define (js-odd? v)
    (not (= (modulo v 2) 0)))

  )
