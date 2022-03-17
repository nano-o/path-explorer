(define-type
  "Hash"
  (fixed-length-array "opaque" 32))
(define-type
  "uint256"
  (fixed-length-array "opaque" 32))
(define-type "uint32" "unsigned int")
(define-type "int32" "int")
(define-type "uint64" "unsigned hyper")
(define-type "int64" "hyper")
(define-type
  "CryptoKeyType"
  (enum ("KEY_TYPE_ED25519" 0)
        ("KEY_TYPE_PRE_AUTH_TX" 1)
        ("KEY_TYPE_HASH_X" 2)
        ("KEY_TYPE_MUXED_ED25519" 256)))
(define-type
  "PublicKeyType"
  (enum ("PUBLIC_KEY_TYPE_ED25519" 0)))
(define-type
  "SignerKeyType"
  (enum ("SIGNER_KEY_TYPE_ED25519" 0)
        ("SIGNER_KEY_TYPE_PRE_AUTH_TX" 1)
        ("SIGNER_KEY_TYPE_HASH_X" 2)))
(define-type
  "PublicKey"
  (union (case ("type" "PublicKeyType")
           (("PUBLIC_KEY_TYPE_ED25519")
            ("ed25519" "uint256")))))
(define-type
  "SignerKey"
  (union (case ("type" "SignerKeyType")
           (("SIGNER_KEY_TYPE_ED25519")
            ("ed25519" "uint256"))
           (("SIGNER_KEY_TYPE_PRE_AUTH_TX")
            ("preAuthTx" "uint256"))
           (("SIGNER_KEY_TYPE_HASH_X") ("hashX" "uint256")))))
(define-type
  "Signature"
  (variable-length-array "opaque" 64))
(define-type
  "SignatureHint"
  (fixed-length-array "opaque" 4))
(define-type "NodeID" "PublicKey")
(define-type
  "Curve25519Secret"
  (struct ("key" (fixed-length-array "opaque" 32))))
(define-type
  "Curve25519Public"
  (struct ("key" (fixed-length-array "opaque" 32))))
(define-type
  "HmacSha256Key"
  (struct ("key" (fixed-length-array "opaque" 32))))
(define-type
  "HmacSha256Mac"
  (struct ("mac" (fixed-length-array "opaque" 32))))
