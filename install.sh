config=~/.config
share=~/.local/share
backup=$share/hyprdots-backup

# Make dirs

if [[ ! -d $backup ]]; then
  mkdir $backup
elif [[ ! -z "$(ls -A $backup)" ]]; then
  rm -r $backup/*
fi

# Backup

/bin/mv -f "$config/hypr" $backup

# Copy

/bin/cp -rf hypr/ $config

echo "Move origin configuration to $backup"
