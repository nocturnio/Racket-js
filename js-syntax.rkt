#lang racket

(require "js-language.rkt")

(provide js-module)

(define-syntax js-module
  (syntax-rules (provide)
    ((_ exports (provide x))
     (begin
       (verify-module-exports exports (symbol->string (quote x)))
       (define x (first exports))
       (set! exports (rest exports))))

    ((_ exports x)
     ((lambda () (when false (displayln "congrats hacker")))))

    ((_ name exp ...)
     (begin
       (define name (js-module/context (js-context exp ...)))
       (define _internal-exports (send name get-exports))
       (js-module _internal-exports exp) ...))))

(define-syntax js-context
  (syntax-rules ()
    ((_ exp ...)
     (let ((internal-c (new js-context%)))
       (js-context-helper exp)
       ...
       (js-context-helper2 internal-c exp)
       ...
       (cxt-command internal-c exp)
       ...
       internal-c))))

(define-syntax js-context-helper
  (syntax-rules (define define/contract)
    ((_ (define (f x ...) b ...))
     (define f (js-declaration (symbol->string (quote f)))))
    ((_ (define (f) b ...))
     (define f (js-declaration (symbol->string (quote f)))))
    ((_ (define/contract (f x ...) b ...))
     (define f (js-declaration (symbol->string (quote f)))))
    ((_ (define/contract (f) b ...))
     (define f (js-declaration (symbol->string (quote f)))))
    ((_ x)
     '())))

(define-syntax js-context-helper2
  (syntax-rules (define define/contract)
    ((_ c (define (f x ...) b ...))
     (send c add-command: f))
    ((_ c (define (f) b ...))
     (send c add-command: f))
    ((_ c (define/contract (f x ...) b ...))
     (send c add-command: f))
    ((_ c (define/contract (f) b ...))
     (send c add-command: f))
    ((_ c x)
     '())))

(define-syntax js-class
  (syntax-rules ()
    ((_ base p ...)
     (let ()
       (js-class-pre-define p)
       ...
       (js-class-cxt-commands p)
       ...
       (define bindings (flatten (list (js-class-binding p) ...)))
       (js-class/bindings (flatten bindings) (cxt-query base))))))

(define-syntax js-class-pre-define
  (syntax-rules (define define/override define/public define/contract)
    ((_ (define (f x ...) b ...))
     (define f (js-private-method (symbol->string (quote f)) js-null)))
    ((_ (define (f) b ...))
     (define f (js-private-method (symbol->string (quote f)) js-null)))
    ((_ (define/contract (f x ...) b ...))
     (define f (js-private-method (symbol->string (quote f)) js-null)))
    ((_ (define/contract (f) b ...))
     (define f (js-private-method (symbol->string (quote f)) js-null)))
    ((_ (define/public (f x ...) b ...))
     (define f (js-public-method (symbol->string (quote f)) js-null)))
    ((_ (define/public (f) b ...))
     (define f (js-public-method (symbol->string (quote f)) js-null)))
    ((_ (define/override (f x ...) b ...))
     (define f (js-override-method (symbol->string (quote f)) js-null)))
    ((_ (define/override (f) b ...))
     (define f (js-override-method (symbol->string (quote f)) js-null)))
    ((_ x)
     '())))

(define-syntax js-lambda/context
  (syntax-rules ()
    ((_ () c)
     (new js-definition% [context c]))
    ((_ (p ...) c)
     (let ()
       (js-lambda-param-helper p)
       ...
       (define internal-all-params (list (js-lambda-param-helper2 p) ...))
       (define-values (optional required) (partition js-optional-param? internal-all-params))
       (define optional-defines
         (for/list ([param optional])
           (js-call js-set!
                    param
                    (js-if (js-call js-undefined? param)
                           (send param get-value)
                           param))))
       (define commands (send c get-commands))
       (define final-commands
         (if (js-self-declare? (first commands))
             (append (list (first commands)) optional-defines (rest commands))
             (append optional-defines commands)))
       (new js-definition%
            [params required]
            [optional-params optional]
            [context (new js-context% [commands (flatten final-commands)])])))))

(define-syntax js-let
  (syntax-rules ()
    ((_ () b ...)
     (js-call (js-lambda/context () (js-context b ...))))
    ((_ ((x y) ...) b ...)
     (let ([x (js-declaration (symbol->string (quote x)))]
           ...
           [internal-c (new js-context%)])
       (send internal-c add-command: b)
       ...
       (define internal-f
         (new js-definition%
              [params (list x ...)]
              [context internal-c]))
       (js-call internal-f y ...)))))

(define-syntax js-let*
  (syntax-rules ()
    ((_ () b ...)
     (js-let () b ...))
    ((_ ([x y] [z w] ...) b ...)
     (cxt-query ((lambda ()
                   (define x y)
                   (define z w)
                   ...
                   b ...))))))

(define-syntax cxt-command
  (syntax-rules (define define/contract)

    ((_ c (define (f #:rest x) b ...))
     (let ((v (cxt-query
               (lambda ()
                 (define proto-slice (get-field slice (get-field prototype array)))
                 (define rest (send proto-slice call arguments 0))
                 ((lambda (x) b ...) rest)))))
       (send v unlimit-param!)
       (send f set-value: v)))

    ((_ c (define (f x ... #:rest y) b ...))
     (let ((v (cxt-query
               (lambda (x ...)
                 (define x-length (vector-length (vector x ...)))
                 (define prototype-slice (get-field slice (get-field prototype array)))
                 (define rest (send prototype-slice call arguments x-length))
                 (define args (vector x ... rest))
                 (send (lambda (x ... y) b ...) apply this args)))))
       (send v unlimit-param!)
       (send f set-value: v)))

    ((_ c (define (f x ...) b ...))
     (let ((v (cxt-query (lambda (x ...) b ...))))
       (send f set-value: v)))

    ((_ c (define (f) b ...))
     (let ((v (cxt-query (lambda () b ...))))
       (send f set-value: v)))

    ((_ c (define x y))
     (begin
       (define x (js-declaration (symbol->string (quote x)) (cxt-query y)))
       (send c add-command: x)))

    ((_ c (define/contract (f x ...) contract b ...))
     (let ((f-name (symbol->string (quote f)))
           (args (js-vector (js-lambda-param-helper2 x) ...)))
       (cxt-command c (define (f x ...)
                        (define func (get-field func contract))
                        (define (contracted x ...) b ...)
                        (func contracted f-name args)))))

    ((_ c (define/contract (f) contract b ...))
     (let ((f-name (symbol->string (quote f))))
       (cxt-command c (define (f)
                        (define func (get-field func contract))
                        (define (contracted) b ...)
                        (func contracted f-name (vector))))))

    ((_ c (define/contract f contract value))
     (begin
       (define f-name (symbol->string (quote f)))
       (define c-name (js-contract-helper contract))
       (define f
         (js-declaration
          (symbol->string (quote f))
          (cxt-query ((lambda (c v)
                        (if (contract? c)
                            ((get-field func c) v f-name)
                            ((get-field func (js-value-contract (vector c-name c))) v f-name)))
                      contract
                      value))))
       (send c add-command: f)))

    ((_ c x)
     (send c add-command: (cxt-query x)))))

(define-syntax cxt-query
  (syntax-rules (+
                 -
                 *
                 /
                 =
                 >
                 <
                 >=
                 <=
                 modulo
                 or
                 and
                 not
                 set!
                 bitwise-and
                 bitwise-ior
                 eq?
                 equal?
                 string=?
                 string?
                 vector?
                 number?
                 integer?
                 boolean?
                 even?
                 odd?
                 is-a?
                 lambda
                 let
                 let*
                 alert
                 display
                 displayln
                 delete
                 set-timeout
                 uri-encode
                 typeof
                 console
                 process
                 this
                 self
                 super
                 document
                 window
                 date
                 math
                 nan
                 nan?
                 object%
                 object?
                 event
                 custom-event
                 false
                 true
                 undefined
                 null
                 for
                 for/vector
                 for/first
                 string-append
                 substring
                 string-length
                 string-join
                 string-split
                 string-empty?
                 vector-fold
                 vector-map
                 vector-filter
                 vector-for-each
                 vector-member
                 vector
                 vector-append
                 vector-append!
                 vector-ref
                 vector-set!
                 vector-length
                 vector-empty?
                 vector-last
                 vector-flatten
                 hash
                 hash?
                 hash->string
                 string->hash
                 hash-ref
                 hash-set!
                 hash-copy
                 hash-remove!
                 if
                 cond
                 unless
                 when
                 new
                 make-object
                 send
                 get-field
                 set-field!
                 inject
                 require
                 provide
                 error
                 class
                 arguments
                 ->
                 ->v
                 ->m
                 >>
                 >>*
                 =>
                 l>
                 l>*
                 class/c
                 class?
                 or/c
                 and/c
                 false/c
                 true/c
                 any/c
                 procedure?
                 undefined?
                 void?
                 apply
                 void-contracts!
                 contract?
                 throw
                 array
                 json
                 hash-for-each
                 hash-for-each/key
                 while-loop
                 for-loop
                 for-loop/break
                 for-loop/final
                 for-loop/start
                 for-loop/only
                 make-number
                 parse-float
                 parse-int
                 try-catch)

    ;; from racket
    ((_ +) js-add)
    ((_ -) js-sub)
    ((_ *) js-mult)
    ((_ /) js-div)
    ((_ modulo) js-modulo)
    ((_ =) js-equal?)
    ((_ >) js-greater-than)
    ((_ <) js-less-than)
    ((_ <=) js-less-than/equal)
    ((_ >=) js-greater-than/equal)
    ((_ bitwise-and) js-bit-and)
    ((_ bitwise-ior) js-bit-or)
    ((_ or) js-or)
    ((_ and) js-and)
    ((_ eq?) js-eq?)
    ((_ not) js-not)
    ((_ even?) js-even?)
    ((_ odd?) js-odd?)
    ((_ equal?) js-equal?)
    ((_ string=?) js-equal?)
    ((_ display) js-display)
    ((_ displayln) js-displayln)
    ((_ uri-encode) js-encode-uri-component)
    ((_ is-a?) js-instanceof)
    ((_ string?) js-string?)
    ((_ number?) js-number?)
    ((_ string-append) js-add)
    ((_ substring) js-substring)
    ((_ string-length) js-vector-length)
    ((_ string-join) js-string-join)
    ((_ string-split) js-string-split)
    ((_ string-empty?) js-string-empty?)
    ((_ vector) js-vector)
    ((_ vector-ref) js-vector-ref)
    ((_ vector-set!) js-vector-set!)
    ((_ vector-length) js-vector-length)
    ((_ vector-empty?) js-vector-empty?)
    ((_ vector-last) js-vector-last)
    ((_ vector-append) js-vector-append)
    ((_ vector-flatten) js-vector-flatten)
    ((_ hash->string) js-hash->string)
    ((_ string->hash) js-string->hash)
    ((_ hash) js-hash)
    ((_ hash?) js-object?)
    ((_ hash-ref) js-hash-ref)
    ((_ hash-set!) js-hash-set!)
    ((_ hash-copy) js-hash-copy)
    ((_ vector-member) js-vector-member)
    ((_ nan?) js-nan?)
    ((_ nan) js-nan)
    ((_ date) js-date)
    ((_ false) js-false)
    ((_ true) js-true)
    ((_ null) js-null)
    ((_ undefined) js-undefined)
    ((_ object%) js-object%)
    ((_ error) js-throw-error)
    ((_ vector?) js-vector?)
    ((_ procedure?) js-procedure?)
    ((_ void?) js-undefined?)
    ((_ false/c) js-false/c)
    ((_ true/c) js-true/c)
    ((_ any/c) js-any/c)
    ((_ object?) js-object?)
    ((_ boolean?) js-boolean?)
    ((_ integer?) js-integer?)
    ((_ contract?) js-contract?)
    ((_ set!) js-set!)
    ((_ vector-fold) js-vector-fold)
    ((_ vector-map) js-vector-map)
    ((_ vector-filter) js-vector-filter)
    ((_ hash-for-each) js-hash-for-each)
    ((_ hash-remove!) js-hash-remove!)

    ;; from me
    ((_ self) js-self)
    ((_ void-contracts!) js-turn-off-contracts)
    ((_ vector-append!) js-vector-append!)
    ((_ vector-for-each) js-for-each)
    ((_ for-loop) js-for-loop)
    ((_ for-loop/break) js-for-loop/break)
    ((_ for-loop/final) js-for-loop/final)
    ((_ for-loop/only) js-for-loop/only)
    ((_ for-loop/start) js-for-loop/start)
    ((_ while-loop) js-while-loop)
    ((_ >>) js-pipe)
    ((_ >>*) js-async-pipe)

    ;; from javascript
    ((_ hash-for-each/key) js-hash-for-each/key)
    ((_ this) js-this)
    ((_ delete) js-delete)
    ((_ typeof) js-typeof)
    ((_ set-timeout) js-set-timeout)
    ((_ arguments) js-arguments)
    ((_ event) js-event)
    ((_ custom-event) js-custom-event)
    ((_ undefined?) js-undefined?)
    ((_ process) js-process)
    ((_ console) js-console)
    ((_ document) js-document)
    ((_ window) js-window)
    ((_ math) js-math)
    ((_ array) js-array)
    ((_ json) js-json)
    ((_ alert) js-alert)
    ((_ throw) js-throw)
    ((_ make-number) js-make-number)
    ((_ parse-float) js-parse-float)
    ((_ parse-int) js-parse-int)
    ((_ try-catch) js-try-catch)

    ;; complex
    ((_ (super id))
     (js-send (js-hash-ref (js-hash-ref js-super% "prototype") (symbol->string (quote id)))
              "apply"
              js-self
              (js-vector)))

    ((_ (super id param ...))
     (js-send (js-hash-ref (js-hash-ref js-super% "prototype") (symbol->string (quote id)))
              "apply"
              js-self
              (cxt-query param)
              ...))

    ((_ (hash-ref x y z))
     (js-let ([internal-access (js-hash-ref (cxt-query x) (cxt-query y))])
       (js-if (js-equal? js-undefined internal-access)
              (cxt-query z)
              internal-access)))

    ((_ (unless x y ...))
     (js-if (cxt-query x)
            js-null
            (js-send (js-lambda/context () (js-context y ...)) "apply" js-this (js-vector))))

    ((_ (when x y ...))
     (js-if (cxt-query x)
            (js-send (js-lambda/context () (js-context y ...)) "apply" js-this (js-vector))
            js-null))

    ((_ (if x y z))
     (js-if (cxt-query x) (cxt-query y) (cxt-query z)))

    ((_ (cond (x y ...) z ...))
     (js-if (cxt-query x)
            (js-send (js-lambda/context () (js-context y ...)) "apply" js-this (js-vector))
            (js-cond-helper z ...)))

    ((_ (new x))
     (js-new (cxt-query x) (js-hash/list '())))

    ((_ (new x [k v] ...))
     (js-new (cxt-query x) (js-hash/list (flatten (list (js-hash-helper k v) ...)))))

    ((_ (make-object x ...))
     (js-make-object (cxt-query x) ...))

    ((_ (send x y z ...))
     (js-send (cxt-query x) (symbol->string (quote y)) (cxt-query z)...))

    ((_ (get-field x y))
     (js-get-field (cxt-query y) (symbol->string (quote x))))

    ((_ (set-field! x y z))
     (js-set-field! (cxt-query y) (symbol->string (quote x)) (cxt-query z)))

    ((_ (for (x ...) b ...))
     (js-for (x ...) b ...))

    ((_ (for/vector (x ...) b ...))
     (js-for/vector (x ...) b ...))

    ((_ (for/first (x ...) b ...))
     (js-for/first (x ...) b ...))

    ((_ (inject x))
     (js-inject x))

    ((_ (require x))
     (js-require x))

    ((_ (provide x))
     (js-export (symbol->string (quote x))))

    ((_ (lambda (x ...) y ...))
     (js-lambda/context (x ...) (js-context y ...)))

    ((_ (lambda () y ...))
     (js-lambda/context () (js-context y ...)))

    ((_ (lambda x y ...))
     (cxt-query (lambda () (send (lambda (x) y ...) apply this (vector arguments)))))

    ((_ (=> (x ...) y ...))
     (js-lambda/context (x ...) (js-context y ...)))

    ((_ (=> () y ...))
     (js-lambda/context () (js-context y ...)))

    ((_ (=> x y ...))
     (cxt-query (lambda () (send (lambda (x) y ...) apply this (vector arguments)))))

    ((_ (l> v f ...))
     (js-call (js-call js-pipe (cxt-query f) ...) (cxt-query v)))

    ((_ (l>* v f ...))
     (js-call (js-call js-async-pipe (cxt-query f) ...) (cxt-query v)))

    ((_ (-> x ...))
     (js-call js-function-contract (js-vector (js-contract-helper x) (cxt-query x)) ...))

    ((_ (->m x ...))
     (js-call js-method-contract (js-vector (js-contract-helper x) (cxt-query x)) ...))

    ((_ (->v x))
     (js-call js-value-contract (js-vector (js-contract-helper x) (cxt-query x))))

    ((_ (class/c x ...))
     (js-call js-class-contract (js-vector (js-class-contract-helper x) ...)))

    ((_ (or/c x ...))
     (cxt-query (lambda (a) (or (x a) ...))))

    ((_ (and/c x ...))
     (cxt-query (lambda (a) (and (x a) ...))))

    ((_ (apply f x))
     (js-send (cxt-query f) "apply" js-this (cxt-query x)))

    ((_ (class x ...))
     (js-class x ...))

    ((_ (let ([x y] ...) z ...))
     (js-let ([x (cxt-query y)] ...) (cxt-query z) ...))

    ((_ (let () x ...))
     (js-let () (cxt-query x) ...))

    ((_ (let* ([x y] [z w] ...) b ...))
     (js-let* ([x y] [z w] ...) b ...))

    ((_ (f x ...))
     (js-call (cxt-query f) (cxt-query x) ...))

    ((_ x)
     x)))

(define-syntax js-class-cxt-commands
  (syntax-rules (init
                 super-new
                 inherit
                 inherit-field
                 field
                 init-field
                 define
                 define/contract
                 define/override
                 define/public)

    ((_ (field x ...))
     (begin
       (js-class-field-helper x)
       ...))

    ((_ (init-field x ...))
     (begin
       (js-class-init-field-helper x)
       ...))

    ((_ (init x ...))
     (begin
       (js-class-init-helper x)
       ...))

    ((_ (inherit n))
     (define n (js-public-method (symbol->string (quote n)) js-null)))

    ((_ (inherit-field n))
     (js-class-field-helper n))

    ((_ (define/public (n a ...) b ...))
     (set! n (js-public-method (symbol->string (quote n))
                               (cxt-query (lambda (a ...) (define self this) b ...)))))

    ((_ (define/public (n) b ...))
     (set! n (js-public-method (symbol->string (quote n))
                               (cxt-query (lambda () (define self this) b ...)))))

    ((_ (define/override (n a ...) b ...))
     (set! n (js-override-method (symbol->string (quote n))
                                 (cxt-query (lambda (a ...) (define self this) b ...)))))

    ((_ (define/override (n) b ...))
     (set! n (js-override-method (symbol->string (quote n))
                                 (cxt-query (lambda () (define self this) b ...)))))

    ((_ (define/contract (n a ...) contract b ...))
     (let ((f-name (symbol->string (quote n)))
           (args (js-vector (js-lambda-param-helper2 a) ...)))
       (set! n (js-private-method f-name
                                  (cxt-query (lambda (a ...)
                                               (define self this)
                                               (define func (get-field func contract))
                                               (define (contracted a ...) b ...)
                                               (func contracted f-name args)))))))

    ((_ (define/contract (n) contract b ...))
     (let ((f-name (symbol->string (quote n))))
       (set! n (js-private-method f-name
                                  (cxt-query (lambda ()
                                               (define self this)
                                               (define func (get-field func contract))
                                               (define (contracted) b ...)
                                               (func contracted f-name (vector))))))))

    ((_ (define (n a ...) b ...))
     (set! n (js-private-method (symbol->string (quote n))
                                (cxt-query (lambda (a ...) (define self this) b ...)))))

    ((_ (define (n) b ...))
     (set! n (js-private-method (symbol->string (quote n))
                                (cxt-query (lambda () (define self this) b ...)))))

    ((_ (define n v))
     (define n (js-private-field (symbol->string (quote n)) (cxt-query v))))

    ((_ x)
     '())))

(define-syntax js-class-binding
  (syntax-rules (init
                 super-new
                 field
                 init-field
                 define
                 define/override
                 define/public)

    ((_ (field x ...))
     (list (js-class-field-helper2 x)
           ...))

    ((_ (init-field x ...))
     (list (js-class-init-field-helper2 x)
           ...))

    ((_ (init x ...))
     (list (js-class-init-helper2 x)
           ...))

    ((_ (super-new)) (super-call))

    ((_ (super-new [k v] ...))
     (list (super-call)
           (js-parent-field (symbol->string (quote k)) (cxt-query v))
           ...))

    ((_ (define/public (n a ...) b ...)) n)
    ((_ (define/public (n) b ...)) n)
    ((_ (define/override (n a ...) b ...)) n)
    ((_ (define/override (n) b ...)) n)
    ((_ (define/contract (n a ...) b ...)) n)
    ((_ (define/contract (n) b ...)) n)
    ((_ (define (n a ...) b ...)) n)
    ((_ (define (n) b ...)) n)
    ((_ (define n b)) n)
    ((_ (inherit n)) '())
    ((_ (inherit-field n)) '())
    ((_ x) (cxt-query x))))

(define-syntax js-contract-helper
  (syntax-rules ()
    ((_ (x ...))
     (string-append (string-append (js-contract-helper x) " ") ...))
    ((_ x)
     (symbol->string (quote x)))))

(define-syntax js-class-contract-helper
  (syntax-rules ()
    ((_ [m c])
     (js-vector (symbol->string (quote m)) (cxt-query c)))))

(define-syntax js-for
  (syntax-rules ()
    ((_ (x ...) b ...)
     (let ()
       (js-for-param-declare x ...)
       (define params (flatten (list (js-for-param x ...))))
       (define arrays (flatten (list (js-for-array x ...))))
       (define keys (flatten (list (js-for-key x ...))))
       (define clauses (flatten (list (js-for-clause x ...))))
       (define keys-and-values
         (for/list ([k keys]
                    [c clauses])
           (list k (new js-definition% [params params] [context (js-context c)]))))
       (js-call js-for-each
                (new js-definition% [params params] [context (js-context b ...)])
                (js-vector/list arrays)
                (js-hash/list (flatten keys-and-values)))))))

(define-syntax js-for/vector
  (syntax-rules ()
    ((_ (x ...) b ...)
     (let ()
       (js-for-param-declare x ...)
       (define params (flatten (list (js-for-param x ...))))
       (define arrays (flatten (list (js-for-array x ...))))
       (define keys (flatten (list (js-for-key x ...))))
       (define clauses (flatten (list (js-for-clause x ...))))
       (define keys-and-values
         (for/list ([k keys]
                    [c clauses])
           (list k (new js-definition% [params params] [context (js-context c)]))))
       (js-call js-for-each/vector
                (new js-definition% [params params] [context (js-context b ...)])
                (js-vector/list arrays)
                (js-hash/list (flatten keys-and-values)))))))

(define-syntax js-for/first
  (syntax-rules ()
    ((_ (x ...) b ...)
     (let ()
       (js-for-param-declare x ...)
       (define params (flatten (list (js-for-param x ...))))
       (define arrays (flatten (list (js-for-array x ...))))
       (define keys (flatten (list (js-for-key x ...))))
       (define clauses (flatten (list (js-for-clause x ...))))
       (define keys-and-values
         (for/list ([k keys]
                    [c clauses])
           (list k (new js-definition% [params params] [context (js-context c)]))))
       (js-call js-for-each/first
                (new js-definition% [params params] [context (js-context b ...)])
                (js-vector/list arrays)
                (js-hash/list (flatten keys-and-values)))))))

(define-syntax js-for-key
  (syntax-rules ()
    ((_ #:when x y ...) (list "when" (js-for-key y ...)))
    ((_ #:unless x y ...) (list "unless" (js-for-key y ...)))
    ((_ #:final x y ...) (list "final" (js-for-key y ...)))
    ((_ #:break x y ...) (list "break" (js-for-key y ...)))
    ((_ #:when x) "when")
    ((_ #:unless x) "unless")
    ((_ #:final x) "final")
    ((_ #:break x) "break")
    ((_ x y ...) (js-for-key y ...))
    ((_ x) '())
    ((_) '())))

(define-syntax js-for-clause
  (syntax-rules ()
    ((_ #:when x y ...) (list (cxt-query x) (js-for-clause y ...)))
    ((_ #:unless x y ...) (list (cxt-query x) (js-for-clause y ...)))
    ((_ #:final x y ...) (list (cxt-query x) (js-for-clause y ...)))
    ((_ #:break x y ...) (list (cxt-query x) (js-for-clause y ...)))
    ((_ #:when x) (cxt-query x))
    ((_ #:unless x) (cxt-query x))
    ((_ #:final x) (cxt-query x))
    ((_ #:break x) (cxt-query x))
    ((_ x y ...) (js-for-clause y ...))
    ((_ x) '())
    ((_) '())))

(define-syntax js-for-param
  (syntax-rules ()
    ((_ #:when x y ...) (js-for-param y ...))
    ((_ #:unless x y ...) (js-for-param y ...))
    ((_ #:final x y ...) (js-for-param y ...))
    ((_ #:break x y ...) (js-for-param y ...))
    ((_ #:when x) '())
    ((_ #:unless x) '())
    ((_ #:final x) '())
    ((_ #:break x) '())
    ((_ [i arr] x ...) (list i (js-for-param x ...)))
    ((_ [i arr]) i)
    ((_ x) '())
    ((_) '())))

(define-syntax js-for-array
  (syntax-rules ()
    ((_ #:when x y ...) (js-for-array y ...))
    ((_ #:unless x y ...) (js-for-array y ...))
    ((_ #:final x y ...) (js-for-array y ...))
    ((_ #:break x y ...) (js-for-array y ...))
    ((_ #:when x) '())
    ((_ #:unless x) '())
    ((_ #:final x) '())
    ((_ #:break x) '())
    ((_ [i arr] x ...) (list (cxt-query arr) (js-for-array x ...)))
    ((_ [i arr]) (cxt-query arr))
    ((_ x) '())
    ((_) '())))

(define-syntax js-for-param-declare
  (syntax-rules ()
    ((_ #:when x y ...) (js-for-param-declare y ...))
    ((_ #:unless x y ...) (js-for-param-declare y ...))
    ((_ #:final x y ...) (js-for-param-declare y ...))
    ((_ #:break x y ...) (js-for-param-declare y ...))
    ((_ #:when x) '())
    ((_ #:unless x) '())
    ((_ #:final x) '())
    ((_ #:break x) '())
    ((_ [i arr] x ...)
     (begin
       (define i (js-declaration (symbol->string (quote i))))
       (js-for-param-declare x ...)))
    ((_ [i arr]) (define i (js-declaration (symbol->string (quote i)))))
    ((_ x) '())
    ((_) '())))

(define-syntax js-cond-helper
  (syntax-rules (else)
    ((_ [else x ...])
     (js-send (js-lambda/context () (js-context x ...)) "apply" js-this (js-vector)))
    ((_ [x y ...])
     (js-if (cxt-query x)
            (js-send (js-lambda/context () (js-context y ...)) "apply" js-this (js-vector))
            (js-base "null")))
    ((_ [x y ...] z ...)
     (js-if (cxt-query x)
            (js-send (js-lambda/context () (js-context y ...)) "apply" js-this (js-vector))
            (js-cond-helper z ...)))))

(define-syntax js-hash-helper
  (syntax-rules ()
    ((_ k v)
     (list (symbol->string (quote k)) (cxt-query v)))))

(define-syntax js-class-init-helper2
  (syntax-rules ()
    ((_ [o def-val])
     (js-optional-field (symbol->string (quote o)) (cxt-query def-val)))
    ((_ f)
     (js-init-field js-self (js-cleanse (symbol->string (quote f))) (symbol->string (quote f))))))

(define-syntax js-class-init-helper
  (syntax-rules ()
    ((_ [o def-val])
     (define o (js-init-field js-self
                              (js-cleanse (symbol->string (quote o)))
                              (symbol->string (quote o)))))
    ((_ f)
     (define f (js-init-field js-self
                              (js-cleanse (symbol->string (quote f)))
                              (symbol->string (quote f)))))))

(define-syntax js-class-field-helper2
  (syntax-rules ()
    ((_ [f val])
     (js-public-field (symbol->string (quote f)) (cxt-query val)))))

(define-syntax js-class-field-helper
  (syntax-rules ()
    ((_ [f val])
     (define f (js-class-field-helper2 [f val])))
    ((_ f)
     (define f (js-class-field-helper2 [f "inherited-field"])))))

(define-syntax js-class-init-field-helper2
  (syntax-rules ()
    ((_ f)
     (js-init-public-field (symbol->string (quote f))))))

(define-syntax js-class-init-field-helper
  (syntax-rules ()
    ((_ f)
     (define f (js-class-init-field-helper2 f)))))

(define-syntax js-lambda-param-helper
  (syntax-rules ()
    ((_ [o def])
     (define o (js-lambda-param-helper2 [o def])))
    ((_ p)
     (define p (js-lambda-param-helper2 p)))))

(define-syntax js-lambda-param-helper2
  (syntax-rules ()
    ((_ [o def])
     (js-optional-param (symbol->string (quote o)) (cxt-query def)))
    ((_ p)
     (js-declaration (symbol->string (quote p)) js-null))))
