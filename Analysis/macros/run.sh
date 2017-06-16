#!/bin/bash

# usage: bsub run.sh -mydir $PWD -- <command to run>

export BATCH=
export DISPLAY=""

batchdir=$PWD
mydir=$(dirname $(which $0))

set -x

workdir=$batchdir
stat=""
tarball=""
proxy=""
envfile=""

while [[ $1 != "--" ]]; do
    case $1 in
	-workdir)
	    workdir=$2;
	    shift
	    ;;
	-stat)
	    stat=$2;
	    shift
	    ;;
	-tarball)
	    tarball=$2
	    shift
	    ;;
	-proxy)
	    proxy=$2
	    shift
	    ;;
	-env)
	    envfile=$2
	    shift
	    ;;
	-mydir)
	    mydir=$2
	    shift
	    ;;
	-copy)
	    copy=$2
	    shift
	    ;;
	-outdir)
	    outdir=$2
	    shift
	    ;;
    esac
    shift
done
shift

versionfile=$workdir/version.sh
setup=$workdir/setup.sh
cleanup=$workdir/cleanup.sh

set -x

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$mydir

cd $mydir

if [[ -n $envfile ]]; then
    source $envfile
else
    eval `scramv1 ru -sh`
fi

job=$(which $1)
shift

args=$@
while [[ -n $1 ]]; do 
    shift
done

if [[ -n $stat ]]; then
    for st in sub run done fail; do
	rm ${stat}.${st}
    done
    touch $stat.run
fi


cd $workdir

if [[ -f $tarball ]]; then
    tar zvxf $tarball
fi

if [[ -n $proxy ]]; then
    export X509_USER_PROXY=$(echo $proxy | awk -F: '{ print $2 }')
    rsync -avP $proxy ${X509_USER_PROXY}
fi

if [[ -f $versionfile ]]; then
    source $versionfile
fi

if [[ -f $setup ]]; then
    source $setup
fi

pwd
ls

$job $args
exstat=$?

if [[ -n $stat ]]; then
    rm $stat.run 
    if [[ "$exstat" != "0" ]]; then
	echo "$exstat" > $stat.fail
	exit $exstat
    fi
fi

if [[ -n $outdir ]] && [[ -n $copy ]]; then
    for fil in $copy; do
	cp -pv $fil $outdir
    done
fi

if [[ -f $cleanup ]]; then
    source $cleanup
fi

if [[ -n $stat ]]; then
    if [[ -n "$errs" ]]; then
	echo -e $sha1  > $stat.fail
	echo $errs >> $stat.fail
    else
	echo -e $sha1  > $stat.done
    fi
fi
