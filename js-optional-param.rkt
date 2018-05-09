#lang racket

(require "js-declaration.rkt")

(provide js-optional-param%
         js-optional-param?
         js-optional-param)

(define (js-optional-param? a)
  (is-a? a js-optional-param%))

(define (js-optional-param name value)
  (new js-optional-param% [name name] [value value]))

(define js-optional-param%
  (class js-declaration% (super-new)))
