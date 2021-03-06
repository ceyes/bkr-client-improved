#!/bin/bash
# author jiyin@redhat.com

#This is a beaker recipe use status checker, that invoked by cron

declare -A HostMax
HostMax[x86_64]=75
HostMax[i386]=65
HostMax[ppc64]=24
HostMax[s390x]=10
HostMax[ppc64le]=10
ret=0
users="$1"

recipeCheck() {
	local arch=${1:-x86_64}
	local user=${2:-jiyin}
	local url=http://nest.test.redhat.com/mnt/qa/scratch/azelinka/beaker-stats/top-recipe-owners.$arch
	I=$(echo $url; curl $url 2>/dev/null)
	M=$(echo "$I" | awk '$1 ~ "'$user'" {print $1, $2}')
	while read U N; do
		[ "${N:-0}" -gt ${HostMax[$arch]} ] && {
			let ret++
			echo "$I" | sendmail.sh -p '[Remind warning line kkkkk] ' -t "$U@redhat.com" -c "jiyin@redhat.com" - \
				"You($U) hold too much($N/${HostMax[$arch]}) $arch recipes"  &>/dev/null
		}
	done <<<"$M"
	echo -e "\033[1;34m$arch host usage status\033[0m:\n$I"
}

users="${users:-^(jiyin)$}"
recipeCheck x86_64  "$users"
recipeCheck ppc64   "$users"
recipeCheck ppc64le "$users"
recipeCheck s390x   "$users"
recipeCheck i386    "$users"

exit $ret
