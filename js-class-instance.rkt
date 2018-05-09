#lang racket

(require "js-function.rkt")

(provide js-class-instance%
         js-class-instance?)

(define (js-class-instance? a)
  (is-a? a js-class-instance%))

(define js-class-instance%
  (class js-function%
    (init class-type)
    (define _class-type class-type)
    (super-new)
    (inherit get-name)
    (inherit get-param-strings)

    (define/public (get-class-type) _class-type)

    (define/override (compile)
      (format "(new ~a(~a))" (get-name) (string-join (get-param-strings) ",")))))
