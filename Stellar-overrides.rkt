#lang racket

(provide overrides pub-priv-dict)

(define pub-priv-dict
  '(("GA57G3YN5GEA5AF7YI2ZMNCKKAOQNAPYGDDIAVGSH7ILWRET6Y76SEIP" . "SCYRMXBWVYYI2XAU5PJ6MDDEUVKNJGJJVQKEBZLS4WK6NL7OHKC6OBLP")
    ("GCNC3APR4XB64E7XADGU5JJFS7J2WYVJRKU73TYATQXW3LRSPGCIN2PJ" . "SAQ33Q6B22DXMYUXXYGUUIO56YBRAAY47KTYJ4J55MW5J3TYYZFU4N4J")
    ("GAWHIZOTTEDZDRPXIJPMPHPDPNW3NKSYMNJX7SMNCTMKATQQVX6VJFNV" . "SCI3M6F4CNX6A4RBPGZDJDYZGZSEF7ILYZJRT2FMXH3IYEQAHGYPWSBU")
    ("GBWLGFVBJVS45X45QBHJ5ZLQWJESZ55QCUZPJBYZTVPLUMJVSD2MAIA3" . "SDSZYX65YRIPDQZ22T75WL7IJWCOUZQJJOVG7ISKKDH3T7FCKDL5VBMY")
    ("GDXTUPQ2HTTVPZGQBOXRNPRYQ4T3NQP75JHOFAQ27WOD57OJM6IWPFTK" . "SDSTY4PKJVRCAUSD3KBCUX7Z6FJLPYERMBL5YJAYICZPEUN67PMUS3IB")
    ("GAA6PHYKE3N4YAWG2QQMT4WGQDEKPVVLZ3HMT5LFAUCJ4CYPP4FOKZM6" . "SCCXLDQOA6L5QG7ZEAECKIQYN2WQHHA2FAACA25NM6BP2O4USTOLUO3K")))

(define keys
  `(key-set ,@(dict-keys pub-priv-dict)))

; for testgen-test
#;(define overrides
  `((("Transaction" "operations") len . 1)
    (("TestLedger" "ledgerEntries") len . 1)
    (("TransactionV1Envelope" "signatures") len . 0) ; we'll sign later
    (("AccountEntry" "signers") len . 0) ; no extra signers for now
    ; TODO allow using a list, e.g. '(0 1) for 0 or 1 signers
    (("MuxedAccount" "ed25519") ,@keys)
    (("MuxedAccount" "med25519" "ed25519") ,@keys)
    (("PublicKey" "ed25519") ,@keys)
    (("SignerKey" "ed25519") ,@keys)))

; for the merge-sponsored demo
(define overrides
  ; here we configure the grammar generator
  `((("Transaction" "operations") len . 1) ; a single operation
    (("TestLedger" "ledgerEntries") len . 3) ; 3 ledger entries
    (("TransactionV1Envelope" "signatures") len . 0) ; no signatures at this point
    (("AccountEntry" "signers") len . 1) ; one extra signer
    (("AccountEntryExtensionV2" "signerSponsoringIDs") len . 1) ; must have one per signer
    (("MuxedAccount" "ed25519") ,@keys)
    (("MuxedAccount" "med25519" "ed25519") ,@keys)
    (("PublicKey" "ed25519") ,@keys)
    (("SignerKey" "ed25519") ,@keys)))
