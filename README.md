# ryangarber.dev

An empty React/Vite canvas with a dark gray, neon pink/violet/cyan theme. No page content is included.

Requires Node 24+ and pnpm 12.21.0.

```sh
pnpm install
pnpm dev
```

Build inside `src/App.tsx`. Theme tokens and the `bg-neon`, `text-neon`, and `neon-panel` classes live in `src/index.css`. Shadcn is configured in `components.json`; add components with `pnpm ui add button` (or any component name).

`pnpm lint` checks lint rules, import ordering, and formatting with Biome. `pnpm lint:fix` applies safe fixes, and `pnpm format` formats files. `pnpm check` runs lint/format checks and the production build, as CI does.

`pnpm build` typechecks with TypeScript 7.1 beta and writes the production site to `dist/`. `pnpm preview` serves that build locally.

## Releases and deployment

Push to `main` to build, deploy, and publish a GitHub release using [rylease](https://github.com/ryangarber/rylease). Pull requests run the build check only. Conventional Commits drive release notes; CalVer uses `YYYY.MM.MICRO` in `America/New_York`, such as `2026.11.0`, `2026.11.1`, then `2026.12.0`. Tags are `v{version}`. The release is published after deployment succeeds.

Create the GitHub **production** environment and set these environment secrets:

| Secret            | Value                                                       |
| ----------------- | ----------------------------------------------------------- |
| `SSH_HOST`        | Linode hostname or IPv4 address                             |
| `SSH_USER`        | Deployment user                                             |
| `SSH_PRIVATE_KEY` | Unencrypted deployment private key with access to that user |

Set these **production environment variables**:

| Variable          | Value                                                            |
| ----------------- | ---------------------------------------------------------------- |
| `SSH_KNOWN_HOSTS` | Verified OpenSSH known_hosts entry for the Linode host; required |
| `SSH_PORT`        | Optional; defaults to `22`                                       |
| `DEPLOY_PATH`     | Optional; defaults to `/var/www/ryangarber.dev`                  |

Obtain the host key through a trusted connection or Linode console and verify its fingerprint before saving the known_hosts entry. A nonstandard port uses `[hostname]:port` in that entry. The workflow uses strict host key checking.

On Linode, install rsync, authorize the deployment public key, and create a dedicated site directory writable by the deployment user. Serve that directory with your existing web server; `deploy/nginx.conf` is an example. Configure DNS and HTTPS on the server. No Node runtime or process restart is needed for this static site. Adjust the web server root if you change `DEPLOY_PATH`.

Deployment uses rsync checksums to transfer changed files. Assets upload before `index.html` is replaced; old hashed assets remain for open browser tabs. Retired assets may be cleaned periodically after your chosen retention period. Keep the deployment directory dedicated to this site.

Production runs are serialized. Use **Run workflow** on `main` to retry deployment even when there are no unreleased commits. GitHub's built-in token creates tags/releases; no additional token is needed. Environment protection rules may require approval if you enable them.
