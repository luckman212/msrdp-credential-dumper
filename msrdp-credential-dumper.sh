#!/usr/bin/env bash

DB="$HOME/Library/Containers/com.microsoft.rdc.macos/Data/Library/Application Support/com.microsoft.rdc.macos/com.microsoft.rdc.application-data.sqlite"
[[ -r $DB ]] || { echo 1>&2 "database could not be accessed"; exit 1; }

MAXCOLS=$(tput cols)
[[ -n $MAXCOLS ]] || MAXCOLS=80
export C1=$(( MAXCOLS / 4 ))
export C2=$(( MAXCOLS / 5 ))

( tput bold ; tput smul ;
	printf "%-${C1}s %-${C2}s %s\n" Name Hostname 'Username/Password' ;
	tput sgr0 ;
	while IFS='|' read -r B_ZFRIENDLYNAME B_ZHOSTNAME C_ZID C_ZUSERNAME _ ; do
		PASSWD=$(security 2>/dev/null find-generic-password -w -s com.microsoft.rdc.macos -a "$C_ZID")
		printf "%-${C1}s %-${C2}s %s\n" "${B_ZFRIENDLYNAME:0:$C1}" "$B_ZHOSTNAME" "${C_ZUSERNAME:--}${PASSWD:+ / $PASSWD}"
	done < <(sqlite3 "$DB" <<-EOS
	SELECT
		b.ZFRIENDLYNAME,
		b.ZHOSTNAME,
		c.ZID,
		c.ZUSERNAME
	FROM
		ZBOOKMARKENTITY as b
	LEFT JOIN ZCREDENTIALENTITY as c on b.ZCREDENTIAL = c.Z_PK
	ORDER BY b.ZFRIENDLYNAME
	EOS
	)
)
