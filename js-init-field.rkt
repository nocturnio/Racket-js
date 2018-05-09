#lang racket

(require "js-base.rkt")
(require "js-accessor.rkt")
(require "js-function.rkt")
(require "js-call.rkt")

(provide js-init-field%
         js-init-field?
         js-init-field)

(define js-init-field%
  (class js-accessor%
    (init key)
    (define _key key)
    (super-new)
    (inherit get-param-strings)

    (define/override (compile)
      (define params (get-param-strings))
      (format "(~a[\"_params\"][~a])" (first params) (second params)))

    (define/public (get-key) _key)

    (define/public (bind-command: param)
      (define key (get-key))
      (define js-verify (js-base (make-js-safe "verify-init-field")))
      (js-call js-verify param key))))

(define (js-init-field? a)
  (is-a? a js-init-field%))

(define (js-init-field a b key)
  (new js-init-field% [params (list a b)] [key key]))
