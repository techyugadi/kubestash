#!/bin/sh

set -e

if [ "$1" = jetty.sh ]; then
	if ! command -v bash >/dev/null 2>&1 ; then
		cat >&2 <<- 'EOWARN'
			********************************************************************
			ERROR: bash not found. Use of jetty.sh requires bash.
			********************************************************************
		EOWARN
		exit 1
	fi
	cat >&2 <<- 'EOWARN'
		********************************************************************
		WARNING: Use of jetty.sh from this image is deprecated and may
			 be removed at some point in the future.

			 See the documentation for guidance on extending this image:
			 https://github.com/docker-library/docs/tree/master/jetty
		********************************************************************
	EOWARN
fi

if ! command -v -- "$1" >/dev/null 2>&1 ; then
	set -- java -jar "$JETTY_HOME/start.jar" "$@"
fi

: ${TMPDIR:=/tmp/jetty}
[ -d "$TMPDIR" ] || mkdir -p $TMPDIR 2>/dev/null

: ${JETTY_START:=$JETTY_BASE/jetty.start}

case "$JAVA_OPTIONS" in
	*-Djava.io.tmpdir=*) ;;
	*) JAVA_OPTIONS="-Djava.io.tmpdir=$TMPDIR $JAVA_OPTIONS" ;;
esac

if expr "$*" : 'java .*/start\.jar.*$' >/dev/null ; then
	# this is a command to run jetty

	# check if it is a terminating command
	for A in "$@" ; do
		case $A in
			--add-to-start* |\
			--create-files |\
			--create-startd |\
			--download |\
			--dry-run |\
			--exec-print |\
			--help |\
			--info |\
			--list-all-modules |\
			--list-classpath |\
			--list-config |\
			--list-modules* |\
			--stop |\
			--update-ini |\
			--version |\
			-v )\
			# It is a terminating command, so exec directly
			JAVA="$1"
			shift
			exec $JAVA $JAVA_OPTIONS "$@"
		esac
	done

        if [ ! -z "$JETTY_SSLCONTEXT_KEYSTOREPASSWORD" ]; then 
          # Note: no option to change default keystore location
          # Simply use volume mounts to install your ssl key into jetty docker
          echo "jetty.sslContext.keyStorePath=etc/keystore" >> $JETTY_BASE/start.d/ssl.ini.new 
          echo "jetty.sslContext.keyStorePassword=$JETTY_SSLCONTEXT_KEYSTOREPASSWORD" >>  $JETTY_BASE/start.d/ssl.ini.new 
        fi
        if [ ! -z "$JETTY_SSLCONTEXT_TRUSTSTOREPATH" ]; then 
          echo "jetty.sslContext.trustStorePath=$JETTY_SSLCONTEXT_TRUSTSTOREPATH" >> $JETTY_BASE/start.d/ssl.ini.new 
        fi
        if [ ! -z "$JETTY_SSLCONTEXT_TRUSTSTOREPASSWORD" ]; then 
          echo "jetty.sslContext.trustStorePassword=$JETTY_SSLCONTEXT_TRUSTSTOREPASSWORD" >>  $JETTY_BASE/start.d/ssl.ini.new 
        fi
        if [ ! -z "$JETTY_SSLCONTEXT_KEYMANAGERPASSWORD" ]; then 
          echo "jetty.sslContext.keyManagerPassword=$JETTY_SSLCONTEXT_KEYMANAGERPASSWORD" >>  $JETTY_BASE/start.d/ssl.ini.new 
        fi
        if [ ! -z "$JETTY_SSLCONTEXT_NEEDCLIENTAUTH" ]; then 
          echo "jetty.sslContext.needClientAuth=$JETTY_SSLCONTEXT_NEEDCLIENTAUTH" >>  $JETTY_BASE/start.d/ssl.ini.new 
        fi
        if [ -f $JETTY_BASE/start.d/ssl.ini.new ]; then
          mv $JETTY_BASE/start.d/ssl.ini $JETTY_BASE/start.d/ssl.ini.bak
          mv $JETTY_BASE/start.d/ssl.ini.new $JETTY_BASE/start.d/ssl.ini
        fi

	if [ $(whoami) != "jetty" ]; then
		cat >&2 <<- EOWARN
			********************************************************************
			WARNING: User is $(whoami)
			         The user should be (re)set to 'jetty' in the Dockerfile
			********************************************************************
		EOWARN
	fi

	if [ -f $JETTY_START ] ; then
		if [ $JETTY_BASE/start.d -nt $JETTY_START ] ; then
			cat >&2 <<- EOWARN
			********************************************************************
			WARNING: The $JETTY_BASE/start.d directory has been modified since
			         the $JETTY_START files was generated. Either delete 
			         the $JETTY_START file or re-run 
			             /generate-jetty.start.sh 
			         from a Dockerfile
			********************************************************************
			EOWARN
		fi
		echo $(date +'%Y-%m-%d %H:%M:%S.000'):INFO:docker-entrypoint:jetty start from $JETTY_START
		set -- $(cat $JETTY_START)
	else
		# Do a jetty dry run to set the final command
		JAVA="$1"
		shift
		$JAVA $JAVA_OPTIONS "$@" --dry-run > $JETTY_START
		if [ $(egrep -v '\\$' $JETTY_START | wc -l ) -gt 1 ] ; then
			# command was more than a dry-run
			cat $JETTY_START \
			| awk '/\\$/ { printf "%s", substr($0, 1, length($0)-1); next } 1' \
			| egrep -v '[^ ]*java .* org\.eclipse\.jetty\.xml\.XmlConfiguration '
			exit
		fi
		set -- $(sed -e 's/ -Djava.io.tmpdir=[^ ]*//g' -e 's/\\$//' $JETTY_START)
	fi
fi

if [ "${1##*/}" = java -a -n "$JAVA_OPTIONS" ] ; then
	JAVA="$1"
	shift
	set -- "$JAVA" $JAVA_OPTIONS "$@"
fi

exec "$@"
