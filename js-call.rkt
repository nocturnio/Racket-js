#lang racket

(require "js-base.rkt")
(require "js-definition.rkt")
(require "js-function.rkt")
(require "js-statement.rkt")
(require "js-operator.rkt")
(require "js-declaration.rkt")
(require "js-callable.rkt")

(provide js-call)
(provide js-call/list)
(provide js-function-call)

(define/contract (js-call func . args)
  (->* ((or/c procedure? js-base?)) #:rest (listof param/c) js-function?)
  (js-call/list func args))

(define (js-call/list func args)
  (js-function-call func args))

(define (js-function-call func args)
  (cond
    [(js-operator-callable? func)
     (call-instance js-operator% (send func get-name) args)]

    [(js-statement-callable? func)
     (call-instance js-statement% (send func get-name) args)]

    [(js-function-callable? func)
     (call-instance js-function% (send func get-name) args)]

    [(js-definition? func)
     (verify-function-arity/definition! func args)
     (call-instance js-function% (send func get-name/safe) args)]

    [(js-declaration? func)
     (verify-function-arity/declaration! func args)
     (call-instance js-function% (send func get-name/safe) args)]

    [(js-base? func)
     (call-instance js-function% (send func get-name/safe) args)]

    [(procedure? func)
     (apply func args)]))

(define (call-instance % name args)
  (new % [name name] [params args]))

(define (verify-function-arity/declaration! func args)
  (define value (send func get-value))
  (cond
    [(js-definition? value)
     (verify-function-arity/definition! value args)]
    [(js-declaration? value)
     (verify-function-arity/declaration! value args)]))

(define (verify-function-arity/definition! func args)
  (define expected (send func get-param-count))
  (define optional (send func get-optional-param-count))
  (define unlimited? (send func get-param-unlimited?))
  (define given (length args))
  (when (and (or (> given (+ optional expected))
                 (< given expected))
             (not unlimited?))
    (define error-message-format
      (string-append "~a: arity mismatch;\n"
                     "the expected number of arguments does not match the given number\n"
                     "expected: ~a\n"
                     "given: ~a\n"
                     "unlimited: ~a\n"
                     "arguments: ~a\n"))
    (error (format error-message-format
                   (send func get-name)
                   expected
                   given
                   unlimited?
                   (for/vector ([a args]) (send a get-name))))))
