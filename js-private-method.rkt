#lang racket

(require "js-base.rkt")
(require "js-function.rkt")
(require "js-declaration.rkt")
(require "js-call.rkt")

(provide js-private-method%
         js-private-method?
         js-private-method)

(define (js-private-method? a)
  (is-a? a js-private-method%))

(define (js-private-method name value)
  (new js-private-method% [name name] [value value]))

(define js-private-method%
  (class js-declaration%
    (super-new)

    (inherit get-value)
    (inherit get-name)

    (define/override (get-name/safe)
      (format "(self[\"(~a)\"])" (get-name)))

    (define/public (bind-declaration: class-constructor)
      (define value (get-value))
      (define key (get-name))
      (define js-bind (js-base (make-js-safe "bind-private-method")))
      (js-call js-bind class-constructor key value))))
