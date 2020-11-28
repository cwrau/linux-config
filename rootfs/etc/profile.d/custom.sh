if [ -d /usr/local/bin/custom ]; then
  PATH="$PATH:/usr/local/bin/custom"
fi

if [ -d /usr/local/bin/custom/custom ]; then
  PATH="$PATH:/usr/local/bin/custom/custom"
fi
