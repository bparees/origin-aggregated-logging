#!/bin/bash
# added 2016-04-13 by singh.janmejay
# This file is part of the rsyslog project, released under ASL 2.0

uname
if [ `uname` = "FreeBSD" ] ; then
   echo "This test currently does not work on FreeBSD."
   exit 77
fi

echo ===============================================================================
echo \[dynstats_prevent_premature_eviction-vg.sh\]: test for ensuring metrics are not evicted before unused-ttl with valgrind
. $srcdir/diag.sh init
generate_conf
add_conf '
ruleset(name="stats") {
  action(type="omfile" file="./rsyslog.out.stats.log")
}

module(load="../plugins/impstats/.libs/impstats" interval="4" severity="7" resetCounters="on" Ruleset="stats" bracketing="on")

template(name="outfmt" type="string" string="%msg% %$.increment_successful%\n")

dyn_stats(name="msg_stats" unusedMetricLife="1" resettable="off")

set $.msg_prefix = field($msg, 32, 1);

if (re_match($.msg_prefix, "foo|bar|baz|quux|corge|grault")) then {
  set $.increment_successful = dyn_inc("msg_stats", $.msg_prefix);
} else {
  set $.increment_successful = -1;
}

action(type="omfile" file=`echo $RSYSLOG_OUT_LOG` template="outfmt")
'
startup_vg
. $srcdir/diag.sh wait-for-stats-flush 'rsyslog.out.stats.log'
. $srcdir/diag.sh block-stats-flush
. $srcdir/diag.sh injectmsg-litteral $srcdir/testsuites/dynstats_input_1
. $srcdir/diag.sh allow-single-stats-flush-after-block-and-wait-for-it
. $srcdir/diag.sh injectmsg-litteral $srcdir/testsuites/dynstats_input_2
. $srcdir/diag.sh allow-single-stats-flush-after-block-and-wait-for-it
. $srcdir/diag.sh injectmsg-litteral $srcdir/testsuites/dynstats_input_3
. $srcdir/diag.sh await-stats-flush-after-block
. $srcdir/diag.sh wait-queueempty
. $srcdir/diag.sh wait-for-stats-flush 'rsyslog.out.stats.log'
. $srcdir/diag.sh content-check "foo 001 0"
. $srcdir/diag.sh content-check "foo 006 0"
echo doing shutdown
shutdown_when_empty
echo wait on shutdown
wait_shutdown_vg
. $srcdir/diag.sh check-exit-vg
 # because dyn-accumulators for existing metrics were posted-to under a second, they should not have been evicted
. $srcdir/diag.sh custom-content-check 'baz=2' 'rsyslog.out.stats.log'
. $srcdir/diag.sh custom-content-check 'bar=1' 'rsyslog.out.stats.log'
. $srcdir/diag.sh custom-content-check 'foo=3' 'rsyslog.out.stats.log'
# sum is high because accumulators were never reset, and we expect them to last specific number of cycles(when we posted before ttl expiry)
. $srcdir/diag.sh first-column-sum-check 's/.*foo=\([0-9]\+\)/\1/g' 'foo=' 'rsyslog.out.stats.log' 6
. $srcdir/diag.sh first-column-sum-check 's/.*bar=\([0-9]\+\)/\1/g' 'bar=' 'rsyslog.out.stats.log' 1
. $srcdir/diag.sh first-column-sum-check 's/.*baz=\([0-9]\+\)/\1/g' 'baz=' 'rsyslog.out.stats.log' 3
. $srcdir/diag.sh first-column-sum-check 's/.*new_metric_add=\([0-9]\+\)/\1/g' 'new_metric_add=' 'rsyslog.out.stats.log' 3
. $srcdir/diag.sh first-column-sum-check 's/.*ops_overflow=\([0-9]\+\)/\1/g' 'ops_overflow=' 'rsyslog.out.stats.log' 0
. $srcdir/diag.sh first-column-sum-check 's/.*no_metric=\([0-9]\+\)/\1/g' 'no_metric=' 'rsyslog.out.stats.log' 0
exit_test
