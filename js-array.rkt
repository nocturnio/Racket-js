#lang racket

(require "js-function.rkt")

(provide js-array% js-array?)

(define (js-array? a)
  (is-a? a js-array%))

(define js-array%
  
  (class js-function%
    
    (init [params '()])
    
    (super-new [name "array"] [params params])
    
    (inherit get-param-strings)
    
    (define/override (get-name/safe)
      (compile))
    
    (define/override (compile)
      (define params (get-param-strings))
      (format "[~a]" (string-join params ",")))))