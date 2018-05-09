#lang racket

(require "modulejs.rkt")
(require "basejs.rkt")
(require "vectorjs.rkt")
(require "stringjs.rkt")
(require "hashjs.rkt")
(require "classjs.rkt")
(require "forjs.rkt")
(require "contractjs.rkt")

;; core
(provide js-base)
(provide module/js)

;; injections
(send basejs inject: "var js_pipe=function(){for(var n=arguments,r=0,t=function(n){return n},u=function(n,r){return function(t){return r(n(t))}};r<n.length;){var e=n[r];t=u(t,e),r++}return t};")
(send basejs inject: "var js_pipe_async=function(){var a=arguments;return function(b){var c=a.length,d=function(b,e){if(b==c)return e;var f=a[b],g=function(a){return d(b+1,a)};return f(e,g)};return d(0,b)}};")

;; extensions
(provide basejs)
(provide stringjs)
(provide classjs)
(provide hashjs)
(provide vectorjs)
(provide contractjs)
(provide forjs)
