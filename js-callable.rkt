#lang racket

(require "js-base.rkt")

(provide js-function-callable%
         js-operator-callable%
         js-function-callable
         js-function-callable/safe
         js-statement-callable
         js-operator-callable
         js-function-callable?
         js-operator-callable?
         js-statement-callable?)

(define js-function-callable%
  (class js-base%
    (super-new)))

(define js-operator-callable%
  (class js-base%
    (super-new)))

(define js-statement-callable%
  (class js-base%
    (super-new)))

(define (js-function-callable/safe name)
  (new js-function-callable% [name (make-js-safe name)]))

(define (js-function-callable name)
  (new js-function-callable% [name name]))

(define (js-operator-callable name)
  (new js-operator-callable% [name name]))

(define (js-statement-callable name)
  (new js-statement-callable% [name name]))

(define (js-function-callable? a)
  (is-a? a js-function-callable%))

(define (js-operator-callable? a)
  (is-a? a js-operator-callable%))

(define (js-statement-callable? a)
  (is-a? a js-statement-callable%))
