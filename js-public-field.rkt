#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-function.rkt")
(require "js-call.rkt")

(provide js-public-field%
         js-public-field?
         js-public-field)

(define (js-public-field? a)
  (is-a? a js-public-field%))

(define (js-public-field name value)
  (new js-public-field% [name name] [value value]))

(define js-public-field%
  (class js-declaration%
    (super-new)
    (inherit get-name)
    (inherit get-value)

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (format "(self[\"~a\"])" (get-name)))

    (define/public (bind-command: param)
      (define key (get-name))
      (define value (get-value))
      (define js-bind (js-base (make-js-safe "bind-public-field")))
      (js-call js-bind (js-base "self") param key value))))
