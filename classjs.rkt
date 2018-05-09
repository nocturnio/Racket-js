#lang racket

(require "modulejs.rkt")

(provide classjs)

(module/js classjs

  (provide public-method-error)
  (provide override-method-error)
  (provide bind-public-method)
  (provide bind-private-method)
  (provide bind-override-method)
  (provide bind-public-field)
  (provide bind-parent-field)
  (provide bind-private-field)
  (provide bind-public-init-field)
  (provide bind-optional-field)
  (provide verify-init-field)
  (provide bind-parent)
  (provide make-class)
  (provide js-object?)

  (define (js-object? v)
    (string=? (typeof v) "object"))

  (define (public-method-error name)
    (error (string-append "class*: superclass already contains method\\n"
                          "method name: "
                          name)))

  (define (override-method-error name)
    (error (string-append "class*: superclass does not provide an expected method for everride\\n"
                          "override name: "
                          name)))

  (define (init-field-error name)
    (error (string-append  "instantiate: no argument for required init variable\\n"
                           "required: "
                           name)))

  (define (bind-parent obj parent)
    (define parent-prototype (get-field prototype parent))
    (set! (get-field prototype obj) (send object% create parent-prototype)))

  (define (bind-private-method obj name func)
    (hash-set! (get-field prototype obj) (string-append "(" name ")") func))

  (define (bind-public-method obj name func)
    (if (undefined? (hash-ref (get-field prototype obj) name))
        (hash-set! (get-field prototype obj) name func)
        (public-method-error name)))

  (define (bind-public-init-field obj params name)
    (define init-param (hash-ref params name))
    (if (undefined? init-param)
        (init-field-error name)
        (hash-set! obj name init-param)))

  (define (bind-override-method obj name func)
    (if (undefined? (hash-ref (get-field prototype obj) name))
        (override-method-error name)
        (hash-set! (get-field prototype obj) name func)))

  (define (bind-public-field obj params name value)
    (define init-param (hash-ref params name))
    (if (undefined? init-param)
        (hash-set! obj name value)
        (hash-set! obj name init-param)))

  (define (bind-private-field obj params name value)
    (bind-public-field obj params (string-append "(" name ")") value))

  (define (bind-optional-field params name value)
    (define init-param (hash-ref params name))
    (when (undefined? init-param)
      (hash-set! params name value)))

  (define (bind-parent-field params name value)
    (when (undefined? (hash-ref params name))
      (hash-set! params name value)))

  (define (verify-init-field params name)
    (define init-param (hash-ref params name))
    (when (undefined? init-param)
      (init-field-error name)))

  (define (make-class properties)
    (define parent (hash-ref properties "parent"))
    (define parent-fields (hash-ref properties "parent-fields"))
    (define init-names (hash-ref properties "init-names"))
    (define public-fields (hash-ref properties "public-fields"))
    (define public-init-names (hash-ref properties "public-init-names"))
    (define optional-fields (hash-ref properties "optional-fields"))
    (define override-methods (hash-ref properties "override-methods"))
    (define public-methods (hash-ref properties "public-methods"))
    (define local-closure (hash-ref properties "local-closure"))
    (define field-closure (hash-ref properties "field-closure"))

    (define (constructor params)
      (define self this)
      (hash-set! self "_private" (hash))
      (apply local-closure (vector params))

      (for ([name init-names])
        (verify-init-field params name))

      (for ([field optional-fields])
        (define name (vector-ref field 0))
        (define value (vector-ref field 1))
        (bind-optional-field params name value))

      (for ([field public-fields])
        (define name (vector-ref field 0))
        (define value (vector-ref field 1))
        (bind-public-field self params name value))

      (for ([name public-init-names])
        (bind-public-init-field self params name))

      (apply field-closure (vector params))

      (for ([field parent-fields])
        (define name (vector-ref field 0))
        (define value (vector-ref field 1))
        (bind-parent-field params name value))

      (send object% call self params)

      self)

    (bind-parent constructor parent)

    (for ([method public-methods])
      (define name (vector-ref method 0))
      (define value (vector-ref method 1))
      (bind-public-method constructor name value))

    (for ([method override-methods])
      (define name (vector-ref method 0))
      (define value (vector-ref method 1))
      (bind-override-method constructor name value))

    constructor)

  )
