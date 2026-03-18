# Reverse proxy (Traefik, etc.)

The Command Center can run behind a reverse proxy on your domain. The main UI and Chat work from in-app links. Links to the other apps (Kiwix, CyberChef, Notes, Kolibri) are built inside the container and may open the main page instead of the app when behind a proxy.

**Workaround:** open those apps via direct URL (your domain or NOMAD host IP, ports 8090, 8100, 8200, 8300).
