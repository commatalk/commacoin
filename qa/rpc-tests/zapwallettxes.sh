#!/usr/bin/env bash
# Copyright (c) 2014 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

# Test -zapwallettxes=<mode>

if [ $# -lt 1 ]; then
        echo "Usage: $0 path_to_binaries"
        echo "e.g. $0 ../../src"
        echo "Env vars BITCOIND and BITCOINCMC may be used to specify the exact binaries used"
        exit 1
fi

set -f

BITCOIND=${BITCOIND:-${1}/bitcoind}
CMC=${BITCOINCMC:-${1}/bitcoin-cli}

DIR="${BASH_SOURCE%/*}"
SENDANDWAIT="${DIR}/send.sh"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/util.sh"

D=$(mktemp -d test.XXXXX)

D1=${D}/node1
CreateDataDir "$D1" port=11000 rpcport=11001
B1ARGS="-datadir=$D1"
$BITCOIND $B1ARGS &
B1PID=$!

D2=${D}/node2
CreateDataDir "$D2" port=11010 rpcport=11011
B2ARGS="-datadir=$D2"
$BITCOIND $B2ARGS &
B2PID=$!

function CleanUp {
$CMC $B2ARGS stop > /dev/null 2>&1
wait $B2PID
$CMC $B1ARGS stop > /dev/null 2>&1
wait $B1PID

rm -rf $D
}

# 110 blocks, 10 mature == 500 XBT
$CMC $B1ARGS setgenerate true 110
$CMC $B2ARGS setgenerate true 110

CheckBalance "$B1ARGS" 500
CheckBalance "$B2ARGS" 500

# Send 10 XBT
TXID1_DEFAULT=$($CMC $B1ARGS sendtoaddress "mrhz5ZgSF3C1BSdyCKt3gEdhKoRL5BNfJV" 10)
TXID2_DEFAULT=$($CMC $B2ARGS sendtoaddress "mrhz5ZgSF3C1BSdyCKt3gEdhKoRL5BNfJV" 10)

CheckBalance $B1ARGS 490
CheckBalance $B2ARGS 490

# Move 10 XBT to testaccount
TMP=$($CMC $B1ARGS move "" "testaccount" 10)
TMP=$($CMC $B2ARGS move "" "testaccount" 10)

CheckBalance $B1ARGS 10 "testaccount"
CheckBalance $B2ARGS 10 "testaccount"

# Send 1 XBT from testaccount
TXID1_TESTACCOUNT=$($CMC $B1ARGS sendfrom "testaccount" "mrhz5ZgSF3C1BSdyCKt3gEdhKoRL5BNfJV" 1)
TXID2_TESTACCOUNT=$($CMC $B2ARGS sendfrom "testaccount" "mrhz5ZgSF3C1BSdyCKt3gEdhKoRL5BNfJV" 1)

CheckBalance $B1ARGS 9 "testaccount"
CheckBalance $B2ARGS 9 "testaccount"

CheckBalance $B1ARGS 489
CheckBalance $B2ARGS 489

# Confirm transactions
$CMC $B1ARGS setgenerate true 1
$CMC $B2ARGS setgenerate true 1

# Create unconfirmed transaction
TXID1_UNCONFIRMED=$($CMC $B1ARGS sendtoaddress "mrhz5ZgSF3C1BSdyCKt3gEdhKoRL5BNfJV" 1)
TXID2_UNCONFIRMED=$($CMC $B2ARGS sendtoaddress "mrhz5ZgSF3C1BSdyCKt3gEdhKoRL5BNfJV" 1)

# check balance (we created another 50 and spent 1 in the meantime)
CheckBalance $B1ARGS 538
CheckBalance $B2ARGS 538

# Safety check, if unconfirmed transactions are there
$CMC $B1ARGS gettransaction $TXID1_UNCONFIRMED > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    echoerr "gettransaction1_1: $TXID1_UNCONFIRMED failed"
    CleanUp
    exit 1
fi
$CMC $B2ARGS gettransaction $TXID2_UNCONFIRMED > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    echoerr "gettransaction2_1: $TXID2_UNCONFIRMED failed"
    CleanUp
    exit 1
fi

# stop nodes
$CMC $B2ARGS stop > /dev/null 2>&1
wait $B2PID
$CMC $B1ARGS stop > /dev/null 2>&1
wait $B1PID

# restart nodes with -zapwallettxes
$BITCOIND -zapwallettxes=1 $B1ARGS &
B1PID=$!
$BITCOIND -zapwallettxes=2 $B2ARGS &
B2PID=$!

# check if confirmed transactions are there
$CMC $B1ARGS gettransaction $TXID1_DEFAULT > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    echoerr "check confirmed transaction 1: $TXID1_DEFAULT failed"
    CleanUp
    exit 1
fi
$CMC $B2ARGS gettransaction $TXID2_DEFAULT > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    echoerr "check confirmed transaction 2: $TXID2_DEFAULT failed"
    CleanUp
    exit 1
fi
$CMC $B1ARGS gettransaction $TXID1_TESTACCOUNT > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    echoerr "check confirmed transaction 3: $TXID1_TESTACCOUNT failed"
    CleanUp
    exit 1
fi
$CMC $B2ARGS gettransaction $TXID2_TESTACCOUNT > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    echoerr "check confirmed transaction 4: $TXID2_TESTACCOUNT failed"
    CleanUp
    exit 1
fi

# check if unconfirmed transaction is gone
$CMC $B1ARGS gettransaction $TXID1_UNCONFIRMED > /dev/null 2>&1
if [[ $? -eq 0 ]] ; then
    echoerr "check unconfirmed transaction 1: $TXID1_UNCONFIRMED failed"
    CleanUp
    exit 1
fi
$CMC $B2ARGS gettransaction $TXID2_UNCONFIRMED > /dev/null 2>&1
if [[ $? -eq 0 ]] ; then
    echoerr "check unconfirmed transaction 2: $TXID2_UNCONFIRMED failed"
    CleanUp
    exit 1
fi

# check zapwallet mode 1, testaccount balance must be 9 (keeping transaction metadata)
CheckBalance $B1ARGS 9 "testaccount"

# check zapwallet mode 2, testaccount balance must be 10 (dropping transaction metadata)
CheckBalance $B2ARGS 10 "testaccount"

echo "Tests successful, cleaning up"
CleanUp
exit 0
