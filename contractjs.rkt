#lang racket

(require "modulejs.rkt")

(provide contractjs)

(module/js contractjs

  (provide js-function-contract)
  (provide js-method-contract)
  (provide js-class-contract)
  (provide js-value-contract)
  (provide js-contract?)
  (provide js-turn-off-contracts)
  (provide js-any/c)
  (provide js-false/c)
  (provide js-true/c)

  (define (js-any/c v)
    true)

  (define (js-false/c v)
    (not (not (not v))))

  (define (js-true/c v)
    (not (not v)))

  (define contracts-off? false)

  (define (js-turn-off-contracts)
    (set! contracts-off? true))

  (define (contract% func)
    (hash-set! this "func" func)
    this)

  (define (js-contract? c)
    (is-a? c contract%))

  (define (js-value-contract condition)
    (define (func signer signer-name)
      (cond
        [contracts-off?
         signer]
        [else
         (check-condition condition signer signer-name)
         signer]))
    (make-object contract% func))

  (define (js-function-contract #:rest conditions)
    (define (func signer signer-name args)
      (cond
        [contracts-off?
         (apply signer args)]
        [else
         (check-domain conditions args signer-name)
         (define post (apply signer args))
         (check-condition (vector-last conditions) post signer-name "parameter: output")
         post]))
    (make-object contract% func))

  (define (js-method-contract #:rest conditions)
    (define (func signer signer-name args class-name)
      (cond
        [contracts-off?
         (apply signer args)]
        [else
         (check-class-domain conditions args signer-name class-name)
         (define post (apply signer args))
         (check-class-condition (vector-last conditions) post signer-name class-name "parameter: output")
         post]))
    (make-object contract% func))

  (define (js-class-contract conditions)
    (define (func % %-name)
      (for ([condition conditions])
        (define name (vector-ref condition 0))
        (define contract (vector-ref condition 1))
        (define func (get-field func contract))
        (define signer (hash-ref (hash-ref % "prototype") name))
        (unless signer
          (error (string-append %-name ": broke it's contract\\n"
                                "no public method " name "\\n")))
        (bind-class-contract %
                             %-name
                             signer
                             name
                             func))
      %)
    (make-object contract% func))

  (define (bind-class-contract % %-name signer signer-name contract)
    (define remapped
      (lambda args
        (apply contract (vector signer signer-name args %-name))))
    (hash-set! (hash-ref % "prototype") signer-name remapped))

  (define (check-condition condition arg signer-name [param-description ""])
    (define name (vector-ref condition 0))
    (define predicate (vector-ref condition 1))
    (unless (predicate arg)
      (error (string-append signer-name ": contract violation\\n"
                            param-description "\\n"
                            "expected: " name "\\n"
                            "given: " arg " (" (typeof arg) ")\\n"))))

  (define (check-domain conditions args signer-name)
    (for ([i (vector-length args)])
      (define condition (vector-ref conditions i))
      (define arg (vector-ref args i))
      (check-condition condition arg signer-name (string-append "parameter #" (+ 1 i)))))

  (define (check-class-condition condition arg signer-name class-name [param-description ""])
    (define name (vector-ref condition 0))
    (define predicate (vector-ref condition 1))
    (unless (predicate arg)
      (error (string-append signer-name ": contract violation\\n"
                            param-description "\\n"
                            "expected: " name "\\n"
                            "given: " arg " (" (typeof arg) ")\\n"
                            "contract on: " class-name
                            "\\n"))))

  (define (check-class-domain conditions args signer-name class-name)
    (for ([i (vector-length args)])
      (define condition (vector-ref conditions i))
      (define arg (vector-ref args i))
      (check-class-condition condition arg signer-name class-name (string-append "parameter #" (+ 1 i)))))

  )
