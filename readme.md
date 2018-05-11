# Racket Js

Racket JS is a macro in Racket that compiles into javascript.
It allows us to write a module in standard Racket syntax that compiles into javascript.
JS modules can be manipulated as a Racket object.
We can also take advantage of the Racket package manager to install/maintain/build javascript projects.

### Prerequisites

__[Racket Language](https://racket-lang.org)__

<= Racket v6.10.1

Versions higher than v6.10.1 will most likely work, but have not been tested.

### Installing

#### Step 1.

__[Install Racket](https://racket-lang.org)__

#### Step 2.

Run

```
raco pkg install "/<path-to-project>/Racket-js"
```

## Using Racket-js

### hellojs module
``` scheme
#lang racket
(require js)

(module/js hellojs

  (provide hello-world)

  (define (hello-world)
    (displayln "HELLO WORLD"))

  )
```

### compiles to
``` javascript
var hello_world;
(function(){
    hello_world = function(){return js_displayln("HELLO WORLD");};
    return false;
})();
```

## Built With

* [Racket](https://racket-lang.org/)

## Contributing

Please read [CONTRIBUTING.md](https://github.com/nocturnio/Racket-js/blob/master/CODE_OF_CONDUCT.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

* **Allen Hsu** - __[github/allenhsu4390](https://github.com/allenhsu4390)__

See also the list of [contributors](https://github.com/nocturnio/Racket-js/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Projects using Racket Js

* __[Nocturn](https://nocturn.io)__

## Language Reference

racket-js is an incomplete implementation of Racket in javascript.

### List of available syntax forms from Racket
* define
* define/contract
* lambda
* class
* let
* let*
* for
* for/vector
* for/first
* if
* cond
* unless
* when
* new
* require
* provide
* ->
* ->v
* ->m
* =>
* class/c
* class?
* or/c
* and/c
* false/c
* true/c
* any/c

### List of symbols and keywords from Racket
* self - replaces **this** in Racket class syntax form
* super

### List of symbols and keywords from javascript
* this
* document
* window
* date
* math
* console
* process
* nan
* event
* custom-event
* object%
* false
* true
* undefined
* null
* arguments

### List of functions from Racket
* +
* -
* *
* /
* =
* >
* <
* >=
* <=
* >>
* modulo
* or
* and
* not
* set!
* bitwise-and
* bitwise-ior
* eq?
* equal?
* string=?

* number?
* integer?
* boolean?
* even?
* odd?
* is-a?
* nan?
* display
* displayln

* hash - hash compiles to json objects
* hash-for-each
* hash-for-each/key
* hash?
* hash->string
* string->hash
* hash-ref
* hash-set!
* hash-copy
* hash-remove!

* vector - vector compiles to javascript arrays
* vector?
* vector-fold
* vector-map
* vector-filter
* vector-for-each
* vector-member
* vector-append
* vector-append!
* vector-ref
* vector-set!
* vector-length
* vector-empty?
* vector-last
* vector-flatten

* string?
* string-append
* substring
* string-length
* string-join
* string-split
* string-empty?

* make-object - Racket class objects match with javascript objects
* object?
* send - equivalent to using class.method() in javascript
* get-field - equivalent to using class.property in javascript
* set-field!

* error
* void? - checks for undefined
* procedure?
* apply
* contract?

### List of functions from javascript
* alert
* delete
* set-timeout
* uri-encode
* typeof
* throw
* array
* json
* make-number
* parse-float
* parse-int
* try-catch
* undefined?

### List of custom syntax forms
* >>* - compose async
* l> - pipe
* l>* - pipe async
* while-loop
* for-loop
* for-loop/break
* for-loop/final
* for-loop/start
* for-loop/only

### List of custom functions
* void-contracts! - turns all contracts off