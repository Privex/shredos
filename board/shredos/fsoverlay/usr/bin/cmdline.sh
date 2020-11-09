#!/bin/ash

#extractpr() {
#  tag="$1"
#  matcher="\"?'?([a-zA-Z0-9/\\@#\$%^&\!*\(\),._-]+)'?\"?"
#  [ $# -gt 1 ] && matcher="$2"
#  sed -rn "s/.* ?${tag}=${matcher} ?(.*)+?/\1/p"
#}

################
# Extract a parameter-like value from a string piped into stdin
#
# $ echo "hello world=\"an example\" test=123" | extractpr world
# an example
# $ echo "hello world=\"an example\" test=123" | extractpr test
# 123
#
extractpr() {
  data_in="$(cat)"
  tag="$1"
  m_matcher="([a-zA-Z0-9/\\@#\$%^&\!*\(\)'\",._-]+)"
  q_matcher="\"([a-zA-Z0-9/\\@#\$%^&\!*\(\)', ._-]+)\""
  [ $# -gt 1 ] && matcher="$2"
  k_res="$(printf '%s' "$data_in" | sed -rn "s/.* ?${tag}=${m_matcher} ?(.*)+?/\1/p")"
  if echo "$k_res" | grep -Eq '^"'; then
    k_res="$(printf "%s\n" "$data_in" | sed -rn "s/.* ?${tag}=${q_matcher} ?(.*)+?/\1/p")"
  fi
  printf "%s\n" "$k_res"
}

get_cmd() {
  res=$(cat /proc/cmdline | extractpr "$1")
  if [ -z "$res" ]; then
    return 1
  else
    printf "%s\n" "$res"
  fi
}

# console=ttyS0,9600n8

has_cmd() { 
  get_cmd "$@" > /dev/null;
}

# has_cmd_word [name] [name2] [name3] ...
# Acts as an OR query for names inside of cmdline
# e.g.
#
#   $ cat /proc/cmdline
#   BOOT_IMAGE=/boot/somekernel root=/dev/sda ro enablex usey world="lorem ipsum"
#   $ has_cmd_word ro && echo yes || echo no
#   yes
#   $ has_cmd_word roo && echo yes || echo no
#   no
#   $ has_cmd_word root && echo yes || echo no
#   yes
#   $ has_cmd_word enablex && echo yes || echo no
#   yes
#
has_cmd_word() {
  for k in "$@"; do
    if cat /proc/cmdline | grep -Eq " ${k}(=.*)? |^${k}(=.*)? | ${k}(=.*)?\$"; then
      return 0
    fi
  done
  return 1
}

