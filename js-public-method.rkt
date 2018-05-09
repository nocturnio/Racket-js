#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-function.rkt")
(require "js-call.rkt")

(provide js-public-method%
         js-public-method?
         js-public-method)

(define (js-public-method? a)
  (is-a? a js-public-method%))

(define (js-public-method name value)
  (new js-public-method% [name name] [value value]))

(define js-public-method%
  (class js-declaration%
    (super-new)

    (inherit get-name)
    (inherit get-value)

    (define/override (get-name/safe)
      (format "(self[\"~a\"])" (get-name)))

    (define/public (bind-declaration: class-constructor)
      (define value (get-value))
      (define key (get-name))
      (define js-bind (js-base (make-js-safe "bind-public-method")))
      (js-call js-bind class-constructor key value))))
