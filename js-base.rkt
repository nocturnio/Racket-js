#lang racket

(provide js-base% js-base? cleanse js-base make-js-safe)

(define (js-base name)
  (new js-base% [name name]))

(define (make-js-safe name)
  (define replacements
    (vector "__mutable__"
            "__at__"
            "__hashtag__"
            "__object__"
            "__power__"
            "_"
            "__plus__"
            "__equal__"
            "__predicate__"
            "__lessthan__"
            "__greaterthan__"
            "__variant__"
            "__tilde__"
            "__colon__"
            "__special__"
            "__andpercand__"))
  (define invalids
    (vector "!"
            "@"
            "#"
            "%"
            "^"
            "-"
            "+"
            "="
            "?"
            "<"
            ">"
            "/"
            "~"
            ":"
            "*"
            "&"))
  (for ([ch invalids]
        [i (vector-length invalids)])
    (set! name (string-replace name ch (vector-ref replacements i))))
  name)

(define (cleanse p)
  (cond [(string? p)
         (new js-base% [name (format "\"~a\"" p)] [safe? true])]
        [(number? p)
         (new js-base% [name (number->string p)] [safe? true])]
        [(js-base? p)
         p]
        [(procedure? p)
         p]))

(define (js-base? a)
  (is-a? a js-base%))

(define/contract js-base%
  (class/c (init [name string?])
           [compile (->m string?)]
           [get-name (->m string?)])

  (class object%

    (init name [safe? false])

    (super-new)

    (define _name name)
    (define _safe? safe?)

    (define/public (get-name)
      _name)

    (define/public (get-name/safe)
      (if _safe? _name (make-js-safe _name)))

    (define/public (compile)
      _name)

    (define/public (write-to-file: file)
      (define port (open-output-file file #:exists 'replace))
      (display (compile) port)
      (close-output-port port))))
