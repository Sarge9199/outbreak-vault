# The Outbreak Vault

A companion dashboard for [Audiobookshelf](https://www.audiobookshelf.org/): **Up Next** shelves (now listening,
next in your series, recently finished), series "runway" (owned / unread / hours left), genre browsing with pinned
favorites, author and narrator shortcuts, and one-tap **Start in ABS** links.

It runs as a tiny nginx container that serves the page **and relays API calls to your Audiobookshelf server**:

- no CORS configuration in Audiobookshelf,
- the relay reaches ABS on your LAN/VPN, so sign-in works even when your public ABS URL sits behind 2FA,
- users sign in with **their own** Audiobookshelf accounts; the container stores **no credentials**,
- only the dashboard files are served (allow-list); everything else returns 404.

> Expects a library named **MyBooks** (current version).

## Settings

| Variable  | Required | Example | Purpose |
|-----------|----------|---------|---------|
| `ABS_URL` | yes | `http://192.168.1.50:13378` | Where the **container** reaches Audiobookshelf. |
| `SERVERS` | no  | `Home network\|http://192.168.1.50:13378;VPN\|http://100.64.0.10:13378` | Sign-in choices, `Name\|URL` separated by `;`. "Start in ABS" links open the address the user picks. Empty = one choice built from `ABS_URL`. |
| port      | –   | `8642` | Web UI port. |

## Install on Unraid

1. Save [`outbreak-vault.xml`](outbreak-vault.xml) to your flash drive as
   `/boot/config/plugins/dockerMan/templates-user/my-outbreak-vault.xml`
   (Unraid terminal: `wget -O /boot/config/plugins/dockerMan/templates-user/my-outbreak-vault.xml https://raw.githubusercontent.com/Sarge9199/outbreak-vault/main/outbreak-vault.xml`).
2. **Docker** tab → **Add Container** → **Template** → *outbreak-vault*.
3. Fill in **ABS_URL** (and optionally **SERVERS**) → **Apply**.
4. Open `http://<unraid-ip>:8642`.

**Updates:** when a new version is published, the Docker tab shows *update ready*: click it, or let the
*CA Auto Update Applications* plugin handle it. Your settings are kept.

## Install with Docker Compose (any Linux)

```bash
mkdir outbreak-vault && cd outbreak-vault
wget https://raw.githubusercontent.com/Sarge9199/outbreak-vault/main/docker-compose.yml
# edit ABS_URL / SERVERS in docker-compose.yml
docker compose up -d
```
Update later with `docker compose pull && docker compose up -d`.

## Troubleshooting

- **Container stops right away:** `ABS_URL` is empty; `docker logs outbreak-vault` says so.
- **Sign-in error mentioning "the Vault relay":** the container can't reach `ABS_URL`. Test with
  `docker exec outbreak-vault wget -qO- "$ABS_URL/ping"` (expects `{"success":true}`).
- **Picker says "No servers configured":** check `SERVERS` formatting (`Name|URL;Name|URL`).
- **Android:** "Start in ABS" opens the Audiobookshelf app (its home screen; the app doesn't support opening a
  specific book yet), falling back to the web page if the app isn't installed.

## Security notes

Keep this dashboard on your LAN/VPN, or behind your own reverse proxy with authentication.
It holds no secrets itself; all access control is enforced by Audiobookshelf.
