#lang racket

(require "js-base.rkt")
(require "js-syntax.rkt")

(provide module/js)
(provide js-base)

(define-syntax module/js
  (syntax-rules ()
    ((_ name exp ...)
     (js-module name exp ...))))
