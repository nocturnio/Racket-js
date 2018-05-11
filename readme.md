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
```
define
define/contract
lambda
class
let
let*
for
for/vector
for/first
if
cond
unless
when
new
require
provide
->
->v
->m
=>
class/c
class?
or/c
and/c
false/c
true/c
any/c
send
get-field
set-field!
```

### List of symbols and keywords from Racket
```
self
super
```

### List of symbols and keywords from javascript
```
this
document
window
date
math
console
process
nan
event
custom-event
object%
false
true
undefined
null
arguments
```

### List of functions from Racket
```
+
-
*
/
=
>
<
>=
<=
>>
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
```

```
number?
integer?
boolean?
even?
odd?
is-a?
nan?
void?
procedure?
contract?
```

```
hash
hash-for-each
hash-for-each/key
hash?
hash->string
string->hash
hash-ref
hash-set!
hash-copy
hash-remove!
```

```
vector
vector?
vector-fold
vector-map
vector-filter
vector-for-each
vector-member
vector-append
vector-append!
vector-ref
vector-set!
vector-length
vector-empty?
vector-last
vector-flatten
```

```
string?
string-append
substring
string-length
string-join
string-split
string-empty?
```

```
make-object
object?
```

```
error
apply
display
displayln
```

### List of functions from javascript
```
alert
delete
set-timeout
uri-encode
typeof
throw
array
json
make-number
parse-float
parse-int
try-catch
undefined?
```

### List of custom syntax forms
```
>>*
l>
l>*
while-loop
for-loop
for-loop/break
for-loop/final
for-loop/start
for-loop/only
```

### List of custom functions
```
void-contracts!
```

## Additional Information

send - equivalent to using class.method() in javascript

get-field - equivalent to using class.property in javascript

self - replaces **this** in Racket class syntax form

void? - checks for undefined

hash - hash compiles to json objects

vector - vector compiles to javascript arrays

object - Racket class objects match with javascript objects

display - maps to console.log

void-contracts! - turns all contracts off

```>>*``` - compose async

l> - pipe

l>* - pipe async