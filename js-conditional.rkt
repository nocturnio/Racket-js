#lang racket
(require "js-function.rkt")

(provide js-conditional%
         js-conditional)

(define (3-item-list/c lst)
  (= (length lst) 3))

(define (js-conditional c t e)
  (new js-conditional% [params (list c t e)]))

(define/contract js-conditional%
  (class/c (init [params (and/c (listof param/c) 3-item-list/c)]))

  (class js-function%
    (init [params '()])

    (super-new [name "if_then_else"] [params params])

    (inherit get-param-strings)

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (define params (get-param-strings))
      (format "(~a?~a:~a)"
              (first params)
              (second params)
              (third params)))))
