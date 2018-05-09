#lang racket

(require "js-accessor.rkt")
(require "js-operator.rkt")
(require "js-declaration.rkt")
(require "js-definition.rkt")
(require "js-function.rkt")
(require "js-base.rkt")
(require "js-call.rkt")
(require "js-context.rkt")

(provide js-class%
         js-class?)

(define (js-class? a)
  (is-a? a js-class%))

(define js-class%
  (class js-base%
    (init parent-fields
          fields
          [public-fields '()]
          [optional-fields '()]
          [private-fields '()]
          [public-methods '()]
          [private-methods '()]
          [override-methods '()]
          [parent (js-base "Object")])

    (define _parent parent)
    (define _parent-fields parent-fields)
    (define _fields fields)
    (define _public-fields public-fields)
    (define _optional-fields optional-fields)
    (define _public-methods public-methods)
    (define _override-methods override-methods)
    (define _private-methods private-methods)
    (define _private-fields private-fields)

    (super-new [name "class"])

    (define/override (get-name/safe)
      (compile))

    (define (constructor)
      (define context (new js-context%))
      (define param-hash (js-base "_internal_param_hash"))
      (define parent-name (send _parent get-name/safe))
      (define parent-constructor (send (js-accessor _parent "call") compile))
      (define declare-js-self (js-declaration "self" (js-base "this")))
      (define js-self (js-base "self"))
      (define all-fields
        (append _fields
                _optional-fields
                _public-fields
                _private-fields
                _parent-fields))
      (define new-parent (string-append "new " (send _parent get-name/safe)))
      (define set-param-hash
        (js-operator "=" (js-accessor js-self "_params") param-hash))
      (send context add-command: declare-js-self)
      (send context add-command: set-param-hash)
      (for ([f all-fields])
        (send context add-command: (send f bind-command: param-hash)))
      (define inherit (js-function parent-constructor js-self param-hash))
      (send context add-command: inherit)
      (send context add-command: js-self)
      (define constructor-definition
        (new js-definition%
             [params (list param-hash)]
             [context context]))
      (js-declaration "_internal_constructor" constructor-definition))

    (define (class-inherit ctor)
      (define js-bind (js-base (make-js-safe "bind-parent")))
      (js-call js-bind ctor _parent))

    (define/override (compile)
      (define ctor (constructor))
      (define private-declarations _private-methods)
      (define methods-to-bind (append _public-methods _override-methods _private-methods))
      (define bind-declarations
        (for/list ([m methods-to-bind]) (send m bind-declaration: ctor)))
      (define inherit (class-inherit ctor))
      (define parent-declaration (js-declaration "_internal_parent" _parent))
      (define commands
        (flatten (list parent-declaration
                       ctor
                       inherit
                       bind-declarations
                       ctor)))
      (define class-context (new js-context% [commands commands]))
      (define definition (new js-definition% [context class-context]))
      (send (js-function (send definition compile)) compile))))
