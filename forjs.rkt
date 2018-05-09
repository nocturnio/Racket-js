#lang racket

(require "modulejs.rkt")

(provide forjs)

(module/js forjs

  (provide js-for)
  (provide js-for/vector)
  (provide js-for/first)

  (define for-loop/local for-loop)
  (define for-loop/break/local for-loop/break)
  (define for-loop/final/local for-loop/final)

  (define (js-for/first func seqs [clauses (hash)])
    (define rtn false)
    (define first-clause (or (hash-ref clauses "when")
                             (lambda x true)))
    (hash-set! clauses "final" first-clause)
    (js-for (lambda x (set! rtn (apply func x)))
            seqs
            clauses)
    rtn)

  (define (js-for/vector func seqs [clauses (hash)])
    (define rtn (vector))
    (js-for (lambda x (send rtn push (apply func x)))
            seqs
            clauses)
    rtn)

  (define (js-for func seqs [clauses (hash)])
    (define break-clause (hash-ref clauses "break"))
    (define final-clause (hash-ref clauses "final"))
    (define when-clause (hash-ref clauses "when"))
    (define unless-clause (hash-ref clauses "unless"))
    (define first (vector-ref seqs 0))
    (define length (or (get-field length first) first))
    (define loop-func
      (cond
        [when-clause
         (if (and when-clause unless-clause)
             (create-loop-func/when/unless func seqs when-clause unless-clause)
             (create-loop-func/when func seqs when-clause))]
        [unless-clause
         (create-loop-func/unless func seqs unless-clause)]
        [else
         (create-loop-func func seqs)]))
    (cond
      [break-clause
       (for-loop/break/local loop-func length (create-loop-func break-clause seqs))]
      [final-clause
       (for-loop/final/local loop-func length (create-loop-func final-clause seqs))]
      [else
       (for-loop/local loop-func length)]))

  (define (create-loop-func func seqs)
    (lambda (i)
      (define elements (vector))
      (define inner-loop-func (create-inner-loop seqs i elements))
      (for-loop/local inner-loop-func (get-field length seqs))
      (apply func elements)))

  (define (create-loop-func/when func seqs when-clause)
    (lambda (i)
      (define elements (vector))
      (define inner-loop-func (create-inner-loop seqs i elements))
      (for-loop/local inner-loop-func (get-field length seqs))
      (when (apply when-clause elements) (apply func elements))))

  (define (create-loop-func/unless func seqs unless-clause)
    (lambda (i)
      (define elements (vector))
      (define inner-loop-func (create-inner-loop seqs i elements))
      (for-loop/local inner-loop-func (get-field length seqs))
      (unless (apply unless-clause elements) (apply func elements))))

   (define (create-loop-func/when/unless func seqs when-clause unless-clause)
    (lambda (i)
      (define elements (vector))
      (define inner-loop-func (create-inner-loop seqs i elements))
      (for-loop/local inner-loop-func (get-field length seqs))
      (define when? (apply when-clause elements))
      (define unless? (apply unless-clause elements))
      (when (and when? (not unless?)) (apply func elements))))

  (define (create-inner-loop seqs i elements)
    (lambda (j)
      (define vec (vector-ref seqs j))
      (define ref (vector-ref vec i))
      (define current (if (undefined? ref) i ref))
      (vector-set! elements j current)))


  )
