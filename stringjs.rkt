#lang racket

(require "modulejs.rkt")

(provide stringjs)

(module/js stringjs

  (provide js-string?)
  (provide js-substring)
  (provide js-string-split)
  (provide js-string-join)
  (provide js-string-empty?)

  (define (js-string? str)
    (string=? (typeof str) "string"))

  (define/contract (js-substring str start end)
    (-> string? integer? (or/c undefined? integer?) string?)
    (send str substring start end))

  (define/contract (js-string-split str sep)
    (-> string? string? vector?)
    (send str split sep))

  (define (js-string-join vec sep)
    (send vec join sep))

  (define (js-string-empty? str)
    (equal? str ""))

  )
