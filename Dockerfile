# The Outbreak Vault: an Audiobookshelf companion dashboard.
# nginx serves the page and relays ABS API calls (same origin, so no CORS setup is needed).
FROM nginx:1.27-alpine
LABEL org.opencontainers.image.title="The Outbreak Vault" \
      org.opencontainers.image.description="Audiobookshelf companion dashboard with a built-in API relay" \
      org.opencontainers.image.source="https://github.com/Sarge9199/outbreak-vault"
# ABS_URL (required): where the relay reaches Audiobookshelf, e.g. http://192.168.1.50:13378
# SERVERS (optional): sign-in choices, "Name|URL;Name|URL". Empty = one entry built from ABS_URL.
ENV ABS_URL="" \
    SERVERS="" \
    PORT=8642
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY docker-entrypoint.d/40-outbreak-vault-servers.sh /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/40-outbreak-vault-servers.sh
COPY icon.png web/The_Outbreak_Vault.html web/outbreak_vault_icon.svg /usr/share/nginx/html/
EXPOSE 8642
HEALTHCHECK --interval=60s --timeout=5s CMD wget -qO- http://127.0.0.1:${PORT}/relay-check >/dev/null || exit 1
