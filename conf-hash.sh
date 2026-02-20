#!/bin/zsh
# Calcule le hash SHA256 de conf.yml
HASH=$(sha256sum conf.yml | awk '{print $1}')
# Met à jour (ou ajoute) la ligne CONF_HASH dans dashy-stack.yml
if grep -q 'CONF_HASH=' dashy-stack.yml; then
  sed -i "s/CONF_HASH=.*/CONF_HASH=$HASH/" dashy-stack.yml
else
  # Ajoute la variable dans la section environment
  sed -i "/environment:/a\      - CONF_HASH=$HASH" dashy-stack.yml
fi
