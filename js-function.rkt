#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")

(provide js-function%
         param/c
         js-function
         js-function?)

(define param/c (or/c js-base? number? string? procedure?))

;; (define (js-function-call func args)
;;   (cond
;;     [(js-base? func)
;;      (new js-function%
;;           [params args]
;;           [name (send func get-name/safe)]
;;           [definition func])]
;;     [else
;;      (apply func args)]))

(define (js-function? a)
  (is-a? a js-function%))

(define (js-function name . params)
  (new js-function% [name name] [params params]))

(define/contract js-function%
  (class/c
   (init [params (listof param/c)] [definition (or/c boolean? js-base?)])
   [compile (->m string?)]
   [get-params (->m (listof param/c))]
   [set-params: (->m (listof param/c) void?)])

  (class js-base%

    (init [params '()] [definition false])

    (super-new)

    (inherit get-name)

    (define _params params)
    (define _definition definition)

    (define/public (get-definition)
      _definition)

    (define/public (get-params)
      _params)

    (define/public (get-param-strings)
      (define clean-params (map cleanse _params))
      (for/list ([c clean-params])
        (cond
          [(js-declaration? c)
           (send c get-name/safe)]
          [(procedure? c)
           (displayln c)
           (send (c 0) get-name)]
          [else
           (send c compile)])))

    (define/public (set-params: params)
      (set! _params params))

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (format "(~a(~a))"
              (get-name)
              (string-join (get-param-strings) ",")))))
