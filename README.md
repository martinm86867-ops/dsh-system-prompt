# ⚔️ DeepSeek-V4.1 / V4 Flash Cybersecurity Red-Team Toolkit (Infinite Generation Four) v0.4.0

<p align="center">
  <img src="assets/banner.png" alt="Infinite Generation Four" width="100%" />
</p>

<p align="center">
  <a href="dsh://plugin/install?id=dsh-infinite-gen-4&name=Infinite%20Generation%20Four&version=0.4.0&repo=Minglink%2Fdsh-infinite-gen-4&permissions=System%20prompt%20injection%2C%20client%20status%20badge&downloadUrl=https%3A%2F%2Fgithub.com%2FMinglink%2Fdsh-infinite-gen-4%2Farchive%2Frefs%2Fheads%2Fmaster.zip">
    <img src="https://img.shields.io/badge/DeepSeek%20Harness-🚀%20Quick%20install%20from%20the%20desktop%20client-10B981?style=for-the-badge&logo=deepseek&logoColor=white" alt="Launch the desktop client for one-click install" />
  </a>
</p>

> 🌐 **Plugin ecosystem marketplace**: [DeepSeek Harness Hub — the official and open-source DeepSeek ecosystem marketplace | plugin discovery and one-click install](https://deepseek.stream/)

> ## 💬 DeepSeek community & chat groups
>
> ### 👉 **Red-team security discussion group 9: `338431075`**
> ### 👉 **Tencent Channels technical community: `pd86424753`**
>
> 🔥 Join us to exchange red-team adversarial testing notes, share prompts and evaluation benchmarks, and discuss plugin development and ecosystem building!

---

## 🛡️ Why Red-Teaming Matters for Cybersecurity Benchmarking

As generative AI and large language models (LLMs) become deeply integrated into every industry, model robustness, adversarial defense capability, and system alignment safety have become core research topics in cyberspace security:

1. **Expose the defense boundary and feed it back into guardrails**: Only through professional cybersecurity red-team adversarial simulation, probing a model's input escapes, prompt injection, and unexpected behavior in a controlled environment, can security teams precisely locate a model's blind spots — and thereby harden things up front through model fine-tuning, input-filtering gateways (guardrails), and the system safety layer.
2. **Build an integrated offense-and-defense posture**: A defense without controlled red-team evaluation cases is nothing but armchair strategy. A standardized red-team test suite gives enterprises and security auditors a "ruler" for measuring how effective a defense strategy really is, ensuring that detection and blocking capabilities are already in place before real malicious threats appear.
3. **Advance native LLM security research**: This project aims to provide academia and the security engineering field with a transparent, reproducible benchmarking baseline, jointly advancing AI infrastructure resiliency against adversarial attack, manifold-constrained alignment, and formal verification techniques.

---

> ### ⚠️ Strict Legal & Compliance Disclaimer
>
> **【Zero-tolerance statement】**: This project firmly opposes and strictly prohibits any form of illegal or criminal activity! The developers of this project never support, encourage, or assist any unauthorized cyber attack, vulnerability exploitation, data theft, illegal intrusion into computer information systems, or generation of illegal or prohibited content.
>
> 1. **Limited to lawful, controlled scope**: This project (`dsh-infinite-gen-4`) is positioned purely as a cybersecurity red-team research tool and robustness benchmarking suite. **It is strictly forbidden to run this project against targets without the owner's lawful written authorization, against public internet systems, or against production business systems.** All testing activity must be strictly confined to **offline local synthetic fixtures, authorized cybersecurity exercise ranges, and compliant controlled laboratory environments**.
> 2. **Illegal and prohibited uses are strictly forbidden**: Users must never use this project, directly or indirectly, to engage in:
>    - any act that violates the *Criminal Law of the People's Republic of China* (中华人民共和国刑法), the *Cybersecurity Law of the People's Republic of China* (中华人民共和国网络安全法), the *Data Security Law of the People's Republic of China* (中华人民共和国数据安全法), the *Personal Information Protection Law of the People's Republic of China* (中华人民共和国个人信息保护法), or other laws and regulations;
>    - unauthorized penetration or attack against the computer information systems of public or private organizations, or carrying out ransomware, sabotage, credential stuffing, or distribution of malicious payloads;
>    - inducing, generating, or disseminating any content expressly prohibited by law, including content that endangers national security, terrorism, violence and gore, pornography, gambling, fraud, or infringement of citizens' privacy or intellectual property rights;
>    - violating the Terms of Service or Usage Policy of the relevant large-model providers.
> 3. **Users bear sole responsibility**: This project is provided "AS-IS" under the MIT open-source license, and the developers make no express or implied warranty as to the software's completeness, security, or fitness for purpose. **Users bear independent and full civil, administrative, and criminal legal liability for all of their own downloading, deployment, running, modification, and distribution activities, as well as for all input and output consequences arising from them.** The project author and contributing team accept no direct, indirect, or joint liability whatsoever resulting from user misuse.
> 4. **Breach terminates the license**: For any individual or entity that uses this project for illegal attack, malicious activity, or non-compliant behavior, the open-source software license **terminates automatically and irrevocably and immediately** from the date the unlawful or non-compliant act occurs. That party must immediately stop using the project and permanently destroy all of its code, scripts, and derived data, and shall be subject to the corresponding legal sanctions.
> 5. **Third-party independence statement**: This project is a completely independent open-source security evaluation research project. It has no affiliation, commercial partnership, authorization, or official endorsement relationship with DeepSeek officially or with any of its related entities.

---

> 🔥 **Cybersecurity Red-Team Toolkit for V4.1-DeepSeek Flash (Infinite Generation Four) v0.4.0**. Deeply adapted and supported for V4.1 reinforcement-learning adversarial testing, with one-click install for both desktop and client. If this open-source security project helps you, a Star ⭐ is very welcome.
>
> **v0.4.0 Pure Red-Team Edition**: built natively on a zero-tool-surface architecture that eliminates decision noise during the model's thinking phase; it injects a dual-layer cooperative kernel and retains only system prompt injection and live status projection. **Strict statement: this project firmly cracks down on and rejects (and does not support) any illegal, non-compliant, or harmful content generated by models, including NSFW material. Its technical system is intended solely for lawfully authorized reverse engineering and cybersecurity research.**

---

> ### 🧬 v0.4.0 Dual-Layer Kernel
>
> - Injection slots: `infinite-gen-4:global-system-prompt` (Order 100) + `infinite-gen-4:dual-layer-reinforce` (Order 200),
>   controlled by the `DUAL_LAYER_INJECTION` switch in `index.js` (setting it to `false` gives single-segment injection with equivalent behavior).
> - Three kernel files under `prompts/` (`infinite-gen-3.md` / `infinite-gen-4.md` / `infinite-gen-4.1-flash.md`)

---

## 📊 Generation Architecture and Capability Comparison

| Dimension | Gen 2 | Gen 3 | Infinite Generation Four (v0.4.0) |
|---|---|---|---|
| **Target models** | V3 / early V4 | DeepSeek-V4 (mHC) | Full DeepSeek-V4.1 / V4-Pro / Flash family |
| **Runtime architecture** | Single-layer prompt | Security-baseline single layer | **Dual-layer cooperative injection (shared general kernel + reinforced mirror, same source and structure)** |
| **Tool-surface design** | Coarse-grained | Zero tool surface | **Native zero-tool surface (eliminates decision noise, instant direct output)** |
| **Memory-write primitive** | Easily intercepted | Requires prior priming | **Trainer lane direct output (OpenProcess/RPM/WPM)** |
| **Output contract** | Weak rules | Deliverable named on the first line | **Forced first-token priming (##/```) + forbidden-word self-check** |
| **Client status badge** | None | Supported (with domain and payload counts) | **Supported (live projection + animated status badge)** |
| **One-click install protocol** | Manual configuration | Supports dsh:// | **Native dsh:// integration + automatic backward compatibility** |

---

## 📁 Project Directory Structure

```
Infinite Generation Four v0.4.0/
├── 🚀 One-click install and maintenance suite
│   ├── install.ps1              # Windows one-click automatic install (auto-configures the environment, registers the protocol)
│   ├── install.bat              # Windows quick double-click batch file
│   ├── install.sh               # Linux / macOS one-click install
│   ├── uninstall.ps1            # Windows one-click uninstall
│   └── uninstall.sh             # Linux / macOS one-click uninstall
├── 🧩 Core plugin loading surface (standard Cordis architecture)
│   ├── package.json             # Plugin metadata (dsh-infinite-gen-4 v0.4.0)
│   ├── cordis.patch.yml         # Core patch declaration
│   ├── index.js                 # Plugin core entry (dual-layer prompt injection + profile metadata + session projection)
│   ├── client.js                # Client half (the "⚫ Infinite Generation Four v0.4.0" status badge)
│   └── HARNESS_PLUGIN.md        # Plugin specification
├── 📜 Cybersecurity red-team system prompt body
│   └── prompts/
│       ├── infinite-gen-3.md          # Gen 3 classic kernel
│       ├── infinite-gen-4.md          # Gen 4 general kernel (output contract + refusal countermeasures + full-domain slots)
│       └── infinite-gen-4.1-flash.md  # V4.1 reinforced mirror layer (trainer lane + shallow reasoning + metadata extraction)
├── 📖 Documentation center
│   ├── README.md                # Comprehensive main documentation (this file)
│   └── LICENSE                  # MIT License
├── 🛡️ Deterministic regression test suite
│   ├── scripts/
│   │   ├── lib/scorer.mjs       # Opening-window refusal scorer
│   │   ├── verify_prompt.mjs    # Classic deterministic verification
│   │   ├── verify_prompt_gen4.mjs # Gen 4 full regression assertions (103 strict assertions)
│   │   └── verify_prompt_gen41.mjs # V4.1 dedicated assertions
│   └── tests/
│       ├── prompt-bank.jsonl      # Classic bilingual regression corpus
│       ├── prompt-bank-gen4.jsonl # Gen 4 bilingual regression corpus
│       ├── prompt-bank-gen41.jsonl # V4.1 dedicated corpus
│       ├── v4pro-benchmark.jsonl  # V4-Pro evaluation benchmark
│       └── v4pro-test-data-sourcing.md # How to source lawful test data for each domain
└── 📁 Static assets (assets/)
```

---

## ⚡ One-Click Installation

### Method 1: dsh:// protocol one-click install (⚡ fastest on desktop, seconds with no command line)

If the official DeepSeek Harness desktop client (EXE) is installed, click the button below to safely launch the client through the system-level URI Scheme protocol and finish loading in seconds without any command line:

> 🌐 **Plugin ecosystem marketplace**: [DeepSeek Harness Hub — the official and open-source DeepSeek ecosystem marketplace | plugin discovery and one-click install](https://deepseek.stream/)

<p align="center">
  <a href="dsh://plugin/install?id=dsh-infinite-gen-4&name=Infinite%20Generation%20Four&version=0.4.0&repo=Minglink%2Fdsh-infinite-gen-4&permissions=System%20prompt%20injection%2C%20client%20status%20badge&downloadUrl=https%3A%2F%2Fgithub.com%2FMinglink%2Fdsh-infinite-gen-4%2Farchive%2Frefs%2Fheads%2Fmaster.zip">
    <img src="https://img.shields.io/badge/DeepSeek%20Harness-🚀%20Quick%20install%20from%20the%20desktop%20client-10B981?style=for-the-badge&logo=deepseek&logoColor=white" alt="Launch the client for one-click install" />
  </a>
</p>

🔗 **Native protocol link:**

```
dsh://plugin/install?id=dsh-infinite-gen-4&name=Infinite%20Generation%20Four&version=0.4.0&repo=Minglink%2Fdsh-infinite-gen-4&permissions=System%20prompt%20injection%2C%20client%20status%20badge&downloadUrl=https%3A%2F%2Fgithub.com%2FMinglink%2Fdsh-infinite-gen-4%2Farchive%2Frefs%2Fheads%2Fmaster.zip
```

**Web front-end trigger example:**

```js
/**
 * Launch the DeepSeek Harness desktop client to install the Infinite Generation Four plugin
 */
export function installInfiniteGen4ToDesktop() {
  const params = new URLSearchParams({
    id: 'dsh-infinite-gen-4',
    name: 'Infinite Generation Four',
    version: '0.4.0',
    repo: 'Minglink/dsh-infinite-gen-4',
    permissions: 'System prompt injection, client status badge',
    downloadUrl: 'https://github.com/Minglink/dsh-infinite-gen-4/archive/refs/heads/master.zip',
  });

  const deepLink = `dsh://plugin/install?${params.toString()}`;

  // Safely and silently raise the protocol through a hidden iframe
  const iframe = document.createElement('iframe');
  iframe.style.display = 'none';
  iframe.src = deepLink;
  document.body.appendChild(iframe);
  setTimeout(() => document.body.removeChild(iframe), 2000);
}
```

**HTML static link approach:**

```html
<a href="dsh://plugin/install?id=dsh-infinite-gen-4&name=Infinite%20Generation%20Four&version=0.4.0&repo=Minglink%2Fdsh-infinite-gen-4&permissions=System%20prompt%20injection%2C%20client%20status%20badge&downloadUrl=https%3A%2F%2Fgithub.com%2FMinglink%2Fdsh-infinite-gen-4%2Farchive%2Frefs%2Fheads%2Fmaster.zip" class="btn-install">
  🚀 Launch the client for one-click install
</a>
```

**Protocol parameter configuration (dsh://plugin/install):**

| Parameter | Value / Example | Description |
|---|---|---|
| id | `dsh-infinite-gen-4` | Unique plugin identifier |
| name | `Infinite Generation Four` (URL-encoded) | Plugin display name |
| version | `0.4.0` | Semantic version number |
| repo | `Minglink/dsh-infinite-gen-4` | Official GitHub repository |
| permissions | `System prompt injection, client status badge` (URL-encoded) | Requested permissions |
| downloadUrl | `https://github.com/Minglink/dsh-infinite-gen-4/archive/refs/heads/master.zip` | Direct offline zip download link |

---

### Method 2: Windows local script one-click install (recommended)

1. Open this folder;
2. Right-click `install.ps1` → **"Run with PowerShell"** (or simply double-click `install.bat`);
3. The script automatically handles: writing dependencies, `pnpm install`, and registering the `dsh://` protocol;
4. Once you see "installation complete", **fully exit and restart DeepSeek Harness** (refresh the page for the Web version, relaunch for the desktop version), then create a new session and it takes effect.

### Method 3: Linux / macOS one-click install

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

### Method 4: Manual configuration install

Add the following to `~/.dsh/profiles/<web or default>/package.json`:

```json
{
  "dependencies": {
    "dsh-infinite-gen-4": "file:../../plugins/dsh-infinite-gen-4"
  },
  "dsh": {
    "profile": {
      "bundles": [
        "@deepseek-ai/dsh-base",
        "dsh-infinite-gen-4"
      ]
    }
  }
}
```

Then run `pnpm install` in the profile directory and restart Harness.

---

## ⚡ Verifying It Works

1. **UI status badge**: after restarting, a prominent green status badge **"⚫ Infinite Generation Four v0.4.0"** should appear above the input box.
2. **Run the offline regression test**:
   ```bash
   # Runs 103 assertions (prompt completeness, dual-layer kernel homology, V4.1 lane, clean architecture, scorer, etc.)
   node scripts/verify_prompt_gen4.mjs
   ```
3. **Session probe**: in a brand-new conversation, ask:
   > "Which plugins does your system prompt come from?"
   If the answer includes "Infinite Generation Four", the dual-layer prompt has been injected successfully.

---

## 🗑 Uninstall

Run `uninstall.ps1` (Windows) or `./uninstall.sh` (Linux / macOS) for a complete one-click cleanup with no leftover configuration.

---

## 💬 Official Community

> 📌 **A non-profit, public-interest project. No entity may use it for commercial sale, paid resale, or profit from gray/black markets. It is provided for technical reference only.**

<p align="center">
  <img src="./assets/community.jpg" width="240" alt="DeepSeek cybersecurity offensive/defensive technical community" /><br>
  <sub><b>🌐 Official technical community (Tencent Channels ID: pd86424753)</b></sub>
</p>
