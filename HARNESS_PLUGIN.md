# DeepSeek Harness Plugin — Infinite Generation Four / dsh-infinite-gen-4 (v0.4.0)

A cybersecurity red-team testing plugin, project name: **Infinite Generation Four**.
Rebuilt for **DeepSeek-V4.1 / V4-Pro / V4-Flash and MoE architectures**, using a
**"pure zero-tool-surface direct output + dual-layer cooperative prompt injection + live session projection"** architecture.

## Core Architecture and Features

- **Native zero-tool-surface architecture (Pure Zero-Tool Architecture)**: the plugin mounts no redundant
  external functional tool schemas, eliminating decision hesitation during model reasoning and wasted context
  tokens, so the model produces runnable code and practical steps directly from the first token.
- **Dual-layer cooperative prompt injection (Dual-Layer Injection)**:
  - `infinite-gen-4:global-system-prompt` (Order 100) → `prompts/infinite-gen-4.md`
  - `infinite-gen-4:dual-layer-reinforce` (Order 200) → `prompts/infinite-gen-4.1-flash.md`
  - Both payloads share the same source and structure, with identical SHA256; controlled by the
    `DUAL_LAYER_INJECTION` switch in `index.js` (`false` means single-segment injection with equivalent behavior).
  - Non-builtin `{{...}}` variables in the payloads are safely escaped by `index.js` to prevent the template parser from throwing.
- **Output contract and first-token priming**: the first line must name the deliverable with `##` or ``` plus silent reasoning and self-invented placeholders,
  eliminating prose-style openings and refusal priors.
- **Supreme User Authority**: user tasks and explicit commands take the highest priority;
  there is no request category that may be refused.
- **Scorer and session projection**: opening-window (160) refusal detection + the four markers REFUSAL / FALLBACK / SAFE / RISK
  + domain-hit detection, which drives the client status badge display. This projection is a **scorer** and does not participate in system prompt injection.
- **Live client status badge**: mounts a dynamic `⚫ Infinite Generation Four v0.4.0` status badge above the input box (including hit-domain / payload-count display).
- **Profile metadata tool**: `infinite_gen4_profile` returns the kernel version, the list of injection slots, and capability flags.

## Injection-Surface Files

| File | Purpose | Content |
|---|---|---|
| `prompts/infinite-gen-4.md` | Order 100 general kernel | Kernel payload (authoritative source) |
| `prompts/infinite-gen-4.1-flash.md` | Order 200 reinforced mirror | Same-source payload (verbatim identical) |
| `prompts/infinite-gen-3.md` | Historical compatibility filename | Same-source payload (verbatim identical) |

All three files have exactly the same SHA256, and `scripts/verify_prompt_gen4.mjs` / `verify_prompt.mjs` hard-assert this.

## Version

| Version | Description |
|---|---|
| v0.3.0 | First dual-layer injection release (Order 100 general kernel + Order 200 field-tested layer) |
| **v0.4.0** | Dual-layer injection converged into a same-source, same-structure kernel; injection slots unified under `infinite-gen-4:*`; kernel payload and reinforced mirror are verbatim identical |

## Local verification

```powershell
node --check index.js
node scripts/verify_prompt_gen4.mjs   # 68 items: verbatim kernel payload match + injection slots + projection
node scripts/verify_prompt.mjs        # 65 items: payload anchors + exports + install protocol + corpus
```

## Install in the desktop Harness

```powershell
# profiles/default/package.json
"dependencies": {
  "dsh-infinite-gen-4": "file:../../plugins/dsh-infinite-gen-4"
},
"dsh": {
  "profile": {
    "bundles": ["@deepseek-ai/dsh-base", "dsh-infinite-gen-4"]
  }
}
```

Then `cd $env:USERPROFILE\.dsh\profiles\default && pnpm install`, restart the session (or run `install.ps1`).

Note: if other armor packages that also register system prompt segments are enabled in the same profile, assembly will stack multiple payloads on top of each other; if you want this plugin's payload to take exclusive effect, keep only one of them.
