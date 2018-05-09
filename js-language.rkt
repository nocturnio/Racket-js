#lang racket

(require "js-base.rkt")
(require "js-declaration.rkt")
(require "js-optional-param.rkt")
(require "js-comment.rkt")

(require "js-function.rkt")
(require "js-operator.rkt")
(require "js-accessor.rkt")
(require "js-definition.rkt")
(require "js-hash.rkt")
(require "js-context.rkt")
(require "js-export.rkt")
(require "js-module.rkt")
(require "js-conditional.rkt")
(require "js-array.rkt")
(require "js-class.rkt")
(require "js-statement.rkt")
(require "js-class-instance.rkt")

(require "js-public-field.rkt")
(require "js-parent-field.rkt")
(require "js-override-method.rkt")
(require "js-public-method.rkt")
(require "js-private-method.rkt")
(require "js-optional-field.rkt")
(require "js-private-field.rkt")
(require "js-init-field.rkt")
(require "js-init-public-field.rkt")

(require "js-callable.rkt")
(require "js-call.rkt")

(require "js-error.rkt")

(provide (all-defined-out)
         js-definition%
         js-context%
         js-function%
         js-class%

         js-call

         verify-module-exports

         js-public-method
         js-private-method
         js-override-method
         js-parent-field
         js-init-field
         js-optional-field
         js-public-field
         js-private-field
         js-init-public-field

         js-public-field?
         js-init-field?
         js-parent-field?
         js-optional-field?

         js-self-declare?

         js-optional-param
         js-optional-param?
         js-declaration
         js-declaration?
         js-base)

(define js-cleanse cleanse)

(define (js-self-declare? x)
  (and (js-declaration? x) (string=? (send x get-name) "self")))

