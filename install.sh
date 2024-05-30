config=~/.config
share=~/.local/share
nconfig=$config/hyprdots-nath
nshare=$share/hyprdots-nath

# Make dirs

if [[ ! -d $nconfig ]]; then
  mkdir $nconfig
fi

if [[ ! -d $nshare ]]; then
  mkdir $nshare
elif [[ ! -z "$(ls -A $nshare)" ]]; then
  rm -r $nshare/*
fi

# Backup

if [[ -d "$config/hypr" ]]; then
  /bin/mv -f "$config/hypr" $nshare
fi

# Copy

/bin/cp -rf hypr $config

echo "Move origin configuration to $nshare"
