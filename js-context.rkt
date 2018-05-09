#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")

(provide js-context% js-context?)

(define (js-context? a)
  (is-a? a js-context%))

(define js-context%
  (class js-base%

    (init [commands '()])

    (super-new [name "context"])

    (define self-commands commands)

    (define/public (get-commands)
      self-commands)

    (define/public (get-declarations)
      (define declarations (filter js-declaration? self-commands))
      (make-hash (for/list ([d declarations])
                   (cons (send d get-name) d))))

    (define/public (prepend-command: command)
      (set! self-commands (append (list command) self-commands)))

    (define/public (add-command: command)
      (set! self-commands (append self-commands (list command))))

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (string-join (for/list ([c self-commands]) (send c compile))
                   ";"
                   #:after-last ";"))))
