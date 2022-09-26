#!/bin/sh
root=$(pwd)
lingy=$(pwd)/lingy 

error(){ echo "[E] $*"; exit 1; }

single(){
	cd test/app1
	$lingy stop
	$lingy start
	sleep 1s
	lsof nohup.out 1>/dev/null 2>/dev/null || error "no process started"
	$lingy logs
	$lingy stop
	test -f nohup.out && error "nohup.out file not removed"
	ps aux | awk '! /grep/ {print $0}' | grep 'sleep 1m' && error "process not killed"
}

# test recursive
recursive(){
	cd $root 
	$lingy start test
	$lingy stop test
}

"$@"
exit 0
