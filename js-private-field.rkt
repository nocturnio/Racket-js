#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-function.rkt")
(require "js-call.rkt")

(provide js-private-field%
         js-private-field?
         js-private-field)

(define (js-private-field? a)
  (is-a? a js-private-field%))

(define (js-private-field name value)
  (new js-private-field% [name name] [value value]))

(define js-private-field%
  (class js-declaration%
    (super-new)
    (inherit get-name)
    (inherit get-value)

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (format "(self[\"(~a)\"])" (get-name)))

    (define/public (bind-command: param)
      (define key (get-name))
      (define value (get-value))
      (define js-bind (js-base (make-js-safe "bind-private-field")))
      (js-call js-bind (js-base "self") param key value))))
