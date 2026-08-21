#!/bin/zsh
# Calcule le hash SHA256 de frigate-config.yaml
HASH=$(sha256sum frigate-config.yaml | awk '{print $1}')
# Met à jour (ou ajoute) la ligne CONFIG_HASH dans frigate-stack.yml
if grep -q 'CONFIG_HASH:' frigate-stack.yml; then
  sed -i "s/CONFIG_HASH:.*/CONFIG_HASH: \"$HASH\"/" frigate-stack.yml
else
  sed -i "/FRIGATE_RTSP_PASSWORD:/a\      CONFIG_HASH: \"$HASH\"" frigate-stack.yml
fi
