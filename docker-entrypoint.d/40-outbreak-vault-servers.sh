#!/bin/sh
# The Outbreak Vault: build servers.json (the sign-in picker list) from the SERVERS setting.
#   SERVERS="Home network|http://192.168.1.50:13378;VPN|http://100.64.0.10:13378;Public|https://abs.example.com"
# If SERVERS is empty, one entry is made from ABS_URL. ABS_URL is required (the relay target).
out="${OV_SERVERS_OUT:-/usr/share/nginx/html/servers.json}"
if [ -z "$ABS_URL" ]; then
  echo "outbreak-vault: ERROR - ABS_URL is not set. Set it to your Audiobookshelf address, e.g. http://192.168.1.50:13378" >&2
  exit 1
fi
src="$SERVERS"
[ -z "$src" ] && src="Audiobookshelf|$ABS_URL"
printf '%s' "$src" | awk 'BEGIN { RS=";"; n=0; printf "[" }
{
  s=$0; gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s); if (s == "") next
  i=index(s, "|"); if (i) { name=substr(s,1,i-1); url=substr(s,i+1) } else { name=s; url=s }
  gsub(/^[ \t]+|[ \t]+$/, "", name); gsub(/^[ \t]+|[ \t]+$/, "", url)
  if (url == "") next
  gsub(/\\/, "\\\\", name); gsub(/"/, "\\\"", name); gsub(/\\/, "\\\\", url); gsub(/"/, "\\\"", url)
  printf "%s{\"name\":\"%s\",\"url\":\"%s\"}", (n++ ? "," : ""), name, url
}
END { print "]" }' > "$out"
echo "outbreak-vault: sign-in servers -> $(cat "$out")"
