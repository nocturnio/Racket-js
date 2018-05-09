#lang racket

(require "js-function.rkt")

(provide js-operator%
         js-operator?
         js-operator
         js-assignment?)

(define (js-assignment? a)
  (and (js-operator? a) (string=? (send a get-name) "=")))

(define (js-operator? a)
  (is-a? a js-operator%))

(define (js-operator name . args)
  (new js-operator% [name name] [params args]))

(define/contract js-operator%
  (class/c [compile (->m string?)])

  (class js-function%
    (super-new)

    (inherit get-param-strings)
    (inherit get-name)

    (define/override (compile)
      (format "(~a)" (string-join (get-param-strings) (get-name))))))
