#lang racket

(require "js-declaration.rkt")
(require "js-base.rkt")
(require "js-call.rkt")

(provide js-parent-field%
         js-parent-field?
         js-parent-field)

(define (js-parent-field? a)
  (is-a? a js-parent-field%))

(define (js-parent-field name value)
  (new js-parent-field% [name name] [value value]))

(define js-parent-field%
  (class js-declaration%
    (super-new)

    (inherit get-name)
    (inherit get-value)

    (define/public (bind-command: param)
      (define key (get-name))
      (define value (get-value))
      (define js-bind (js-base (make-js-safe "bind-parent-field")))
      (js-call js-bind param key value))))
