#lang racket

(require "modulejs.rkt")

(provide vectorjs)

(module/js vectorjs

  (provide js-vector?)
  (provide js-vector-empty?)
  (provide js-vector-member)
  (provide js-vector-length)
  (provide js-vector-append)
  (provide js-vector-append!)
  (provide js-vector-last)
  (provide js-vector-map)
  (provide js-vector-fold)
  (provide js-vector-filter)
  (provide js-vector-flatten)

  (define for-loop/local for-loop)

  (define (js-vector? v)
    (is-a? v array))

  (define (js-vector-member value vec)
    (send vec indexOf value))

  (define (js-vector-length vec)
    (get-field length vec))

  (define (js-vector-empty? vec)
    (= (js-vector-length vec) 0))

  (define (js-vector-append #:rest args)
    (define rtn (vector))
    (for-loop/local (lambda (i)
                      (send (get-field push rtn) apply rtn (vector-ref args i)))
                    (js-vector-length args))
    rtn)

  (define (js-vector-append! vec #:rest args)
    (for-loop/local (lambda (i)
                      (send (get-field push vec) apply vec (vector-ref args i)))
                    (js-vector-length args)))

  (define (js-vector-last vec)
    (vector-ref vec (- (js-vector-length vec) 1)))

  (define (js-vector-map func #:rest args)
    (define rtn (vector))
    (define arg-length (js-vector-length args))
    (define map-length (js-vector-length (vector-ref args 0)))
    (define (outer-loop i)
      (define elements (vector))
      (define (inner-loop j)
        (send elements push (vector-ref (vector-ref args j) i)))
      (for-loop/local inner-loop arg-length)
      (define value (apply func elements))
      (send rtn push value))
    (for-loop/local outer-loop map-length)
    rtn)

  (define (js-vector-fold func start vec)
    (define accum start)
    (for ([v vec])
      (set! accum (func v accum)))
    accum)

  (define (js-vector-filter func vec)
    (send vec filter func))

  (define (js-vector-flatten vec)
    (define rtn (vector))
    (send (get-field concat rtn) apply rtn vec))

  )
