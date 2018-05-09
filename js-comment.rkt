#lang racket

(require "js-base.rkt")

(provide js-comment%
         js-comment?
         js-comment)

(define (js-comment str)
  (new js-comment% [name str]))

(define (js-comment? a)
  (is-a? a js-comment%))

(define js-comment%
  (class js-base%
    (super-new)
    (inherit get-name)

    (define/override (compile)
      (string-append "/*" (get-name) "*/"))))
