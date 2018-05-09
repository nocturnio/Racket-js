#lang racket

(require "js-base.rkt")
(require "js-export.rkt")
(require "js-context.rkt")
(require "js-function.rkt")

(provide js-module% js-module?)

(define (js-module? a)
  (is-a? a js-module%))

(define/contract js-module%
  (class/c (init [exports (listof js-base?)]
                 [commands (listof js-base?)]))

  (class js-base%
    (init exports commands)
    (super-new [name "module"])
    (define _exports exports)
    (define _commands commands)
    (define _extra-code "")
    (define/public (get-exports) _exports)

    (define/public (inject: code)
      (set! _extra-code (string-append _extra-code code)))

    (define/override (compile)
      (string-append
       (string-join (for/list ([c _commands]) (send c compile)) ";")
       ";"
       _extra-code))))
