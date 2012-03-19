#! /bin/sh

LDNS_SIGNZONE="ldns-signzone"

errx() {
  echo "$1" >&2
  exit 1
}

parse_opts() {
  opts=''
  output=''
  while [ $# -gt 0 ]; do
    case $1 in
      -[eioE]) opts="$opts $1"; shift ;;
      -f) shift; output=$1; shift ;;
      --) shift; break ;;
      -*) ;;
       *) break ;;
    esac
    opts="$opts $1"; shift
  done
  [ $# -lt 2 ] && exit 1
  zonefile=$1; shift
  keys=$*
  [ "$output" = '' ] && output="${zonefile}.signed"
  echo "$opts"; echo "$zonefile"; echo "$keys"; echo "$output"
}

preprocess_include() {
  file="$1"
  line="$2"
  echo "$line" | {
    read include_statement included_file
    if [ -f "$included_file" ]; then
      preprocess_file "$included_file"
    else
      alt_included_file=$(dirname "$file")/$(basename "$included_file")
      [ -f "$alt_included_file" ] || \
        errx "Nonexistent file: [$included_file] included from [$file]"
      preprocess_file "$alt_included_file"
    fi
  }
}

preprocess_file() {
  file="$1"
  while read line; do
    case "$line" in
      \$[Ii][Nn][Cc][Ll][Uu][Dd][Ee][[:blank:]]*)
        preprocess_include "$file" "$line" || exit $?
      ;;
      *) echo "$line" ;;
    esac
  done < "$file" | egrep -v "^[[:blank:]]*$"
}

parse_opts $* | {
  read opts; read zonefile; read keys; read output

  [ -z "$zonefile" -o -z "$keys" -o -z "$output" ] && \
    errx "Usage: $0 [opts] zonefile key [key [key]]"
  preprocess_file $zonefile | "$LDNS_SIGNZONE" -f "$output" $opts -- - $keys
}
