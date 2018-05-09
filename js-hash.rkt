#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-function.rkt")

(provide js-hash% js-hash?)

(define (js-hash? a)
  (is-a? a js-hash%))

(define (evens lst)
  (if (or (null? lst)(null? (cdr lst)))
      '()
      (cons (second lst) (evens (cddr lst)))))

(define (odds lst)
  (if (or (null? lst) (null? (cdr lst)))
      '()
      (cons (first lst) (odds (cddr lst)))))

(define (even-list/c lst)
  (even? (length lst)))

(define/contract js-hash%
  (class/c (init [params (and/c (listof param/c) even-list/c)]))

  (class js-function%

    (init [params '()])

    (super-new [name "hash"] [params params])

    (inherit get-param-strings)

    (define/public (get-key-count)
      (length (get-keys)))

    (define/public (get-keys)
      (odds (get-param-strings)))

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (define params (get-param-strings))
      (define keys (odds params))
      (define values (evens params))
      (define keys-values
        (for/list ([k keys]
                   [v values])
          (format "~a:~a" k v)))
      (format "{~a}" (string-join keys-values ",")))))
