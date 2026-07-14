# Launch runbook — fianchettochess.app

State as of 2026-07-03: the site is complete and pushed on `main`
(landing page, audited privacy policy, 404, CNAME, Inkwell board,
wordmark). The repo is **private**, which blocks GitHub Pages on the
current plan — that is the only thing between here and live.

## Before launch day (can be done any time)

1. **Verify the domain on the GitHub account** (protects
   `fianchettochess.app` from Pages domain-takeover while the site is
   not yet serving — do this BEFORE creating the DNS records below):
   - github.com/settings/pages (profile Settings → sidebar → *Pages*,
     under "Code, planning, and automation") → *Add a domain* →
     `fianchettochess.app` → *Add domain*.
   - Add the TXT record GitHub shows at the registrar — host
     `_github-pages-challenge-jaredbrewer` (full name
     `_github-pages-challenge-jaredbrewer.fianchettochess.app`), value
     as displayed. Check propagation with:
     `dig _github-pages-challenge-jaredbrewer.fianchettochess.app TXT`
   - Back on the Pages settings page: menu next to the domain →
     *Continue verifying* → *Verify*.

2. **DNS at the registrar** (safe once the domain is verified):

   | Type  | Host | Value                                          |
   |-------|------|------------------------------------------------|
   | A     | `@`  | `185.199.108.153`                              |
   | A     | `@`  | `185.199.109.153`                              |
   | A     | `@`  | `185.199.110.153`                              |
   | A     | `@`  | `185.199.111.153`                              |
   | AAAA  | `@`  | `2606:50c0:8000::153` (and `8001`/`8002`/`8003`) — optional IPv6 |
   | CNAME | `www`| `fianchettochess.github.io`                    |

3. ~~**Activate `support@fianchettochess.app`**~~ — DONE 2026-07-03;
   the mailbox is live and all site links point at it.

4. ~~**Decide Inkwell attribution**~~ — DONE 2026-07-03: original
   commissioned artwork, all rights held; distributed CC-BY-NC-4.0.
   Recorded on all three site footers and in the app repo
   (LICENSING.md, README, both platforms' AboutView).

## Launch day (in order)

```sh
# 1. Flip the repo public
gh repo edit fianchettochess/fianchetto.github.io --visibility public \
  --accept-visibility-change-consequences

# 2. Enable Pages (deploy from branch main, root)
gh api -X POST repos/fianchettochess/fianchetto.github.io/pages \
  -f "source[branch]=main" -f "source[path]=/"

# 3. The CNAME file sets the custom domain on first build; if the
#    Pages settings do not show fianchettochess.app after a minute:
gh api -X PUT repos/fianchettochess/fianchetto.github.io/pages \
  -f cname=fianchettochess.app

# 4. Watch the first build
gh api repos/fianchettochess/fianchetto.github.io/pages/builds/latest \
  --jq '{status: .status, error: .error.message}'

# 5. Once the Pages settings show the DNS check green and the
#    certificate is issued (minutes to ~1 hour), enforce HTTPS:
gh api -X PUT repos/fianchettochess/fianchetto.github.io/pages \
  -F https_enforced=true
```

## Post-launch checks

- https://fianchettochess.app loads; `www.` redirects to the apex.
- /privacy.html renders; footer mailto works; /404 test: visit any
  bad URL ("That square is empty").
- Favicon + apple-touch-icon appear; no mixed-content warnings
  (the site makes zero external requests, so none are expected).

## Notes

- GPL source-offer wording on the site is already qualified ("source
  published when the app ships") — when the app repo goes public,
  reinstate the direct GitHub links on the site.
- Cburnett dual-license track (CC BY-SA vs GPL-2.0+) is an open item
  in the app's LICENSING.md; it matters slightly more with piece art
  displayed on the web.
