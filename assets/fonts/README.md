# Self-hosted web fonts

These fonts are self-hosted to eliminate external font requests. All three families are licensed under the SIL Open Font License 1.1 (see `OFL.txt`).

## Families

| Family | Source | Version served | License |
|--------|--------|----------------|---------|
| Playfair Display | [Google Fonts](https://fonts.google.com/specimen/Playfair+Display) / [GitHub](https://github.com/clauseggers/Playfair) | v40 (woff2 via Google Fonts API) | OFL-1.1 |
| Source Serif 4 | [Google Fonts](https://fonts.google.com/specimen/Source+Serif+4) / [Adobe Fonts GitHub](https://github.com/adobe-fonts/source-serif) | v14 (woff2 via Google Fonts API) | OFL-1.1 |
| Source Code Pro | [Google Fonts](https://fonts.google.com/specimen/Source+Code+Pro) / [Adobe Fonts GitHub](https://github.com/adobe-fonts/source-code-pro) | v31 (woff2 via Google Fonts API) | OFL-1.1 |

## Subsets

**Kept:** `latin`, `latin-ext` (latin-ext covers accented characters in the licensing footer and internationalised names).

**Dropped:** cyrillic, cyrillic-ext, greek, greek-ext, vietnamese — none used on the Fianchetto site.

## Files

All three families are served as variable-weight woff2 files (Google returns the same binary for multiple declared weights — the woff2 encodes the weight axis internally):

```
playfair-display-italic-latin-ext.woff2   (italic wt 400 & 700, latin-ext)
playfair-display-italic-latin.woff2       (italic wt 400 & 700, latin)
playfair-display-normal-latin-ext.woff2   (normal wt 400, 700, 900, latin-ext)
playfair-display-normal-latin.woff2       (normal wt 400, 700, 900, latin)

source-serif-4-italic-latin-ext.woff2     (italic wt 300 & 400, latin-ext)
source-serif-4-italic-latin.woff2         (italic wt 300 & 400, latin)
source-serif-4-normal-latin-ext.woff2     (normal wt 300, 400, 600, latin-ext)
source-serif-4-normal-latin.woff2         (normal wt 300, 400, 600, latin)

source-code-pro-normal-latin-ext.woff2    (normal wt 400 & 500, latin-ext)
source-code-pro-normal-latin.woff2        (normal wt 400 & 500, latin)
```

`fonts.css` contains the `@font-face` declarations; it is loaded via `<link>` in `index.html` before `study.css`.
