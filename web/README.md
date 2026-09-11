# Public family stories

Production runs at https://pocket.changhai.me on Cloudflare Workers with D1. POST and DELETE require the family owner key. GET requires only the opaque sharing link. Responses use no-store caching. [Deployment instructions](../docs/deployment.md) cover production updates, secrets and verification.

Local development requires Node 24 or later and uses SQLite on disk:

From the project root, create a local owner key without printing it:

```sh
python3 - <<'PY'
from pathlib import Path
import secrets
folder = Path('.local')
folder.mkdir(mode=0o700, exist_ok=True)
key = folder / 'owner-key'
if not key.exists():
    key.write_text(secrets.token_urlsafe(32))
    key.chmod(0o600)
PY
cd web
npm ci
npm run build
npm start
```

The local service listens at http://127.0.0.1:4174. Its database and key are under .local, outside Git. A parent configures the same origin and key in the app's Family sharing settings. Do not put the owner key in a URL, app bundle or web bundle.

Deployment configuration:

| Variable | Meaning |
| --- | --- |
| PUBLIC_BASE_URL | The actual HTTPS origin recipients will open |
| OWNER_KEY | A random server secret of at least 32 characters |
| DATABASE_PATH | A SQLite file on a persistent disk, preserved across restarts |
| LISTEN_HOST | Use 0.0.0.0 behind a deployment reverse proxy |
| PORT | Defaults to 4174 |

The Dockerfile is an optional deployment recipe. Mount persistent storage at /data, inject OWNER_KEY securely and set PUBLIC_BASE_URL. It has not been deployed or verified against a cloud provider. A deployment without persistent storage does not meet the acceptance contract.

The Cloudflare deployment uses web/wrangler.jsonc and web/migrations. Run npm run test:cloudflare with POCKET_SHARE_OWNER_KEY supplied securely to verify the live deployment. It operates on fictional test stories and revokes them afterward.

The versioned format is shared/public-story.schema.json. Native and web tests read the same shared/fixtures/public-story-v1.json. Only allowlisted story fields are stored. Revoking a link removes its snapshot and keeps a tombstone for HTTP 410.
