#!/bin/zsh
# Calcule le hash SHA256 combine de conf.yml et theme.css
HASH=$(cat conf.yml theme.css | sha256sum | awk '{print $1}')
# Met à jour (ou ajoute) la ligne CONF_HASH dans dashy-stack.yml
if grep -q 'CONF_HASH=' dashy-stack.yml; then
  sed -i "s/CONF_HASH=.*/CONF_HASH=$HASH/" dashy-stack.yml
else
  # Ajoute la variable dans la section environment
  sed -i "/environment:/a\      - CONF_HASH=$HASH" dashy-stack.yml
fi
