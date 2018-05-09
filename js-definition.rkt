#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-context.rkt")
(require "js-conditional.rkt")

(provide js-definition% js-definition? js-definition)

(define (js-definition? a)
  (is-a? a js-definition%))

(define (js-definition params context)
  (new js-definition% [params params] [context context]))

(define/contract js-definition%
  (class/c (init [context js-context?]
                 [params (listof js-base?)]))

  (class js-base%
    (init context
          [params '()]
          [optional-params '()]
          [param-unlimited? false])

    (super-new [name "#<procedure>"])

    (define _context context)
    (define _params params)
    (define _optional-params optional-params)
    (define _param-unlimited? param-unlimited?)

    (define/public (get-context)
      _context)

    (define/public (prepend-context-command: command)
      (send _context prepend-command: command))

    (define/public (get-param-strings)
      (for/list ([p _params]) (send p get-name/safe)))

    (define/public (get-optional-param-strings)
      (for/list ([o _optional-params]) (send o get-name/safe)))

    (define/public (get-param-unlimited?)
      _param-unlimited?)

    (define/public (get-param-count)
      (length _params))

    (define/public (get-optional-param-count)
      (length _optional-params))

    (define/public (get-all-params)
      (append _params _optional-params))

    (define/public (get-return)
      (last (send _context get-commands)))

    (define/public (unlimit-param!)
      (set! _param-unlimited? true))

    (define/override (get-name/safe)
      (compile))

    (define/override (compile)
      (define params (flatten (append (get-param-strings) (get-optional-param-strings))))
      (define commands (send _context get-commands))
      (cond
        [(null? commands)
         "(function(){return null;})"]
        [else
         (define pre-commands (reverse (cdr (reverse commands))))
         (define setup-commands (for/list ([c pre-commands]) (send c compile)))
         (define return (send (cleanse (last commands)) get-name/safe))
         (format "(function(~a){~areturn ~a;})"
                 (string-join params ",")
                 (if (empty? setup-commands)
                     ""
                     (string-join setup-commands ";" #:after-last ";"))
                 return)]))))