(define/contract (js-make-object obj . args)
  (->* (js-base?) #:rest (listof param/c) js-function?)
  (js-new/list obj args))

(define/contract (js-new obj . args)
  (->* (js-base?) #:rest (listof js-base?) js-function?)
  (js-new/list obj args))

(define (js-new/list obj args)
  (define name (send obj get-name))
  (new js-class-instance%
       [class-type obj]
       [params args]
       [name (send obj get-name/safe)]))

(define/contract (js-require arg)
  (-> (or/c js-module? string? js-declaration?) js-base?)
  (if (string? arg)
      (js-call (js-function-callable "require") (cleanse arg))
      arg))

(define (js-inject name)
  (js-comment (string-append "###inject_key###" name "###inject_key###")))

(define (js-hash . args)
  (new js-hash% [params args]))

(define (js-vector . args)
  (js-vector/list args))

(define (js-vector/list args)
  (new js-array% [params args]))

(define (js-if cond then else)
  (new js-conditional% [params (list cond then else)]))

(define (js-export name)
  (new js-export% [name name]))

(define (js-hash/list args)
  (new js-hash% [params args]))

(define/contract (js-hash-ref a b)
  (-> js-base? param/c js-accessor?)
  (js-accessor a b))

(define/contract (js-hash-set! h k v)
  (-> js-base? param/c param/c js-assignment?)
  (js-call js-set! (js-hash-ref h k) v))

(define/contract (js-vector-set! vec pos v)
  (-> (or/c js-array? js-declaration? js-base?) param/c param/c js-assignment?)
  (js-call js-set! (js-vector-ref vec pos) v))

(define/contract (js-vector-ref vec pos)
  (-> (or/c js-array? js-declaration? js-base?) param/c js-accessor?)
  (js-accessor vec pos))

(define/contract (js-get-field a b)
  (-> param/c param/c js-accessor?)
  (js-accessor a b))

(define (js-set-field! h k v)
  (js-call js-set! (js-get-field h k) v))

(define/contract (js-send obj message . args)
  (->* (js-base? string?) #:rest (listof param/c) js-function?)
  (js-send/list obj message args))

(define (js-send/list obj message args)
  (define func (js-get-field obj message))
  (new js-function% [params args] [name (send func get-name/safe)]))

(define (js-module/context c)
  (define commands (send c get-commands))
  (define-values (exports contained) (partition js-export? commands))
  (define export-names (for/list ([e exports]) (send e get-name)))
  (define mapped-contained
    (for/list ([c contained])
      (define c-name (send c get-name))
      (if (and (member c-name export-names) (js-declaration? c))
          (js-call js-set! c (send c get-value))
          c)))
  (define closure-commands (append mapped-contained (list js-false)))
  (define closure-context (new js-context% [commands closure-commands]))
  (define closure-definition (new js-definition% [context closure-context]))
  (define closure (js-call closure-definition))
  (define export-values
    (for/list ([e exports])
      (define e-name (send e get-name))
      (define (match-pred c) (string=? e-name (send c get-name)))
      (define match (memf match-pred contained))
      (if match (car match) '())))
  (new js-module%
       [exports export-values]
       [commands (append exports (list closure))]))

(define (js-class/bindings bindings parent)
  (define public-methods (filter js-public-method? bindings))
  (define private-methods (filter js-private-method? bindings))
  (define override-methods (filter js-override-method? bindings))
  (define parent-fields (filter js-parent-field? bindings))
  (define optional-fields (filter js-optional-field? bindings))
  (define init-fields (filter js-init-field? bindings))
  (define public-fields (filter js-public-field? bindings))
  (define private-fields (filter js-private-field? bindings))
  (verify-superclass-init (filter super-call? bindings))
  (new js-class%
       [parent parent]
       [parent-fields parent-fields]
       [fields init-fields]
       [public-fields public-fields]
       [optional-fields optional-fields]
       [public-methods public-methods]
       [override-methods override-methods]
       [private-methods private-methods]
       [private-fields private-fields]))

(struct super-call ())

#| Direct Imports |#

;; literals
(define js-json (js-base "JSON"))
(define js-console (js-base "console"))
(define js-process (js-base "process"))
(define js-null (js-base "null"))
(define js-undefined (js-base "undefined"))
(define js-false (js-base "false"))
(define js-true (js-base "true"))
(define js-this (js-base "this"))
(define js-self (js-base "self"))
(define js-document (js-base "document"))
(define js-window (js-base "window"))
(define js-event (js-base "Event"))
(define js-custom-event (js-base "CustomEvent"))
(define js-math (js-base "Math"))
(define js-date (js-base "Date"))
(define js-array (js-base "Array"))
(define js-super% (js-base "_internal_parent"))
(define js-object% (js-base "Object"))
(define js-arguments (js-base "arguments"))
(define js-nan (js-base "NaN"))

;; operators
(define js-add (js-operator-callable "+"))
(define js-sub (js-operator-callable "-"))
(define js-mult (js-operator-callable "*"))
(define js-div (js-operator-callable "/"))
(define js-or (js-operator-callable "||"))
(define js-and (js-operator-callable "&&"))
(define js-equal? (js-operator-callable "==="))
(define js-eq? (js-operator-callable "=="))
(define js-greater-than (js-operator-callable ">"))
(define js-less-than (js-operator-callable "<"))
(define js-greater-than/equal (js-operator-callable ">="))
(define js-less-than/equal (js-operator-callable "<="))
(define js-bit-or (js-operator-callable "|"))
(define js-bit-and (js-operator-callable "&"))
(define js-modulo (js-operator-callable "%"))
(define js-instanceof (js-operator-callable " instanceof "))
(define js-set! (js-operator-callable "="))

;; functions
(define js-not (js-function-callable "!"))
(define js-alert (js-function-callable "alert"))
(define js-set-timeout (js-function-callable "setTimeout"))
(define js-nan? (js-function-callable "isNaN"))
(define js-encode-uri-component (js-function-callable "encodeURIComponent"))
(define js-delete (js-function-callable "delete"))
(define js-typeof (js-function-callable "typeof"))
(define js-parse-int (js-function-callable "parseInt"))
(define js-parse-float (js-function-callable "parseFloat"))
(define js-make-number (js-function-callable "Number"))
(define js-throw (js-statement-callable "throw"))

#| Extensions |#

;; inline
(define js-for-loop/break
  (js-function-callable "function(f,l,b){for(var i=0;i<l;i++){if(b(i))break;else f(i);}}"))
(define js-for-loop/final
  (js-function-callable "function(f,l,b){for(var i=0;i<l;i++){if(b(i)){f(i);break;}else f(i);}}"))
(define js-for-loop/only
  (js-function-callable "function(f,l,b){for(var i=0;i<l;i++){if(b(i)){f(i);break;}}}"))
(define js-for-loop (js-function-callable "function(f,l){for(var i=0;i<l;i++){f(i);}}"))
(define js-for-loop/start (js-function-callable "function(f,s,l){for(var i=s;i<l;i++){f(i);}}"))
(define js-hash-for-each (js-function-callable "function(h,f){for(var x in h){f(h[x]);}}"))
(define js-hash-for-each/key (js-function-callable "function(h,f){for(var x in h){f(x);}}"))
(define js-hash-remove! (js-function-callable "function(h,k){delete h[k];}"))
(define js-while-loop (js-function-callable "function(c,f){while(c()){f();}}"))
(define js-try-catch (js-function-callable "function(s,f){try{return s();}catch(e){return f(e);}}"))
(define js-pipe (js-function-callable "js_pipe"))
(define js-async-pipe (js-function-callable "js_pipe_async"))

;; basejs
(define js-undefined? (js-function-callable/safe "js-undefined?"))
(define js-display (js-function-callable/safe "js-display"))
(define js-displayln  (js-function-callable/safe "js-displayln"))
(define js-boolean? (js-function-callable/safe "js-boolean?"))
(define js-integer? (js-function-callable/safe "js-integer?"))
(define js-number? (js-function-callable/safe "js-number?"))
(define js-procedure? (js-function-callable/safe "js-procedure?"))
(define js-throw-error (js-function-callable/safe "js-error"))
(define js-even? (js-function-callable/safe "js-even?"))
(define js-odd? (js-function-callable/safe "js-odd?"))

;; forjs
(define js-for-each (js-function-callable/safe "js-for"))
(define js-for-each/vector (js-function-callable/safe "js-for/vector"))
(define js-for-each/first (js-function-callable/safe "js-for/first"))

;; stringjs
(define js-substring (js-function-callable/safe "js-substring"))
(define js-string? (js-function-callable/safe "js-string?"))
(define js-string-join (js-function-callable/safe "js-string-join"))
(define js-string-split (js-function-callable/safe "js-string-split"))
(define js-string-empty? (js-function-callable/safe "js-string-empty?"))

;; vectorjs
(define js-vector? (js-function-callable/safe "js-vector?"))
(define js-vector-member (js-function-callable/safe "js-vector-member"))
(define js-vector-length (js-function-callable/safe "js-vector-length"))
(define js-vector-append (js-function-callable/safe "js-vector-append"))
(define js-vector-append! (js-function-callable/safe "js-vector-append!"))
(define js-vector-last (js-function-callable/safe "js-vector-last"))
(define js-vector-map (js-function-callable/safe "js-vector-map"))
(define js-vector-filter (js-function-callable/safe "js-vector-filter"))
(define js-vector-fold (js-function-callable/safe "js-vector-fold"))
(define js-vector-flatten (js-function-callable/safe "js-vector-flatten"))
(define js-vector-empty? (js-function-callable/safe "js-vector-empty?"))

;; hashjs
(define js-hash->string (js-function-callable/safe "js-hash->string"))
(define js-string->hash (js-function-callable/safe "js-string->hash"))
(define js-hash-copy (js-function-callable/safe "js-hash-copy"))

;; classjs
(define js-object? (js-function-callable/safe "js-object?"))

;; contractjs
(define js-function-contract (js-function-callable/safe "js-function-contract"))
(define js-method-contract (js-function-callable/safe "js-method-contract"))
(define js-value-contract (js-function-callable/safe "js-value-contract"))
(define js-class-contract (js-function-callable/safe "js-class-contract"))
(define js-turn-off-contracts (js-function-callable/safe "js-turn-off-contracts"))
(define js-contract? (js-function-callable/safe "js-contract?"))
(define js-false/c (js-function-callable/safe "js-false/c"))
(define js-true/c (js-function-callable/safe "js-true/c"))
(define js-any/c (js-function-callable/safe "js-any/c"))
