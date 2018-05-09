#lang racket

(require "js-definition.rkt")
(require "js-declaration.rkt")
(require "js-hash.rkt")
(require "js-function.rkt")
(require "js-class.rkt")
(require "js-class-instance.rkt")

(provide (all-defined-out))

(define (verify-hash-ref h k)
  (when (js-declaration? h)
    (define value (send h get-value))
    (verify-hash-ref/hash value k))

  (verify-hash-ref/hash h k))

(define (verify-hash-ref/hash h k)
  (when (and (js-hash? h) (string? k) (not (member (format "\"~a\"" k) (send h get-keys))))
    (error (format "hash-ref: no value found for key\n key: \"~a\"" k))))

(define (verify-module-exports exports module-name)
  (when (null? exports)
    (error (format (string-append "module: provided identifier not defined or imported for phase 0\n"
                                  "at: ~a\n")
                   module-name))))

(define (verify-superclass-init super-call)
  (when (null? super-call)
    (error "superclass initialization not invoked by initialization")))
