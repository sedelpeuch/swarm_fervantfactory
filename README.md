# FervantFactory — Stacks Docker Swarm

Dépôt GitOps des stacks du homelab, déployées via **Portainer** (un environnement Git par stack, redéploiement automatique sur push).

## Architecture

- Chaque `*-stack.yml` est une stack Swarm indépendante, déployée par Portainer depuis ce dépôt.
- Toutes les stacks exposées en HTTP rejoignent le réseau overlay externe `proxy`, créé une fois manuellement (`docker network create -d overlay proxy`) et partagé entre stacks.
- `nginx-stack.yml` + `nginx.conf` font office de reverse proxy d'entrée (`fervantfactory.delpeuch.net`), routant vers les services internes du réseau `proxy` (dashy, uptime-kuma, dolibarr-dashboard, ...).
- `homeassistant-stack.yml` est volontairement en dehors de ce schéma : `network_mode: host` + `privileged: true` pour l'accès direct au bus USB/Zigbee (`/dev/ttyUSB0`) et à dbus.

## Dashy et `CONF_HASH`

Portainer ne redéploie pas un service quand seul un fichier monté (`conf.yml`) change, sans changement du service lui-même. Pour forcer un redéploiement de Dashy à chaque modification de `conf.yml`, un hook `pre-commit` local (`conf-hash.sh`) recalcule le SHA256 de `conf.yml` et met à jour la variable d'environnement `CONF_HASH` dans `dashy-stack.yml`. Ce changement de variable déclenche le redéploiement Portainer.

Installation du hook :

```sh
pre-commit install
```

## Stacks

| Fichier | Service | Notes |
|---|---|---|
| `dashy-stack.yml` | Dashboard d'accueil | Config dans `conf.yml`, redeploy via `CONF_HASH` |
| `nginx-stack.yml` | Reverse proxy d'entrée | Config dans `nginx.conf` |
| `uptime-kuma-stack.yml` | Monitoring de disponibilité | |
| `homeassistant-stack.yml` | Domotique | Hors réseau `proxy`, accès matériel direct |
| `balthazar-stack.yml` | Dashboard projets Dolibarr | Secrets via `.env` non versionné (`DOLIBARR_URL`, `DOLIAPIKEY`, ...) |
| `calibre-web-stack.yml` | Bibliothèque ebooks | Service d'init qui télécharge la base d'exemple et `kepubify` au premier démarrage |

## Risques connus (acceptés)

- Les images sont toutes en tag `:latest` (sauf `mariadb:10.11`) : pas de pinning de version, risque de dérive assumé.
- `homeassistant-stack.yml` stocke ses identifiants MariaDB en clair : risque accepté, pas de migration vers `docker secret` prévue pour l'instant.
