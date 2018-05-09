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