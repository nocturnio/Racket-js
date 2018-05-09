#lang racket

(require "js-base.rkt")
(require "js-function.rkt")

(provide js-accessor% js-accessor? js-accessor)

(define (js-accessor? a)
  (is-a? a js-accessor%))

(define (js-accessor obj key)
  (new js-accessor% [params (list obj key)]))

(define js-accessor%
  (class js-function%

    (super-new [name "accessor"])

    (inherit get-param-strings)

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (define params (get-param-strings))
      (format "(~a[~a])" (first params) (second params)))))
