#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-accessor.rkt")
(require "js-function.rkt")
(require "js-operator.rkt")
(require "js-conditional.rkt")
(require "js-call.rkt")

(provide js-optional-field%
         js-optional-field?
         js-optional-field)

(define (js-optional-field? a)
  (is-a? a js-optional-field%))

(define (js-optional-field name value)
  (new js-optional-field% [name name] [value value]))

(define js-optional-field%
  (class js-declaration%
    (super-new)

    (inherit get-name)
    (inherit get-value)

    (define/public (bind-command: param)
       (define key (get-name))
       (define value (get-value))
       (define js-bind (js-base (make-js-safe "bind-optional-field")))
       (js-call js-bind param key value))))
