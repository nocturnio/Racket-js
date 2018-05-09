#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-operator.rkt")
(require "js-accessor.rkt")
(require "js-context.rkt")
(require "js-definition.rkt")
(require "js-statement.rkt")
(require "js-function.rkt")
(require "js-conditional.rkt")
(require "js-call.rkt")
(require "js-public-field.rkt")

(provide js-init-public-field%
         js-init-public-field?
         js-init-public-field)

(define js-init-public-field%
  (class js-public-field%
    (super-new)
    (inherit get-name)

    (define/override (compile)
      (format "(self[\"~a\"])" (get-name)))

    (define/override (bind-command: param)
      (define key (get-name))
      (define js-bind (js-base (make-js-safe "bind-public-init-field")))
      (js-call js-bind (js-base "self") param key))))

(define (js-init-public-field? a)
  (is-a? a js-init-public-field%))

(define (js-init-public-field name)
  (new js-init-public-field% [name name] [value "___none___"]))