(define-type
  "Value"
  (variable-length-array "opaque" #f))
(define-type
  "SCPBallot"
  (struct ("counter" "uint32") ("value" "Value")))
(define-type
  "SCPStatementType"
  (enum ("SCP_ST_PREPARE" 0)
        ("SCP_ST_CONFIRM" 1)
        ("SCP_ST_EXTERNALIZE" 2)
        ("SCP_ST_NOMINATE" 3)))
(define-type
  "SCPNomination"
  (struct
    ("quorumSetHash" "Hash")
    ("votes" (variable-length-array "Value" #f))
    ("accepted" (variable-length-array "Value" #f))))
(define-type
  "SCPStatement"
  (struct
    ("nodeID" "NodeID")
    ("slotIndex" "uint64")
    ("pledges"
     (union (case ("type" "SCPStatementType")
              (("SCP_ST_PREPARE")
               ("prepare"
                (struct
                  ("quorumSetHash" "Hash")
                  ("ballot" "SCPBallot")
                  ("prepared"
                   (union (case ("opted" "bool")
                            (("TRUE") ("value" "SCPBallot"))
                            (("FALSE") "void"))))
                  ("preparedPrime"
                   (union (case ("opted" "bool")
                            (("TRUE") ("value" "SCPBallot"))
                            (("FALSE") "void"))))
                  ("nC" "uint32")
                  ("nH" "uint32"))))
              (("SCP_ST_CONFIRM")
               ("confirm"
                (struct
                  ("ballot" "SCPBallot")
                  ("nPrepared" "uint32")
                  ("nCommit" "uint32")
                  ("nH" "uint32")
                  ("quorumSetHash" "Hash"))))
              (("SCP_ST_EXTERNALIZE")
               ("externalize"
                (struct
                  ("commit" "SCPBallot")
                  ("nH" "uint32")
                  ("commitQuorumSetHash" "Hash"))))
              (("SCP_ST_NOMINATE")
               ("nominate" "SCPNomination")))))))
(define-type
  "SCPEnvelope"
  (struct
    ("statement" "SCPStatement")
    ("signature" "Signature")))
(define-type
  "SCPQuorumSet"
  (struct
    ("threshold" "uint32")
    ("validators"
     (variable-length-array "NodeID" #f))
    ("innerSets"
     (variable-length-array "SCPQuorumSet" #f))))
(define-type
  "UpgradeType"
  (variable-length-array "opaque" 128))
(define-type
  "StellarValueType"
  (enum ("STELLAR_VALUE_BASIC" 0)
        ("STELLAR_VALUE_SIGNED" 1)))
(define-type
  "LedgerCloseValueSignature"
  (struct
    ("nodeID" "NodeID")
    ("signature" "Signature")))
(define-type
  "StellarValue"
  (struct
    ("txSetHash" "Hash")
    ("closeTime" "TimePoint")
    ("upgrades"
     (variable-length-array "UpgradeType" 6))
    ("ext"
     (union (case ("v" "StellarValueType")
              (("STELLAR_VALUE_BASIC") "void")
              (("STELLAR_VALUE_SIGNED")
               ("lcValueSignature" "LedgerCloseValueSignature")))))))
(define-constant "MASK_LEDGER_HEADER_FLAGS" 7)
(define-type
  "LedgerHeaderFlags"
  (enum ("DISABLE_LIQUIDITY_POOL_TRADING_FLAG" 1)
        ("DISABLE_LIQUIDITY_POOL_DEPOSIT_FLAG" 2)
        ("DISABLE_LIQUIDITY_POOL_WITHDRAWAL_FLAG" 4)))
(define-type
  "LedgerHeaderExtensionV1"
  (struct
    ("flags" "uint32")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "LedgerHeader"
  (struct
    ("ledgerVersion" "uint32")
    ("previousLedgerHash" "Hash")
    ("scpValue" "StellarValue")
    ("txSetResultHash" "Hash")
    ("bucketListHash" "Hash")
    ("ledgerSeq" "uint32")
    ("totalCoins" "int64")
    ("feePool" "int64")
    ("inflationSeq" "uint32")
    ("idPool" "uint64")
    ("baseFee" "uint32")
    ("baseReserve" "uint32")
    ("maxTxSetSize" "uint32")
    ("skipList" (fixed-length-array "Hash" 4))
    ("ext"
     (union (case ("v" "int")
              ((0) "void")
              ((1) ("v1" "LedgerHeaderExtensionV1")))))))
(define-type
  "LedgerUpgradeType"
  (enum ("LEDGER_UPGRADE_VERSION" 1)
        ("LEDGER_UPGRADE_BASE_FEE" 2)
        ("LEDGER_UPGRADE_MAX_TX_SET_SIZE" 3)
        ("LEDGER_UPGRADE_BASE_RESERVE" 4)
        ("LEDGER_UPGRADE_FLAGS" 5)))
(define-type
  "LedgerUpgrade"
  (union (case ("type" "LedgerUpgradeType")
           (("LEDGER_UPGRADE_VERSION")
            ("newLedgerVersion" "uint32"))
           (("LEDGER_UPGRADE_BASE_FEE")
            ("newBaseFee" "uint32"))
           (("LEDGER_UPGRADE_MAX_TX_SET_SIZE")
            ("newMaxTxSetSize" "uint32"))
           (("LEDGER_UPGRADE_BASE_RESERVE")
            ("newBaseReserve" "uint32"))
           (("LEDGER_UPGRADE_FLAGS") ("newFlags" "uint32")))))
(define-type
  "BucketEntryType"
  (enum ("METAENTRY" -1)
        ("LIVEENTRY" 0)
        ("DEADENTRY" 1)
        ("INITENTRY" 2)))
(define-type
  "BucketMetadata"
  (struct
    ("ledgerVersion" "uint32")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "BucketEntry"
  (union (case ("type" "BucketEntryType")
           (("LIVEENTRY" "INITENTRY")
            ("liveEntry" "LedgerEntry"))
           (("DEADENTRY") ("deadEntry" "LedgerKey"))
           (("METAENTRY") ("metaEntry" "BucketMetadata")))))
(define-type
  "TransactionSet"
  (struct
    ("previousLedgerHash" "Hash")
    ("txs"
     (variable-length-array "TransactionEnvelope" #f))))
(define-type
  "TransactionResultPair"
  (struct
    ("transactionHash" "Hash")
    ("result" "TransactionResult")))
(define-type
  "TransactionResultSet"
  (struct
    ("results"
     (variable-length-array
       "TransactionResultPair"
       #f))))
(define-type
  "TransactionHistoryEntry"
  (struct
    ("ledgerSeq" "uint32")
    ("txSet" "TransactionSet")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "TransactionHistoryResultEntry"
  (struct
    ("ledgerSeq" "uint32")
    ("txResultSet" "TransactionResultSet")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "LedgerHeaderHistoryEntry"
  (struct
    ("hash" "Hash")
    ("header" "LedgerHeader")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "LedgerSCPMessages"
  (struct
    ("ledgerSeq" "uint32")
    ("messages"
     (variable-length-array "SCPEnvelope" #f))))
(define-type
  "SCPHistoryEntryV0"
  (struct
    ("quorumSets"
     (variable-length-array "SCPQuorumSet" #f))
    ("ledgerMessages" "LedgerSCPMessages")))
(define-type
  "SCPHistoryEntry"
  (union (case ("v" "int")
           ((0) ("v0" "SCPHistoryEntryV0")))))
(define-type
  "LedgerEntryChangeType"
  (enum ("LEDGER_ENTRY_CREATED" 0)
        ("LEDGER_ENTRY_UPDATED" 1)
        ("LEDGER_ENTRY_REMOVED" 2)
        ("LEDGER_ENTRY_STATE" 3)))
(define-type
  "LedgerEntryChange"
  (union (case ("type" "LedgerEntryChangeType")
           (("LEDGER_ENTRY_CREATED")
            ("created" "LedgerEntry"))
           (("LEDGER_ENTRY_UPDATED")
            ("updated" "LedgerEntry"))
           (("LEDGER_ENTRY_REMOVED")
            ("removed" "LedgerKey"))
           (("LEDGER_ENTRY_STATE") ("state" "LedgerEntry")))))
(define-type
  "LedgerEntryChanges"
  (variable-length-array "LedgerEntryChange" #f))
(define-type
  "OperationMeta"
  (struct ("changes" "LedgerEntryChanges")))
(define-type
  "TransactionMetaV1"
  (struct
    ("txChanges" "LedgerEntryChanges")
    ("operations"
     (variable-length-array "OperationMeta" #f))))
(define-type
  "TransactionMetaV2"
  (struct
    ("txChangesBefore" "LedgerEntryChanges")
    ("operations"
     (variable-length-array "OperationMeta" #f))
    ("txChangesAfter" "LedgerEntryChanges")))
(define-type
  "TransactionMeta"
  (union (case ("v" "int")
           ((0)
            ("operations"
             (variable-length-array "OperationMeta" #f)))
           ((1) ("v1" "TransactionMetaV1"))
           ((2) ("v2" "TransactionMetaV2")))))
(define-type
  "TransactionResultMeta"
  (struct
    ("result" "TransactionResultPair")
    ("feeProcessing" "LedgerEntryChanges")
    ("txApplyProcessing" "TransactionMeta")))
(define-type
  "UpgradeEntryMeta"
  (struct
    ("upgrade" "LedgerUpgrade")
    ("changes" "LedgerEntryChanges")))
(define-type
  "LedgerCloseMetaV0"
  (struct
    ("ledgerHeader" "LedgerHeaderHistoryEntry")
    ("txSet" "TransactionSet")
    ("txProcessing"
     (variable-length-array
       "TransactionResultMeta"
       #f))
    ("upgradesProcessing"
     (variable-length-array "UpgradeEntryMeta" #f))
    ("scpInfo"
     (variable-length-array "SCPHistoryEntry" #f))))
(define-type
  "LedgerCloseMeta"
  (union (case ("v" "int")
           ((0) ("v0" "LedgerCloseMetaV0")))))
(define-type "AccountID" "PublicKey")
(define-type
  "Thresholds"
  (fixed-length-array "opaque" 4))
(define-type "string32" (string 32))
(define-type "string64" (string 64))
(define-type "SequenceNumber" "int64")
(define-type "TimePoint" "uint64")
(define-type
  "DataValue"
  (variable-length-array "opaque" 64))
(define-type "PoolID" "Hash")
(define-type
  "AssetCode4"
  (fixed-length-array "opaque" 4))
(define-type
  "AssetCode12"
  (fixed-length-array "opaque" 12))
(define-type
  "AssetType"
  (enum ("ASSET_TYPE_NATIVE" 0)
        ("ASSET_TYPE_CREDIT_ALPHANUM4" 1)
        ("ASSET_TYPE_CREDIT_ALPHANUM12" 2)
        ("ASSET_TYPE_POOL_SHARE" 3)))
(define-type
  "AssetCode"
  (union (case ("type" "AssetType")
           (("ASSET_TYPE_CREDIT_ALPHANUM4")
            ("assetCode4" "AssetCode4"))
           (("ASSET_TYPE_CREDIT_ALPHANUM12")
            ("assetCode12" "AssetCode12")))))
(define-type
  "AlphaNum4"
  (struct
    ("assetCode" "AssetCode4")
    ("issuer" "AccountID")))
(define-type
  "AlphaNum12"
  (struct
    ("assetCode" "AssetCode12")
    ("issuer" "AccountID")))
(define-type
  "Asset"
  (union (case ("type" "AssetType")
           (("ASSET_TYPE_NATIVE") "void")
           (("ASSET_TYPE_CREDIT_ALPHANUM4")
            ("alphaNum4" "AlphaNum4"))
           (("ASSET_TYPE_CREDIT_ALPHANUM12")
            ("alphaNum12" "AlphaNum12")))))
(define-type
  "Price"
  (struct ("n" "int32") ("d" "int32")))
(define-type
  "Liabilities"
  (struct ("buying" "int64") ("selling" "int64")))
(define-type
  "ThresholdIndexes"
  (enum ("THRESHOLD_MASTER_WEIGHT" 0)
        ("THRESHOLD_LOW" 1)
        ("THRESHOLD_MED" 2)
        ("THRESHOLD_HIGH" 3)))
(define-type
  "LedgerEntryType"
  (enum ("ACCOUNT" 0)
        ("TRUSTLINE" 1)
        ("OFFER" 2)
        ("DATA" 3)
        ("CLAIMABLE_BALANCE" 4)
        ("LIQUIDITY_POOL" 5)))
(define-type
  "Signer"
  (struct ("key" "SignerKey") ("weight" "uint32")))
(define-type
  "AccountFlags"
  (enum ("AUTH_REQUIRED_FLAG" 1)
        ("AUTH_REVOCABLE_FLAG" 2)
        ("AUTH_IMMUTABLE_FLAG" 4)
        ("AUTH_CLAWBACK_ENABLED_FLAG" 8)))
(define-constant "MASK_ACCOUNT_FLAGS" 7)
(define-constant "MASK_ACCOUNT_FLAGS_V17" 15)
(define-constant "MAX_SIGNERS" 20)
(define-type
  "SponsorshipDescriptor"
  (union (case ("opted" "bool")
           (("TRUE") ("value" "AccountID"))
           (("FALSE") "void"))))
(define-type
  "AccountEntryExtensionV2"
  (struct
    ("numSponsored" "uint32")
    ("numSponsoring" "uint32")
    ("signerSponsoringIDs"
     (variable-length-array
       "SponsorshipDescriptor"
       "MAX_SIGNERS"))
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "AccountEntryExtensionV1"
  (struct
    ("liabilities" "Liabilities")
    ("ext"
     (union (case ("v" "int")
              ((0) "void")
              ((2) ("v2" "AccountEntryExtensionV2")))))))
(define-type
  "AccountEntry"
  (struct
    ("accountID" "AccountID")
    ("balance" "int64")
    ("seqNum" "SequenceNumber")
    ("numSubEntries" "uint32")
    ("inflationDest"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "AccountID"))
              (("FALSE") "void"))))
    ("flags" "uint32")
    ("homeDomain" "string32")
    ("thresholds" "Thresholds")
    ("signers"
     (variable-length-array "Signer" "MAX_SIGNERS"))
    ("ext"
     (union (case ("v" "int")
              ((0) "void")
              ((1) ("v1" "AccountEntryExtensionV1")))))))
(define-type
  "TrustLineFlags"
  (enum ("AUTHORIZED_FLAG" 1)
        ("AUTHORIZED_TO_MAINTAIN_LIABILITIES_FLAG" 2)
        ("TRUSTLINE_CLAWBACK_ENABLED_FLAG" 4)))
(define-constant "MASK_TRUSTLINE_FLAGS" 1)
(define-constant "MASK_TRUSTLINE_FLAGS_V13" 3)
(define-constant "MASK_TRUSTLINE_FLAGS_V17" 7)
(define-type
  "LiquidityPoolType"
  (enum ("LIQUIDITY_POOL_CONSTANT_PRODUCT" 0)))
(define-type
  "TrustLineAsset"
  (union (case ("type" "AssetType")
           (("ASSET_TYPE_NATIVE") "void")
           (("ASSET_TYPE_CREDIT_ALPHANUM4")
            ("alphaNum4" "AlphaNum4"))
           (("ASSET_TYPE_CREDIT_ALPHANUM12")
            ("alphaNum12" "AlphaNum12"))
           (("ASSET_TYPE_POOL_SHARE")
            ("liquidityPoolID" "PoolID")))))
(define-type
  "TrustLineEntryExtensionV2"
  (struct
    ("liquidityPoolUseCount" "int32")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "TrustLineEntry"
  (struct
    ("accountID" "AccountID")
    ("asset" "TrustLineAsset")
    ("balance" "int64")
    ("limit" "int64")
    ("flags" "uint32")
    ("ext"
     (union (case ("v" "int")
              ((0) "void")
              ((1)
               ("v1"
                (struct
                  ("liabilities" "Liabilities")
                  ("ext"
                   (union (case ("v" "int")
                            ((0) "void")
                            ((2) ("v2" "TrustLineEntryExtensionV2")))))))))))))
(define-type
  "OfferEntryFlags"
  (enum ("PASSIVE_FLAG" 1)))
(define-constant "MASK_OFFERENTRY_FLAGS" 1)
(define-type
  "OfferEntry"
  (struct
    ("sellerID" "AccountID")
    ("offerID" "int64")
    ("selling" "Asset")
    ("buying" "Asset")
    ("amount" "int64")
    ("price" "Price")
    ("flags" "uint32")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "DataEntry"
  (struct
    ("accountID" "AccountID")
    ("dataName" "string64")
    ("dataValue" "DataValue")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "ClaimPredicateType"
  (enum ("CLAIM_PREDICATE_UNCONDITIONAL" 0)
        ("CLAIM_PREDICATE_AND" 1)
        ("CLAIM_PREDICATE_OR" 2)
        ("CLAIM_PREDICATE_NOT" 3)
        ("CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME" 4)
        ("CLAIM_PREDICATE_BEFORE_RELATIVE_TIME" 5)))
(define-type
  "ClaimPredicate"
  (union (case ("type" "ClaimPredicateType")
           (("CLAIM_PREDICATE_UNCONDITIONAL") "void")
           (("CLAIM_PREDICATE_AND")
            ("andPredicates"
             (variable-length-array "ClaimPredicate" 2)))
           (("CLAIM_PREDICATE_OR")
            ("orPredicates"
             (variable-length-array "ClaimPredicate" 2)))
           (("CLAIM_PREDICATE_NOT")
            ("notPredicate"
             (union (case ("opted" "bool")
                      (("TRUE") ("value" "ClaimPredicate"))
                      (("FALSE") "void")))))
           (("CLAIM_PREDICATE_BEFORE_ABSOLUTE_TIME")
            ("absBefore" "int64"))
           (("CLAIM_PREDICATE_BEFORE_RELATIVE_TIME")
            ("relBefore" "int64")))))
(define-type
  "ClaimantType"
  (enum ("CLAIMANT_TYPE_V0" 0)))
(define-type
  "Claimant"
  (union (case ("type" "ClaimantType")
           (("CLAIMANT_TYPE_V0")
            ("v0"
             (struct
               ("destination" "AccountID")
               ("predicate" "ClaimPredicate")))))))
(define-type
  "ClaimableBalanceIDType"
  (enum ("CLAIMABLE_BALANCE_ID_TYPE_V0" 0)))
(define-type
  "ClaimableBalanceID"
  (union (case ("type" "ClaimableBalanceIDType")
           (("CLAIMABLE_BALANCE_ID_TYPE_V0") ("v0" "Hash")))))
(define-type
  "ClaimableBalanceFlags"
  (enum ("CLAIMABLE_BALANCE_CLAWBACK_ENABLED_FLAG" 1)))
(define-constant
  "MASK_CLAIMABLE_BALANCE_FLAGS"
  1)
(define-type
  "ClaimableBalanceEntryExtensionV1"
  (struct
    ("ext" (union (case ("v" "int") ((0) "void"))))
    ("flags" "uint32")))
(define-type
  "ClaimableBalanceEntry"
  (struct
    ("balanceID" "ClaimableBalanceID")
    ("claimants"
     (variable-length-array "Claimant" 10))
    ("asset" "Asset")
    ("amount" "int64")
    ("ext"
     (union (case ("v" "int")
              ((0) "void")
              ((1) ("v1" "ClaimableBalanceEntryExtensionV1")))))))
(define-type
  "LiquidityPoolConstantProductParameters"
  (struct
    ("assetA" "Asset")
    ("assetB" "Asset")
    ("fee" "int32")))
(define-type
  "LiquidityPoolEntry"
  (struct
    ("liquidityPoolID" "PoolID")
    ("body"
     (union (case ("type" "LiquidityPoolType")
              (("LIQUIDITY_POOL_CONSTANT_PRODUCT")
               ("constantProduct"
                (struct
                  ("params"
                   "LiquidityPoolConstantProductParameters")
                  ("reserveA" "int64")
                  ("reserveB" "int64")
                  ("totalPoolShares" "int64")
                  ("poolSharesTrustLineCount" "int64")))))))))
(define-type
  "LedgerEntryExtensionV1"
  (struct
    ("sponsoringID" "SponsorshipDescriptor")
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "LedgerEntry"
  (struct
    ("lastModifiedLedgerSeq" "uint32")
    ("data"
     (union (case ("type" "LedgerEntryType")
              (("ACCOUNT") ("account" "AccountEntry"))
              (("TRUSTLINE") ("trustLine" "TrustLineEntry"))
              (("OFFER") ("offer" "OfferEntry"))
              (("DATA") ("data" "DataEntry"))
              (("CLAIMABLE_BALANCE")
               ("claimableBalance" "ClaimableBalanceEntry"))
              (("LIQUIDITY_POOL")
               ("liquidityPool" "LiquidityPoolEntry")))))
    ("ext"
     (union (case ("v" "int")
              ((0) "void")
              ((1) ("v1" "LedgerEntryExtensionV1")))))))
(define-type
  "LedgerKey"
  (union (case ("type" "LedgerEntryType")
           (("ACCOUNT")
            ("account" (struct ("accountID" "AccountID"))))
           (("TRUSTLINE")
            ("trustLine"
             (struct
               ("accountID" "AccountID")
               ("asset" "TrustLineAsset"))))
           (("OFFER")
            ("offer"
             (struct
               ("sellerID" "AccountID")
               ("offerID" "int64"))))
           (("DATA")
            ("data"
             (struct
               ("accountID" "AccountID")
               ("dataName" "string64"))))
           (("CLAIMABLE_BALANCE")
            ("claimableBalance"
             (struct ("balanceID" "ClaimableBalanceID"))))
           (("LIQUIDITY_POOL")
            ("liquidityPool"
             (struct ("liquidityPoolID" "PoolID")))))))
(define-type
  "EnvelopeType"
  (enum ("ENVELOPE_TYPE_TX_V0" 0)
        ("ENVELOPE_TYPE_SCP" 1)
        ("ENVELOPE_TYPE_TX" 2)
        ("ENVELOPE_TYPE_AUTH" 3)
        ("ENVELOPE_TYPE_SCPVALUE" 4)
        ("ENVELOPE_TYPE_TX_FEE_BUMP" 5)
        ("ENVELOPE_TYPE_OP_ID" 6)
        ("ENVELOPE_TYPE_POOL_REVOKE_OP_ID" 7)))
(define-type
  "LiquidityPoolParameters"
  (union (case ("type" "LiquidityPoolType")
           (("LIQUIDITY_POOL_CONSTANT_PRODUCT")
            ("constantProduct"
             "LiquidityPoolConstantProductParameters")))))
(define-type
  "MuxedAccount"
  (union (case ("type" "CryptoKeyType")
           (("KEY_TYPE_ED25519") ("ed25519" "uint256"))
           (("KEY_TYPE_MUXED_ED25519")
            ("med25519"
             (struct ("id" "uint64") ("ed25519" "uint256")))))))
(define-type
  "DecoratedSignature"
  (struct
    ("hint" "SignatureHint")
    ("signature" "Signature")))
(define-type
  "OperationType"
  (enum ("CREATE_ACCOUNT" 0)
        ("PAYMENT" 1)
        ("PATH_PAYMENT_STRICT_RECEIVE" 2)
        ("MANAGE_SELL_OFFER" 3)
        ("CREATE_PASSIVE_SELL_OFFER" 4)
        ("SET_OPTIONS" 5)
        ("CHANGE_TRUST" 6)
        ("ALLOW_TRUST" 7)
        ("ACCOUNT_MERGE" 8)
        ("INFLATION" 9)
        ("MANAGE_DATA" 10)
        ("BUMP_SEQUENCE" 11)
        ("MANAGE_BUY_OFFER" 12)
        ("PATH_PAYMENT_STRICT_SEND" 13)
        ("CREATE_CLAIMABLE_BALANCE" 14)
        ("CLAIM_CLAIMABLE_BALANCE" 15)
        ("BEGIN_SPONSORING_FUTURE_RESERVES" 16)
        ("END_SPONSORING_FUTURE_RESERVES" 17)
        ("REVOKE_SPONSORSHIP" 18)
        ("CLAWBACK" 19)
        ("CLAWBACK_CLAIMABLE_BALANCE" 20)
        ("SET_TRUST_LINE_FLAGS" 21)
        ("LIQUIDITY_POOL_DEPOSIT" 22)
        ("LIQUIDITY_POOL_WITHDRAW" 23)))
(define-type
  "CreateAccountOp"
  (struct
    ("destination" "AccountID")
    ("startingBalance" "int64")))
(define-type
  "PaymentOp"
  (struct
    ("destination" "MuxedAccount")
    ("asset" "Asset")
    ("amount" "int64")))
(define-type
  "PathPaymentStrictReceiveOp"
  (struct
    ("sendAsset" "Asset")
    ("sendMax" "int64")
    ("destination" "MuxedAccount")
    ("destAsset" "Asset")
    ("destAmount" "int64")
    ("path" (variable-length-array "Asset" 5))))
(define-type
  "PathPaymentStrictSendOp"
  (struct
    ("sendAsset" "Asset")
    ("sendAmount" "int64")
    ("destination" "MuxedAccount")
    ("destAsset" "Asset")
    ("destMin" "int64")
    ("path" (variable-length-array "Asset" 5))))
(define-type
  "ManageSellOfferOp"
  (struct
    ("selling" "Asset")
    ("buying" "Asset")
    ("amount" "int64")
    ("price" "Price")
    ("offerID" "int64")))
(define-type
  "ManageBuyOfferOp"
  (struct
    ("selling" "Asset")
    ("buying" "Asset")
    ("buyAmount" "int64")
    ("price" "Price")
    ("offerID" "int64")))
(define-type
  "CreatePassiveSellOfferOp"
  (struct
    ("selling" "Asset")
    ("buying" "Asset")
    ("amount" "int64")
    ("price" "Price")))
(define-type
  "SetOptionsOp"
  (struct
    ("inflationDest"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "AccountID"))
              (("FALSE") "void"))))
    ("clearFlags"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "uint32"))
              (("FALSE") "void"))))
    ("setFlags"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "uint32"))
              (("FALSE") "void"))))
    ("masterWeight"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "uint32"))
              (("FALSE") "void"))))
    ("lowThreshold"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "uint32"))
              (("FALSE") "void"))))
    ("medThreshold"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "uint32"))
              (("FALSE") "void"))))
    ("highThreshold"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "uint32"))
              (("FALSE") "void"))))
    ("homeDomain"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "string32"))
              (("FALSE") "void"))))
    ("signer"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "Signer"))
              (("FALSE") "void"))))))
(define-type
  "ChangeTrustAsset"
  (union (case ("type" "AssetType")
           (("ASSET_TYPE_NATIVE") "void")
           (("ASSET_TYPE_CREDIT_ALPHANUM4")
            ("alphaNum4" "AlphaNum4"))
           (("ASSET_TYPE_CREDIT_ALPHANUM12")
            ("alphaNum12" "AlphaNum12"))
           (("ASSET_TYPE_POOL_SHARE")
            ("liquidityPool" "LiquidityPoolParameters")))))
(define-type
  "ChangeTrustOp"
  (struct
    ("line" "ChangeTrustAsset")
    ("limit" "int64")))
(define-type
  "AllowTrustOp"
  (struct
    ("trustor" "AccountID")
    ("asset" "AssetCode")
    ("authorize" "uint32")))
(define-type
  "ManageDataOp"
  (struct
    ("dataName" "string64")
    ("dataValue"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "DataValue"))
              (("FALSE") "void"))))))
(define-type
  "BumpSequenceOp"
  (struct ("bumpTo" "SequenceNumber")))
(define-type
  "CreateClaimableBalanceOp"
  (struct
    ("asset" "Asset")
    ("amount" "int64")
    ("claimants"
     (variable-length-array "Claimant" 10))))
(define-type
  "ClaimClaimableBalanceOp"
  (struct ("balanceID" "ClaimableBalanceID")))
(define-type
  "BeginSponsoringFutureReservesOp"
  (struct ("sponsoredID" "AccountID")))
(define-type
  "RevokeSponsorshipType"
  (enum ("REVOKE_SPONSORSHIP_LEDGER_ENTRY" 0)
        ("REVOKE_SPONSORSHIP_SIGNER" 1)))
(define-type
  "RevokeSponsorshipOp"
  (union (case ("type" "RevokeSponsorshipType")
           (("REVOKE_SPONSORSHIP_LEDGER_ENTRY")
            ("ledgerKey" "LedgerKey"))
           (("REVOKE_SPONSORSHIP_SIGNER")
            ("signer"
             (struct
               ("accountID" "AccountID")
               ("signerKey" "SignerKey")))))))
(define-type
  "ClawbackOp"
  (struct
    ("asset" "Asset")
    ("from" "MuxedAccount")
    ("amount" "int64")))
(define-type
  "ClawbackClaimableBalanceOp"
  (struct ("balanceID" "ClaimableBalanceID")))
(define-type
  "SetTrustLineFlagsOp"
  (struct
    ("trustor" "AccountID")
    ("asset" "Asset")
    ("clearFlags" "uint32")
    ("setFlags" "uint32")))
(define-constant "LIQUIDITY_POOL_FEE_V18" 30)
(define-type
  "LiquidityPoolDepositOp"
  (struct
    ("liquidityPoolID" "PoolID")
    ("maxAmountA" "int64")
    ("maxAmountB" "int64")
    ("minPrice" "Price")
    ("maxPrice" "Price")))
(define-type
  "LiquidityPoolWithdrawOp"
  (struct
    ("liquidityPoolID" "PoolID")
    ("amount" "int64")
    ("minAmountA" "int64")
    ("minAmountB" "int64")))
(define-type
  "Operation"
  (struct
    ("sourceAccount"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "MuxedAccount"))
              (("FALSE") "void"))))
    ("body"
     (union (case ("type" "OperationType")
              (("CREATE_ACCOUNT")
               ("createAccountOp" "CreateAccountOp"))
              (("PAYMENT") ("paymentOp" "PaymentOp"))
              (("PATH_PAYMENT_STRICT_RECEIVE")
               ("pathPaymentStrictReceiveOp"
                "PathPaymentStrictReceiveOp"))
              (("MANAGE_SELL_OFFER")
               ("manageSellOfferOp" "ManageSellOfferOp"))
              (("CREATE_PASSIVE_SELL_OFFER")
               ("createPassiveSellOfferOp"
                "CreatePassiveSellOfferOp"))
              (("SET_OPTIONS") ("setOptionsOp" "SetOptionsOp"))
              (("CHANGE_TRUST")
               ("changeTrustOp" "ChangeTrustOp"))
              (("ALLOW_TRUST") ("allowTrustOp" "AllowTrustOp"))
              (("ACCOUNT_MERGE")
               ("destination" "MuxedAccount"))
              (("INFLATION") "void")
              (("MANAGE_DATA") ("manageDataOp" "ManageDataOp"))
              (("BUMP_SEQUENCE")
               ("bumpSequenceOp" "BumpSequenceOp"))
              (("MANAGE_BUY_OFFER")
               ("manageBuyOfferOp" "ManageBuyOfferOp"))
              (("PATH_PAYMENT_STRICT_SEND")
               ("pathPaymentStrictSendOp"
                "PathPaymentStrictSendOp"))
              (("CREATE_CLAIMABLE_BALANCE")
               ("createClaimableBalanceOp"
                "CreateClaimableBalanceOp"))
              (("CLAIM_CLAIMABLE_BALANCE")
               ("claimClaimableBalanceOp"
                "ClaimClaimableBalanceOp"))
              (("BEGIN_SPONSORING_FUTURE_RESERVES")
               ("beginSponsoringFutureReservesOp"
                "BeginSponsoringFutureReservesOp"))
              (("END_SPONSORING_FUTURE_RESERVES") "void")
              (("REVOKE_SPONSORSHIP")
               ("revokeSponsorshipOp" "RevokeSponsorshipOp"))
              (("CLAWBACK") ("clawbackOp" "ClawbackOp"))
              (("CLAWBACK_CLAIMABLE_BALANCE")
               ("clawbackClaimableBalanceOp"
                "ClawbackClaimableBalanceOp"))
              (("SET_TRUST_LINE_FLAGS")
               ("setTrustLineFlagsOp" "SetTrustLineFlagsOp"))
              (("LIQUIDITY_POOL_DEPOSIT")
               ("liquidityPoolDepositOp"
                "LiquidityPoolDepositOp"))
              (("LIQUIDITY_POOL_WITHDRAW")
               ("liquidityPoolWithdrawOp"
                "LiquidityPoolWithdrawOp")))))))
(define-type
  "HashIDPreimage"
  (union (case ("type" "EnvelopeType")
           (("ENVELOPE_TYPE_OP_ID")
            ("operationID"
             (struct
               ("sourceAccount" "AccountID")
               ("seqNum" "SequenceNumber")
               ("opNum" "uint32"))))
           (("ENVELOPE_TYPE_POOL_REVOKE_OP_ID")
            ("revokeID"
             (struct
               ("sourceAccount" "AccountID")
               ("seqNum" "SequenceNumber")
               ("opNum" "uint32")
               ("liquidityPoolID" "PoolID")
               ("asset" "Asset")))))))
(define-type
  "MemoType"
  (enum ("MEMO_NONE" 0)
        ("MEMO_TEXT" 1)
        ("MEMO_ID" 2)
        ("MEMO_HASH" 3)
        ("MEMO_RETURN" 4)))
(define-type
  "Memo"
  (union (case ("type" "MemoType")
           (("MEMO_NONE") "void")
           (("MEMO_TEXT") ("text" (string 28)))
           (("MEMO_ID") ("id" "uint64"))
           (("MEMO_HASH") ("hash" "Hash"))
           (("MEMO_RETURN") ("retHash" "Hash")))))
(define-type
  "TimeBounds"
  (struct
    ("minTime" "TimePoint")
    ("maxTime" "TimePoint")))
(define-constant "MAX_OPS_PER_TX" 100)
(define-type
  "TransactionV0"
  (struct
    ("sourceAccountEd25519" "uint256")
    ("fee" "uint32")
    ("seqNum" "SequenceNumber")
    ("timeBounds"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "TimeBounds"))
              (("FALSE") "void"))))
    ("memo" "Memo")
    ("operations"
     (variable-length-array
       "Operation"
       "MAX_OPS_PER_TX"))
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "TransactionV0Envelope"
  (struct
    ("tx" "TransactionV0")
    ("signatures"
     (variable-length-array "DecoratedSignature" 20))))
(define-type
  "Transaction"
  (struct
    ("sourceAccount" "MuxedAccount")
    ("fee" "uint32")
    ("seqNum" "SequenceNumber")
    ("timeBounds"
     (union (case ("opted" "bool")
              (("TRUE") ("value" "TimeBounds"))
              (("FALSE") "void"))))
    ("memo" "Memo")
    ("operations"
     (variable-length-array
       "Operation"
       "MAX_OPS_PER_TX"))
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "TransactionV1Envelope"
  (struct
    ("tx" "Transaction")
    ("signatures"
     (variable-length-array "DecoratedSignature" 20))))
(define-type
  "FeeBumpTransaction"
  (struct
    ("feeSource" "MuxedAccount")
    ("fee" "int64")
    ("innerTx"
     (union (case ("type" "EnvelopeType")
              (("ENVELOPE_TYPE_TX")
               ("v1" "TransactionV1Envelope")))))
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "FeeBumpTransactionEnvelope"
  (struct
    ("tx" "FeeBumpTransaction")
    ("signatures"
     (variable-length-array "DecoratedSignature" 20))))
(define-type
  "TransactionEnvelope"
  (union (case ("type" "EnvelopeType")
           (("ENVELOPE_TYPE_TX_V0")
            ("v0" "TransactionV0Envelope"))
           (("ENVELOPE_TYPE_TX")
            ("v1" "TransactionV1Envelope"))
           (("ENVELOPE_TYPE_TX_FEE_BUMP")
            ("feeBump" "FeeBumpTransactionEnvelope")))))
(define-type
  "TransactionSignaturePayload"
  (struct
    ("networkId" "Hash")
    ("taggedTransaction"
     (union (case ("type" "EnvelopeType")
              (("ENVELOPE_TYPE_TX") ("tx" "Transaction"))
              (("ENVELOPE_TYPE_TX_FEE_BUMP")
               ("feeBump" "FeeBumpTransaction")))))))
(define-type
  "ClaimAtomType"
  (enum ("CLAIM_ATOM_TYPE_V0" 0)
        ("CLAIM_ATOM_TYPE_ORDER_BOOK" 1)
        ("CLAIM_ATOM_TYPE_LIQUIDITY_POOL" 2)))
(define-type
  "ClaimOfferAtomV0"
  (struct
    ("sellerEd25519" "uint256")
    ("offerID" "int64")
    ("assetSold" "Asset")
    ("amountSold" "int64")
    ("assetBought" "Asset")
    ("amountBought" "int64")))
(define-type
  "ClaimOfferAtom"
  (struct
    ("sellerID" "AccountID")
    ("offerID" "int64")
    ("assetSold" "Asset")
    ("amountSold" "int64")
    ("assetBought" "Asset")
    ("amountBought" "int64")))
(define-type
  "ClaimLiquidityAtom"
  (struct
    ("liquidityPoolID" "PoolID")
    ("assetSold" "Asset")
    ("amountSold" "int64")
    ("assetBought" "Asset")
    ("amountBought" "int64")))
(define-type
  "ClaimAtom"
  (union (case ("type" "ClaimAtomType")
           (("CLAIM_ATOM_TYPE_V0")
            ("v0" "ClaimOfferAtomV0"))
           (("CLAIM_ATOM_TYPE_ORDER_BOOK")
            ("orderBook" "ClaimOfferAtom"))
           (("CLAIM_ATOM_TYPE_LIQUIDITY_POOL")
            ("liquidityPool" "ClaimLiquidityAtom")))))
(define-type
  "CreateAccountResultCode"
  (enum ("CREATE_ACCOUNT_SUCCESS" 0)
        ("CREATE_ACCOUNT_MALFORMED" -1)
        ("CREATE_ACCOUNT_UNDERFUNDED" -2)
        ("CREATE_ACCOUNT_LOW_RESERVE" -3)
        ("CREATE_ACCOUNT_ALREADY_EXIST" -4)))
(define-type
  "CreateAccountResult"
  (union (case ("code" "CreateAccountResultCode")
           (("CREATE_ACCOUNT_SUCCESS") "void")
           (else "void"))))
(define-type
  "PaymentResultCode"
  (enum ("PAYMENT_SUCCESS" 0)
        ("PAYMENT_MALFORMED" -1)
        ("PAYMENT_UNDERFUNDED" -2)
        ("PAYMENT_SRC_NO_TRUST" -3)
        ("PAYMENT_SRC_NOT_AUTHORIZED" -4)
        ("PAYMENT_NO_DESTINATION" -5)
        ("PAYMENT_NO_TRUST" -6)
        ("PAYMENT_NOT_AUTHORIZED" -7)
        ("PAYMENT_LINE_FULL" -8)
        ("PAYMENT_NO_ISSUER" -9)))
(define-type
  "PaymentResult"
  (union (case ("code" "PaymentResultCode")
           (("PAYMENT_SUCCESS") "void")
           (else "void"))))
(define-type
  "PathPaymentStrictReceiveResultCode"
  (enum ("PATH_PAYMENT_STRICT_RECEIVE_SUCCESS" 0)
        ("PATH_PAYMENT_STRICT_RECEIVE_MALFORMED" -1)
        ("PATH_PAYMENT_STRICT_RECEIVE_UNDERFUNDED" -2)
        ("PATH_PAYMENT_STRICT_RECEIVE_SRC_NO_TRUST" -3)
        ("PATH_PAYMENT_STRICT_RECEIVE_SRC_NOT_AUTHORIZED"
         -4)
        ("PATH_PAYMENT_STRICT_RECEIVE_NO_DESTINATION" -5)
        ("PATH_PAYMENT_STRICT_RECEIVE_NO_TRUST" -6)
        ("PATH_PAYMENT_STRICT_RECEIVE_NOT_AUTHORIZED" -7)
        ("PATH_PAYMENT_STRICT_RECEIVE_LINE_FULL" -8)
        ("PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER" -9)
        ("PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS"
         -10)
        ("PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF"
         -11)
        ("PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX" -12)))
(define-type
  "SimplePaymentResult"
  (struct
    ("destination" "AccountID")
    ("asset" "Asset")
    ("amount" "int64")))
(define-type
  "PathPaymentStrictReceiveResult"
  (union (case ("code" "PathPaymentStrictReceiveResultCode")
           (("PATH_PAYMENT_STRICT_RECEIVE_SUCCESS")
            ("success"
             (struct
               ("offers" (variable-length-array "ClaimAtom" #f))
               ("last" "SimplePaymentResult"))))
           (("PATH_PAYMENT_STRICT_RECEIVE_NO_ISSUER")
            ("noIssuer" "Asset"))
           (else "void"))))
(define-type
  "PathPaymentStrictSendResultCode"
  (enum ("PATH_PAYMENT_STRICT_SEND_SUCCESS" 0)
        ("PATH_PAYMENT_STRICT_SEND_MALFORMED" -1)
        ("PATH_PAYMENT_STRICT_SEND_UNDERFUNDED" -2)
        ("PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST" -3)
        ("PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED"
         -4)
        ("PATH_PAYMENT_STRICT_SEND_NO_DESTINATION" -5)
        ("PATH_PAYMENT_STRICT_SEND_NO_TRUST" -6)
        ("PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED" -7)
        ("PATH_PAYMENT_STRICT_SEND_LINE_FULL" -8)
        ("PATH_PAYMENT_STRICT_SEND_NO_ISSUER" -9)
        ("PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS" -10)
        ("PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF" -11)
        ("PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN" -12)))
(define-type
  "PathPaymentStrictSendResult"
  (union (case ("code" "PathPaymentStrictSendResultCode")
           (("PATH_PAYMENT_STRICT_SEND_SUCCESS")
            ("success"
             (struct
               ("offers" (variable-length-array "ClaimAtom" #f))
               ("last" "SimplePaymentResult"))))
           (("PATH_PAYMENT_STRICT_SEND_NO_ISSUER")
            ("noIssuer" "Asset"))
           (else "void"))))
(define-type
  "ManageSellOfferResultCode"
  (enum ("MANAGE_SELL_OFFER_SUCCESS" 0)
        ("MANAGE_SELL_OFFER_MALFORMED" -1)
        ("MANAGE_SELL_OFFER_SELL_NO_TRUST" -2)
        ("MANAGE_SELL_OFFER_BUY_NO_TRUST" -3)
        ("MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED" -4)
        ("MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED" -5)
        ("MANAGE_SELL_OFFER_LINE_FULL" -6)
        ("MANAGE_SELL_OFFER_UNDERFUNDED" -7)
        ("MANAGE_SELL_OFFER_CROSS_SELF" -8)
        ("MANAGE_SELL_OFFER_SELL_NO_ISSUER" -9)
        ("MANAGE_SELL_OFFER_BUY_NO_ISSUER" -10)
        ("MANAGE_SELL_OFFER_NOT_FOUND" -11)
        ("MANAGE_SELL_OFFER_LOW_RESERVE" -12)))
(define-type
  "ManageOfferEffect"
  (enum ("MANAGE_OFFER_CREATED" 0)
        ("MANAGE_OFFER_UPDATED" 1)
        ("MANAGE_OFFER_DELETED" 2)))
(define-type
  "ManageOfferSuccessResult"
  (struct
    ("offersClaimed"
     (variable-length-array "ClaimAtom" #f))
    ("offer"
     (union (case ("effect" "ManageOfferEffect")
              (("MANAGE_OFFER_CREATED" "MANAGE_OFFER_UPDATED")
               ("offer" "OfferEntry"))
              (else "void"))))))
(define-type
  "ManageSellOfferResult"
  (union (case ("code" "ManageSellOfferResultCode")
           (("MANAGE_SELL_OFFER_SUCCESS")
            ("success" "ManageOfferSuccessResult"))
           (else "void"))))
(define-type
  "ManageBuyOfferResultCode"
  (enum ("MANAGE_BUY_OFFER_SUCCESS" 0)
        ("MANAGE_BUY_OFFER_MALFORMED" -1)
        ("MANAGE_BUY_OFFER_SELL_NO_TRUST" -2)
        ("MANAGE_BUY_OFFER_BUY_NO_TRUST" -3)
        ("MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED" -4)
        ("MANAGE_BUY_OFFER_BUY_NOT_AUTHORIZED" -5)
        ("MANAGE_BUY_OFFER_LINE_FULL" -6)
        ("MANAGE_BUY_OFFER_UNDERFUNDED" -7)
        ("MANAGE_BUY_OFFER_CROSS_SELF" -8)
        ("MANAGE_BUY_OFFER_SELL_NO_ISSUER" -9)
        ("MANAGE_BUY_OFFER_BUY_NO_ISSUER" -10)
        ("MANAGE_BUY_OFFER_NOT_FOUND" -11)
        ("MANAGE_BUY_OFFER_LOW_RESERVE" -12)))
(define-type
  "ManageBuyOfferResult"
  (union (case ("code" "ManageBuyOfferResultCode")
           (("MANAGE_BUY_OFFER_SUCCESS")
            ("success" "ManageOfferSuccessResult"))
           (else "void"))))
(define-type
  "SetOptionsResultCode"
  (enum ("SET_OPTIONS_SUCCESS" 0)
        ("SET_OPTIONS_LOW_RESERVE" -1)
        ("SET_OPTIONS_TOO_MANY_SIGNERS" -2)
        ("SET_OPTIONS_BAD_FLAGS" -3)
        ("SET_OPTIONS_INVALID_INFLATION" -4)
        ("SET_OPTIONS_CANT_CHANGE" -5)
        ("SET_OPTIONS_UNKNOWN_FLAG" -6)
        ("SET_OPTIONS_THRESHOLD_OUT_OF_RANGE" -7)
        ("SET_OPTIONS_BAD_SIGNER" -8)
        ("SET_OPTIONS_INVALID_HOME_DOMAIN" -9)
        ("SET_OPTIONS_AUTH_REVOCABLE_REQUIRED" -10)))
(define-type
  "SetOptionsResult"
  (union (case ("code" "SetOptionsResultCode")
           (("SET_OPTIONS_SUCCESS") "void")
           (else "void"))))
(define-type
  "ChangeTrustResultCode"
  (enum ("CHANGE_TRUST_SUCCESS" 0)
        ("CHANGE_TRUST_MALFORMED" -1)
        ("CHANGE_TRUST_NO_ISSUER" -2)
        ("CHANGE_TRUST_INVALID_LIMIT" -3)
        ("CHANGE_TRUST_LOW_RESERVE" -4)
        ("CHANGE_TRUST_SELF_NOT_ALLOWED" -5)
        ("CHANGE_TRUST_TRUST_LINE_MISSING" -6)
        ("CHANGE_TRUST_CANNOT_DELETE" -7)
        ("CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES" -8)))
(define-type
  "ChangeTrustResult"
  (union (case ("code" "ChangeTrustResultCode")
           (("CHANGE_TRUST_SUCCESS") "void")
           (else "void"))))
(define-type
  "AllowTrustResultCode"
  (enum ("ALLOW_TRUST_SUCCESS" 0)
        ("ALLOW_TRUST_MALFORMED" -1)
        ("ALLOW_TRUST_NO_TRUST_LINE" -2)
        ("ALLOW_TRUST_TRUST_NOT_REQUIRED" -3)
        ("ALLOW_TRUST_CANT_REVOKE" -4)
        ("ALLOW_TRUST_SELF_NOT_ALLOWED" -5)
        ("ALLOW_TRUST_LOW_RESERVE" -6)))
(define-type
  "AllowTrustResult"
  (union (case ("code" "AllowTrustResultCode")
           (("ALLOW_TRUST_SUCCESS") "void")
           (else "void"))))
(define-type
  "AccountMergeResultCode"
  (enum ("ACCOUNT_MERGE_SUCCESS" 0)
        ("ACCOUNT_MERGE_MALFORMED" -1)
        ("ACCOUNT_MERGE_NO_ACCOUNT" -2)
        ("ACCOUNT_MERGE_IMMUTABLE_SET" -3)
        ("ACCOUNT_MERGE_HAS_SUB_ENTRIES" -4)
        ("ACCOUNT_MERGE_SEQNUM_TOO_FAR" -5)
        ("ACCOUNT_MERGE_DEST_FULL" -6)
        ("ACCOUNT_MERGE_IS_SPONSOR" -7)))
(define-type
  "AccountMergeResult"
  (union (case ("code" "AccountMergeResultCode")
           (("ACCOUNT_MERGE_SUCCESS")
            ("sourceAccountBalance" "int64"))
           (else "void"))))
(define-type
  "InflationResultCode"
  (enum ("INFLATION_SUCCESS" 0)
        ("INFLATION_NOT_TIME" -1)))
(define-type
  "InflationPayout"
  (struct
    ("destination" "AccountID")
    ("amount" "int64")))
(define-type
  "InflationResult"
  (union (case ("code" "InflationResultCode")
           (("INFLATION_SUCCESS")
            ("payouts"
             (variable-length-array "InflationPayout" #f)))
           (else "void"))))
(define-type
  "ManageDataResultCode"
  (enum ("MANAGE_DATA_SUCCESS" 0)
        ("MANAGE_DATA_NOT_SUPPORTED_YET" -1)
        ("MANAGE_DATA_NAME_NOT_FOUND" -2)
        ("MANAGE_DATA_LOW_RESERVE" -3)
        ("MANAGE_DATA_INVALID_NAME" -4)))
(define-type
  "ManageDataResult"
  (union (case ("code" "ManageDataResultCode")
           (("MANAGE_DATA_SUCCESS") "void")
           (else "void"))))
(define-type
  "BumpSequenceResultCode"
  (enum ("BUMP_SEQUENCE_SUCCESS" 0)
        ("BUMP_SEQUENCE_BAD_SEQ" -1)))
(define-type
  "BumpSequenceResult"
  (union (case ("code" "BumpSequenceResultCode")
           (("BUMP_SEQUENCE_SUCCESS") "void")
           (else "void"))))
(define-type
  "CreateClaimableBalanceResultCode"
  (enum ("CREATE_CLAIMABLE_BALANCE_SUCCESS" 0)
        ("CREATE_CLAIMABLE_BALANCE_MALFORMED" -1)
        ("CREATE_CLAIMABLE_BALANCE_LOW_RESERVE" -2)
        ("CREATE_CLAIMABLE_BALANCE_NO_TRUST" -3)
        ("CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED" -4)
        ("CREATE_CLAIMABLE_BALANCE_UNDERFUNDED" -5)))
(define-type
  "CreateClaimableBalanceResult"
  (union (case ("code" "CreateClaimableBalanceResultCode")
           (("CREATE_CLAIMABLE_BALANCE_SUCCESS")
            ("balanceID" "ClaimableBalanceID"))
           (else "void"))))
(define-type
  "ClaimClaimableBalanceResultCode"
  (enum ("CLAIM_CLAIMABLE_BALANCE_SUCCESS" 0)
        ("CLAIM_CLAIMABLE_BALANCE_DOES_NOT_EXIST" -1)
        ("CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM" -2)
        ("CLAIM_CLAIMABLE_BALANCE_LINE_FULL" -3)
        ("CLAIM_CLAIMABLE_BALANCE_NO_TRUST" -4)
        ("CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED" -5)))
(define-type
  "ClaimClaimableBalanceResult"
  (union (case ("code" "ClaimClaimableBalanceResultCode")
           (("CLAIM_CLAIMABLE_BALANCE_SUCCESS") "void")
           (else "void"))))
(define-type
  "BeginSponsoringFutureReservesResultCode"
  (enum ("BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS" 0)
        ("BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED" -1)
        ("BEGIN_SPONSORING_FUTURE_RESERVES_ALREADY_SPONSORED"
         -2)
        ("BEGIN_SPONSORING_FUTURE_RESERVES_RECURSIVE" -3)))
(define-type
  "BeginSponsoringFutureReservesResult"
  (union (case ("code"
                "BeginSponsoringFutureReservesResultCode")
           (("BEGIN_SPONSORING_FUTURE_RESERVES_SUCCESS")
            "void")
           (else "void"))))
(define-type
  "EndSponsoringFutureReservesResultCode"
  (enum ("END_SPONSORING_FUTURE_RESERVES_SUCCESS" 0)
        ("END_SPONSORING_FUTURE_RESERVES_NOT_SPONSORED"
         -1)))
(define-type
  "EndSponsoringFutureReservesResult"
  (union (case ("code" "EndSponsoringFutureReservesResultCode")
           (("END_SPONSORING_FUTURE_RESERVES_SUCCESS")
            "void")
           (else "void"))))
(define-type
  "RevokeSponsorshipResultCode"
  (enum ("REVOKE_SPONSORSHIP_SUCCESS" 0)
        ("REVOKE_SPONSORSHIP_DOES_NOT_EXIST" -1)
        ("REVOKE_SPONSORSHIP_NOT_SPONSOR" -2)
        ("REVOKE_SPONSORSHIP_LOW_RESERVE" -3)
        ("REVOKE_SPONSORSHIP_ONLY_TRANSFERABLE" -4)
        ("REVOKE_SPONSORSHIP_MALFORMED" -5)))
(define-type
  "RevokeSponsorshipResult"
  (union (case ("code" "RevokeSponsorshipResultCode")
           (("REVOKE_SPONSORSHIP_SUCCESS") "void")
           (else "void"))))
(define-type
  "ClawbackResultCode"
  (enum ("CLAWBACK_SUCCESS" 0)
        ("CLAWBACK_MALFORMED" -1)
        ("CLAWBACK_NOT_CLAWBACK_ENABLED" -2)
        ("CLAWBACK_NO_TRUST" -3)
        ("CLAWBACK_UNDERFUNDED" -4)))
(define-type
  "ClawbackResult"
  (union (case ("code" "ClawbackResultCode")
           (("CLAWBACK_SUCCESS") "void")
           (else "void"))))
(define-type
  "ClawbackClaimableBalanceResultCode"
  (enum ("CLAWBACK_CLAIMABLE_BALANCE_SUCCESS" 0)
        ("CLAWBACK_CLAIMABLE_BALANCE_DOES_NOT_EXIST" -1)
        ("CLAWBACK_CLAIMABLE_BALANCE_NOT_ISSUER" -2)
        ("CLAWBACK_CLAIMABLE_BALANCE_NOT_CLAWBACK_ENABLED"
         -3)))
(define-type
  "ClawbackClaimableBalanceResult"
  (union (case ("code" "ClawbackClaimableBalanceResultCode")
           (("CLAWBACK_CLAIMABLE_BALANCE_SUCCESS") "void")
           (else "void"))))
(define-type
  "SetTrustLineFlagsResultCode"
  (enum ("SET_TRUST_LINE_FLAGS_SUCCESS" 0)
        ("SET_TRUST_LINE_FLAGS_MALFORMED" -1)
        ("SET_TRUST_LINE_FLAGS_NO_TRUST_LINE" -2)
        ("SET_TRUST_LINE_FLAGS_CANT_REVOKE" -3)
        ("SET_TRUST_LINE_FLAGS_INVALID_STATE" -4)
        ("SET_TRUST_LINE_FLAGS_LOW_RESERVE" -5)))
(define-type
  "SetTrustLineFlagsResult"
  (union (case ("code" "SetTrustLineFlagsResultCode")
           (("SET_TRUST_LINE_FLAGS_SUCCESS") "void")
           (else "void"))))
(define-type
  "LiquidityPoolDepositResultCode"
  (enum ("LIQUIDITY_POOL_DEPOSIT_SUCCESS" 0)
        ("LIQUIDITY_POOL_DEPOSIT_MALFORMED" -1)
        ("LIQUIDITY_POOL_DEPOSIT_NO_TRUST" -2)
        ("LIQUIDITY_POOL_DEPOSIT_NOT_AUTHORIZED" -3)
        ("LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED" -4)
        ("LIQUIDITY_POOL_DEPOSIT_LINE_FULL" -5)
        ("LIQUIDITY_POOL_DEPOSIT_BAD_PRICE" -6)
        ("LIQUIDITY_POOL_DEPOSIT_POOL_FULL" -7)))
(define-type
  "LiquidityPoolDepositResult"
  (union (case ("code" "LiquidityPoolDepositResultCode")
           (("LIQUIDITY_POOL_DEPOSIT_SUCCESS") "void")
           (else "void"))))
(define-type
  "LiquidityPoolWithdrawResultCode"
  (enum ("LIQUIDITY_POOL_WITHDRAW_SUCCESS" 0)
        ("LIQUIDITY_POOL_WITHDRAW_MALFORMED" -1)
        ("LIQUIDITY_POOL_WITHDRAW_NO_TRUST" -2)
        ("LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED" -3)
        ("LIQUIDITY_POOL_WITHDRAW_LINE_FULL" -4)
        ("LIQUIDITY_POOL_WITHDRAW_UNDER_MINIMUM" -5)))
(define-type
  "LiquidityPoolWithdrawResult"
  (union (case ("code" "LiquidityPoolWithdrawResultCode")
           (("LIQUIDITY_POOL_WITHDRAW_SUCCESS") "void")
           (else "void"))))
(define-type
  "OperationResultCode"
  (enum ("opINNER" 0)
        ("opBAD_AUTH" -1)
        ("opNO_ACCOUNT" -2)
        ("opNOT_SUPPORTED" -3)
        ("opTOO_MANY_SUBENTRIES" -4)
        ("opEXCEEDED_WORK_LIMIT" -5)
        ("opTOO_MANY_SPONSORING" -6)))
(define-type
  "OperationResult"
  (union (case ("code" "OperationResultCode")
           (("opINNER")
            ("tr"
             (union (case ("type" "OperationType")
                      (("CREATE_ACCOUNT")
                       ("createAccountResult" "CreateAccountResult"))
                      (("PAYMENT") ("paymentResult" "PaymentResult"))
                      (("PATH_PAYMENT_STRICT_RECEIVE")
                       ("pathPaymentStrictReceiveResult"
                        "PathPaymentStrictReceiveResult"))
                      (("MANAGE_SELL_OFFER")
                       ("manageSellOfferResult" "ManageSellOfferResult"))
                      (("CREATE_PASSIVE_SELL_OFFER")
                       ("createPassiveSellOfferResult"
                        "ManageSellOfferResult"))
                      (("SET_OPTIONS")
                       ("setOptionsResult" "SetOptionsResult"))
                      (("CHANGE_TRUST")
                       ("changeTrustResult" "ChangeTrustResult"))
                      (("ALLOW_TRUST")
                       ("allowTrustResult" "AllowTrustResult"))
                      (("ACCOUNT_MERGE")
                       ("accountMergeResult" "AccountMergeResult"))
                      (("INFLATION")
                       ("inflationResult" "InflationResult"))
                      (("MANAGE_DATA")
                       ("manageDataResult" "ManageDataResult"))
                      (("BUMP_SEQUENCE")
                       ("bumpSeqResult" "BumpSequenceResult"))
                      (("MANAGE_BUY_OFFER")
                       ("manageBuyOfferResult" "ManageBuyOfferResult"))
                      (("PATH_PAYMENT_STRICT_SEND")
                       ("pathPaymentStrictSendResult"
                        "PathPaymentStrictSendResult"))
                      (("CREATE_CLAIMABLE_BALANCE")
                       ("createClaimableBalanceResult"
                        "CreateClaimableBalanceResult"))
                      (("CLAIM_CLAIMABLE_BALANCE")
                       ("claimClaimableBalanceResult"
                        "ClaimClaimableBalanceResult"))
                      (("BEGIN_SPONSORING_FUTURE_RESERVES")
                       ("beginSponsoringFutureReservesResult"
                        "BeginSponsoringFutureReservesResult"))
                      (("END_SPONSORING_FUTURE_RESERVES")
                       ("endSponsoringFutureReservesResult"
                        "EndSponsoringFutureReservesResult"))
                      (("REVOKE_SPONSORSHIP")
                       ("revokeSponsorshipResult"
                        "RevokeSponsorshipResult"))
                      (("CLAWBACK")
                       ("clawbackResult" "ClawbackResult"))
                      (("CLAWBACK_CLAIMABLE_BALANCE")
                       ("clawbackClaimableBalanceResult"
                        "ClawbackClaimableBalanceResult"))
                      (("SET_TRUST_LINE_FLAGS")
                       ("setTrustLineFlagsResult"
                        "SetTrustLineFlagsResult"))
                      (("LIQUIDITY_POOL_DEPOSIT")
                       ("liquidityPoolDepositResult"
                        "LiquidityPoolDepositResult"))
                      (("LIQUIDITY_POOL_WITHDRAW")
                       ("liquidityPoolWithdrawResult"
                        "LiquidityPoolWithdrawResult"))))))
           (else "void"))))
(define-type
  "TransactionResultCode"
  (enum ("txFEE_BUMP_INNER_SUCCESS" 1)
        ("txSUCCESS" 0)
        ("txFAILED" -1)
        ("txTOO_EARLY" -2)
        ("txTOO_LATE" -3)
        ("txMISSING_OPERATION" -4)
        ("txBAD_SEQ" -5)
        ("txBAD_AUTH" -6)
        ("txINSUFFICIENT_BALANCE" -7)
        ("txNO_ACCOUNT" -8)
        ("txINSUFFICIENT_FEE" -9)
        ("txBAD_AUTH_EXTRA" -10)
        ("txINTERNAL_ERROR" -11)
        ("txNOT_SUPPORTED" -12)
        ("txFEE_BUMP_INNER_FAILED" -13)
        ("txBAD_SPONSORSHIP" -14)))
(define-type
  "InnerTransactionResult"
  (struct
    ("feeCharged" "int64")
    ("result"
     (union (case ("code" "TransactionResultCode")
              (("txSUCCESS" "txFAILED")
               ("results"
                (variable-length-array "OperationResult" #f)))
              (("txTOO_EARLY"
                "txTOO_LATE"
                "txMISSING_OPERATION"
                "txBAD_SEQ"
                "txBAD_AUTH"
                "txINSUFFICIENT_BALANCE"
                "txNO_ACCOUNT"
                "txINSUFFICIENT_FEE"
                "txBAD_AUTH_EXTRA"
                "txINTERNAL_ERROR"
                "txNOT_SUPPORTED"
                "txBAD_SPONSORSHIP")
               "void"))))
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "InnerTransactionResultPair"
  (struct
    ("transactionHash" "Hash")
    ("result" "InnerTransactionResult")))
(define-type
  "TransactionResult"
  (struct
    ("feeCharged" "int64")
    ("result"
     (union (case ("code" "TransactionResultCode")
              (("txFEE_BUMP_INNER_SUCCESS"
                "txFEE_BUMP_INNER_FAILED")
               ("innerResultPair" "InnerTransactionResultPair"))
              (("txSUCCESS" "txFAILED")
               ("results"
                (variable-length-array "OperationResult" #f)))
              (else "void"))))
    ("ext" (union (case ("v" "int") ((0) "void"))))))
(define-type
  "TestCase"
  (struct
    ("ledgerHeader" "LedgerHeader")
    ("ledgerEntries"
     (variable-length-array "LedgerEntry" #f))
    ("transationEnvelopes"
     (variable-length-array "TransactionEnvelope" #f))
    ("transactionResults"
     (variable-length-array "TransactionResult" #f))
    ("ledgerChanges"
     (variable-length-array "LedgerEntryChange" #f))))
