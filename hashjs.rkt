#lang racket

(require "modulejs.rkt")

(provide hashjs)

(module/js hashjs

  (provide js-hash->string)
  (provide js-string->hash)
  (provide js-hash-copy)

  (define (js-hash->string h)
    (send json stringify h))

  (define (js-string->hash h)
    (send json parse h))

  (define (js-hash-copy h)
    (js-string->hash (js-hash->string h)))

  )
