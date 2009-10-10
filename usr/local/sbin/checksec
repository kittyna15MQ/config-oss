#!/bin/bash
# Tobias Klein, 02/2009
# http://www.trapkit.de

# help
if [ "$#" = "0" ]; then
  echo "usage: checksec OPTIONS"
  echo -e "\t--file <binary name>"
  echo -e "\t--dir <directory name>"
  echo -e "\t--proc <process name>"
  echo -e "\t--proc-all"
  echo -e "\t--version"
  echo
  exit 1
fi

# version information
version() {
  echo "checksec v1.0, Tobias Klein / www.trapkit.de 02/2009"
  echo 
}

# check file(s)
filecheck() {
  # check for RELRO support
  if readelf -l $1 2>/dev/null | grep -q 'GNU_RELRO'; then
    if readelf -d $1 2>/dev/null | grep -q 'BIND_NOW'; then
      echo -n -e '\033[32mFull RELRO   \033[m   '
    else
      echo -n -e '\033[33mPartial RELRO\033[m   '
    fi
  else
    echo -n -e '\033[31mNo RELRO     \033[m   '
  fi

  # check for stack canary support
  if readelf -s $1 2>/dev/null | grep -q '__stack_chk_fail'; then
    echo -n -e '\033[32mCanary found   \033[m   '
  else
    echo -n -e '\033[31mNo canary found\033[m   '
  fi

  # check for NX support
  if readelf -l $1 2>/dev/null | grep 'GNU_STACK' | grep -q 'RWE'; then
    echo -n -e '\033[31mNX disabled\033[m   '
  else
    echo -n -e '\033[32mNX enabled \033[m   '
  fi 

  # check for PIE support
  if readelf -h $1 2>/dev/null | grep -q 'Type:[[:space:]]*EXEC'; then
    echo -n -e '\033[31mNo PIE               \033[m   '
  elif readelf -h $1 2>/dev/null | grep -q 'Type:[[:space:]]*DYN'; then
    if readelf -d $1 2>/dev/null | grep -q '(DEBUG)'; then
      echo -n -e '\033[32mPIE enabled          \033[m   '
    else   
      echo -n -e '\033[33mDynamic Shared Object\033[m   '
    fi
  else
    echo -n -e '\033[33mNot an ELF file      \033[m   '
  fi 
}

# check process(es)
proccheck() {
  # check for RELRO support
  if readelf -l $1/exe 2>/dev/null | grep -q 'Program Headers'; then
    if readelf -l $1/exe 2>/dev/null | grep -q 'GNU_RELRO'; then
      if readelf -d $1/exe 2>/dev/null | grep -q 'BIND_NOW'; then
        echo -n -e '\033[32mFull RELRO       \033[m '
      else
        echo -n -e '\033[33mPartial RELRO    \033[m '
      fi
    else
      echo -n -e '\033[31mNo RELRO         \033[m '
    fi
  else
    echo -n -e '\033[33mPermission denied\033[m '
    return
  fi

  # check for stack canary support
  if readelf -s $1/exe 2>/dev/null | grep -q 'Symbol table'; then
    if readelf -s $1/exe 2>/dev/null | grep -q '__stack_chk_fail'; then
      echo -n -e '\033[32mCanary found         \033[m  '
    else
      echo -n -e '\033[31mNo canary found      \033[m  '
    fi
  else
    if [ "$1" != "1" ]; then
      echo -n -e '\033[33mPermission denied    \033[m  '
    else
      echo -n -e '\033[33mNo symbol table found\033[m  '
    fi
  fi

  # check for NX support
  if readelf -l $1/exe 2>/dev/null | grep 'GNU_STACK' | grep -q 'RWE'; then
    echo -n -e '\033[31mNX disabled\033[m   '
  else
    echo -n -e '\033[32mNX enabled \033[m   '
  fi 

  # check for PIE support
  if readelf -h $1/exe 2>/dev/null | grep -q 'Type:[[:space:]]*EXEC'; then
    echo -n -e '\033[31mNo PIE               \033[m   '
  elif readelf -h $1/exe 2>/dev/null | grep -q 'Type:[[:space:]]*DYN'; then
    if readelf -d $1/exe 2>/dev/null | grep -q '(DEBUG)'; then
      echo -n -e '\033[32mPIE enabled          \033[m   '
    else   
      echo -n -e '\033[33mDynamic Shared Object\033[m   '
    fi
  else
    echo -n -e '\033[33mNot an ELF file      \033[m   '
  fi

  # check for global ASLR support
  if /sbin/sysctl -a 2>/dev/null | grep -q 'kernel.randomize_va_space = 1'; then
    echo -n -e '\033[32mASLR enabled      \033[m   '
  elif /sbin/sysctl -a 2>/dev/null | grep -q 'kernel.randomize_va_space = 2'; then
    echo -n -e '\033[32mASLR enabled      \033[m   '
  elif /sbin/sysctl -a 2>/dev/null | grep -q 'kernel.randomize_va_space = 0'; then
    echo -n -e '\033[31mASLR disabled     \033[m   '
  else
    echo -n -e '\033[32mASLR not supported\033[m   '
  fi 
}

if [ "$1" = "--dir" ]; then
  cd $2
  printf "RELRO           STACK CANARY      NX            PIE                     FILE\n"
  for N in [a-z]*; do
    if [ "$N" != "[a-z]*" ]; then
      filecheck $N
      if [ `find $2$N \( -perm -004000 -o -perm -002000 \) -type f -print` ]; then
        printf "\033[37;41m%s%s\033[m" $2 $N
      else
        printf "%s%s" $2 $N
      fi
      echo
    fi
  done
  exit 0
fi

if [ "$1" = "--file" ]; then
  printf "RELRO           STACK CANARY      NX            PIE                     FILE\n"		
  filecheck $2
  if [ `find $2 \( -perm -004000 -o -perm -002000 \) -type f -print` ]; then
    printf "\033[37;41m%s%s\033[m" $2 $N
  else
    printf "%s" $2
  fi
  echo
  exit 0
fi

if [ "$1" = "--proc-all" ]; then
  cd /proc
  printf "         COMMAND    PID RELRO             STACK CANARY           NX            PIE                     ASLR\n"
  for N in [1-9]*; do
    if [ $N != $$ ] && readlink -q $N/exe > /dev/null; then
      printf "%16s" `head -1 $N/status | cut -b 7-`
      printf "%7d " $N
      proccheck $N
      echo
    fi
  done
  exit 0
fi

if [ "$1" = "--proc" ]; then
  cd /proc
  printf "         COMMAND    PID RELRO             STACK CANARY           NX            PIE                     ASLR\n"
  for N in `pidof $2`; do
    if [ -d $N ]; then
      printf "%16s" `head -1 $N/status | cut -b 7-`
      printf "%7d " $N			
      proccheck $N
      echo
    fi
  done
fi

if [ "$1" = "--version" ]; then
  version
fi
