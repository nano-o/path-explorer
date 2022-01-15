#lang rosette

(require racket/include)
(require (for-syntax syntax/parse racket/syntax) macro-debugger/stepper)

; We start with a set of macro that give meaning to a parse tree produced by guile-rpc

; a bitvector type needs a type predicate and a constructor
(define-syntax (make-bv-type stx)
  (syntax-parse stx
    [(_ name:string nbits:number)
     (with-syntax
         ([type-name (format-id #'name #:source #'name "~a" (syntax-e #'name))]
          [type-pred (format-id #'name #:source #'name "~a?" (syntax-e #'name))])
     #`(begin
         (define type-pred (bitvector nbits))
         (define (type-name val) (bv val type-pred))))]))

; enums are just 32-bit bitvectors
(define-syntax (make-enum stx)
  (syntax-parse stx
    [(_ name:string ([field0:string value0:number] ...)) ; NOTE must allow negative values
     (with-syntax
         ([nbits 32]
          [type-pred (format-id #'name #:source #'name "~a?" (syntax-e #'name))]
          [(member0 ...) (map (λ (f) (format-id #'name #:source f "~a-~a" (syntax-e #'name) (syntax-e f))) (syntax->list #'(field0 ...)))])
       ; NOTE: we need to prefix union-member names by the type name because it's a local scope according to the RFC
       #'(begin
           (define type-pred (bitvector nbits))
           (define member0 (bv value0 type-pred)) ...))]))

(define-syntax (define-type stx)
  (syntax-parse stx
    ; opaque fixe-length arrays
    [(_ typename:string ((~literal fixed-length-array) "opaque" nbits:nat))
     #'(make-bv-type typename nbits)]
    ; int
    [(_ typename:string "int")
     #'(make-bv-type typename 32)]
    ; unsigned int
    ; TODO: would be nice to remember it's unsigned and not allow signed operations
    [(_ typename:string "unsigned int")
     #'(make-bv-type typename 32)]
    ; hyper
    [(_ typename:string "hyper")
     #'(make-bv-type typename 64)]
    ; unsigned hyper
    [(_ typename:string "unsigned hyper")
     #'(make-bv-type typename 64)]
    ; enum
    [(_ typename:string ((~literal enum) [name0:string val0:number] ...))
     #'(make-enum typename ([name0 val0] ...))]))

#;(include (file "./Stellar.xdr.scm"))

; test
; TODO: should we normalize all names? probably yes.
(begin
  (define-type
    "Hash"
    (fixed-length-array "opaque" 32))
  (define-type "int32" "int")
  (define-type "uint64" "unsigned hyper")
  (define-type
      "CryptoKeyType"
      (enum ("KEY_TYPE_ED25519" 0)
            ("KEY_TYPE_PRE_AUTH_TX" 1)
            ("KEY_TYPE_HASH_X" 2)
            ("KEY_TYPE_MUXED_ED25519" 256)))

  (Hash 1)
  (int32 0)
  (uint64 0)
  CryptoKeyType?
  CryptoKeyType-KEY_TYPE_ED25519
  CryptoKeyType-KEY_TYPE_HASH_X)