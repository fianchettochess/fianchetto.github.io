# Launch runbook — fianchettochess.app

State as of 2026-07-03: the site is complete and pushed on `main`
(landing page, audited privacy policy, 404, CNAME, Inkwell board,
wordmark). The repo is **private**, which blocks GitHub Pages on the
current plan — that is the only thing between here and live.

## Before launch day (can be done any time)

1. **Verify the domain on the GitHub account** (protects
   `fianchettochess.app` from Pages domain-takeover while the site is
   not yet serving — do this BEFORE creating the DNS records below):
   - github.com/settings/pages_verified_domains → *Add a domain* →
     `fianchettochess.app`
   - Add the TXT record GitHub shows (name
     `_github-pages-challenge-jaredbrewer`) at the registrar → *Verify*.

2. **DNS at the registrar** (safe once the domain is verified):

   | Type  | Host | Value                                          |
   |-------|------|------------------------------------------------|
   | A     | `@`  | `185.199.108.153`                              |
   | A     | `@`  | `185.199.109.153`                              |
   | A     | `@`  | `185.199.110.153`                              |
   | A     | `@`  | `185.199.111.153`                              |
   | AAAA  | `@`  | `2606:50c0:8000::153` (and `8001`/`8002`/`8003`) — optional IPv6 |
   | CNAME | `www`| `jaredbrewer.github.io`                        |

3. **Activate `support@fianchettochess.app`** — the site's contact and
   CTA links point at it.

4. **Decide Inkwell attribution** (see the footer sentence on all three
   pages): if it is original first-party art, say so on the site and in
   the app's LICENSING.md/README; if third-party, add the real
   author/license in both places.

## Launch day (in order)

```sh
# 1. Flip the repo public
gh repo edit jaredbrewer/fianchetto.github.io --visibility public \
  --accept-visibility-change-consequences

# 2. Enable Pages (deploy from branch main, root)
gh api -X POST repos/jaredbrewer/fianchetto.github.io/pages \
  -f "source[branch]=main" -f "source[path]=/"

# 3. The CNAME file sets the custom domain on first build; if the
#    Pages settings do not show fianchettochess.app after a minute:
gh api -X PUT repos/jaredbrewer/fianchetto.github.io/pages \
  -f cname=fianchettochess.app

# 4. Watch the first build
gh api repos/jaredbrewer/fianchetto.github.io/pages/builds/latest \
  --jq '{status: .status, error: .error.message}'

# 5. Once the Pages settings show the DNS check green and the
#    certificate is issued (minutes to ~1 hour), enforce HTTPS:
gh api -X PUT repos/jaredbrewer/fianchetto.github.io/pages \
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
