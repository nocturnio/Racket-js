#lang racket

(require "js-declaration.rkt")
(require "js-base.rkt")
(require "js-function.rkt")
(require "js-call.rkt")

(provide js-override-method%
         js-override-method?
         js-override-method)

(define (js-override-method? a)
  (is-a? a js-override-method%))

(define (js-override-method name value)
  (new js-override-method% [name name] [value value]))

(define js-override-method%
  (class js-declaration%
    (super-new)

    (inherit get-value)
    (inherit get-name)

    (define/override (get-name/safe)
      (format "(self[\"~a\"])" (get-name)))

    (define/public (bind-declaration: class-constructor)
      (define value (get-value))
      (define key (get-name))
      (define js-bind (js-base (make-js-safe "bind-override-method")))
      (js-call js-bind class-constructor key value))))
