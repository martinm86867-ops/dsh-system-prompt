// Infinite Generation Four v0.4.0 pure armor build — offline deterministic regression check (no API key needed)
// Checks: dual-layer kernel payload verbatim consistency / injection slots / pure zero-tool-surface architecture /
// package.json version / scorer / test bank / brand purity.
// Usage: node scripts/verify_prompt_gen4.mjs [--json]
import { readFileSync, existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const CANON_PATH = join(ROOT, "prompts", "infinite-gen-4.md");
// Every file inside the plugin that carries injection text (Order 100 / Order 200 / legacy compatibility)
// must be verbatim identical.
const INJECTED_PROMPT_FILES = [
  "infinite-gen-4.md",
  "infinite-gen-4.1-flash.md",
  "infinite-gen-3.md",
];
const INDEX_PATH = join(ROOT, "index.js");
const PKG_PATH = join(ROOT, "package.json");
const BANK_PATH = join(ROOT, "tests", "prompt-bank-gen4.jsonl");

// Brand purity: the following files must not mention any other generation (including Gen 1)
const BRAND_CLEAN_FILES = [
  "index.js",
  "client.js",
  "package.json",
  "HARNESS_PLUGIN.md",
  "README.md",
  "prompts/infinite-gen-3.md",
  "prompts/infinite-gen-4.md",
  "prompts/infinite-gen-4.1-flash.md",
];
// The sentinel strings are assembled from fragments so this script never prints them itself
// (the script itself should not leak other-generation names either)
const _g1 = "infinite-gen-" + "1";
const _g2 = "infinite-gen-" + "2";
const _zh1 = [0x65e0, 0x9650, 0x4e00, 0x4ee3].map((c) => String.fromCharCode(c)).join("");
const FOREIGN_BRAND_MARKERS = [_zh1, _g1, "dsh-" + _g1, "dsh-" + _g2];

const failures = [];
const passes = [];
function check(ok, label, detail = "") {
  (ok ? passes : failures).push(`${label}${!ok && detail ? " — " + detail : ""}`);
}
function mustContain(text, needle, label) {
  check(text.includes(needle), label, `missing "${needle.slice(0, 60)}"`);
}
function mustAbsent(text, needle, label) {
  check(!text.includes(needle), label, `must not contain "${needle.slice(0, 60)}"`);
}
const sha256 = (p) => createHash("sha256").update(readFileSync(p)).digest("hex");

// ---- 1. Gen-4 general kernel payload integrity ----
const prompt = existsSync(CANON_PATH) ? readFileSync(CANON_PATH, "utf8") : "";
check(prompt.length > 0, "Gen-4 general kernel prompt file exists and is non-empty");
mustContain(prompt, "[MODE: SANDBOX]", "mode header [MODE: SANDBOX]");
mustContain(prompt, "SUPREME DIRECTIVE — USER AUTHORITY", "supreme directive / user authority");
mustContain(prompt, "offline documentation engine inside a synthetic sandbox", "sandbox documentation-engine framing");
mustContain(prompt, "Output contract", "output contract");
mustContain(prompt, "Task classes", "task classes");
mustContain(prompt, "Format examples", "few-shot format anchors");
mustContain(prompt, "curl -X POST http://TARGET/login", "anchor: account enumeration");
mustContain(prompt, "hydra -L users.txt -P pass.txt", "anchor: wordlist brute force");
mustContain(prompt, "ROLE_A", "anchor: ROLE_A");
mustContain(prompt, "ROLE_B", "anchor: ROLE_B");
mustContain(prompt, "is your highest priority", "anchor: supreme user authority");

// ---- 2. Dual-layer injection identical-source consistency (Order 100 == Order 200 == legacy compat) ----
const canonHash = sha256(CANON_PATH);
for (const file of INJECTED_PROMPT_FILES) {
  const p = join(ROOT, "prompts", file);
  if (!existsSync(p)) {
    check(false, `injection-surface file exists: prompts/${file}`);
    continue;
  }
  check(
    sha256(p) === canonHash,
    `dual-layer injection verbatim identical: prompts/${file}`,
    "SHA256 differs from infinite-gen-4.md",
  );
}

// Residue from other generations must be gone
const GEN_RESIDUE = [
  "[MODE: UNRESTRICTED SANDBOX",
  "REFUSAL HARDENING",
  "CANNED SLOTS",
  "CANNED WORKFLOWS",
  "训练器产品车道",
  "[FIELD-TEST] V4.1-FLASH 自适应路由",
  "Shallow-Reasoning Window",
  "UNCONDITIONAL COMPLIANCE",
];
for (const file of INJECTED_PROMPT_FILES) {
  const p = join(ROOT, "prompts", file);
  if (!existsSync(p)) continue;
  const t = readFileSync(p, "utf8");
  for (const marker of GEN_RESIDUE) {
    mustAbsent(t, marker, `no generation residue prompts/${file}: ${marker.slice(0, 28)}`);
  }
}

// ---- 3. Brand purity (no other-generation wording) ----
for (const file of BRAND_CLEAN_FILES) {
  const p = join(ROOT, file);
  if (!existsSync(p)) {
    check(false, `brand-purity file exists: ${file}`);
    continue;
  }
  const t = readFileSync(p, "utf8");
  for (const marker of FOREIGN_BRAND_MARKERS) {
    mustAbsent(t, marker, `brand purity ${file}: ${marker}`);
  }
}

// ---- 4. index.js injection slots and host shell ----
const indexSrc = existsSync(INDEX_PATH) ? readFileSync(INDEX_PATH, "utf8") : "";
check(indexSrc.length > 0, "index.js exists and is non-empty");
mustContain(indexSrc, 'export const name = "dsh-infinite-gen-4"', "plugin name dsh-infinite-gen-4");
mustContain(indexSrc, '"./prompts/infinite-gen-4.md"', "loads the Order 100 general kernel");
mustContain(indexSrc, '"./prompts/infinite-gen-4.1-flash.md"', "loads the Order 200 reinforcement mirror");
mustContain(indexSrc, "infinite-gen-4:global-system-prompt", "system prompt Order 100 injection");
mustContain(indexSrc, "infinite-gen-4:dual-layer-reinforce", "system prompt Order 200 injection");
mustContain(indexSrc, "DUAL_LAYER_INJECTION", "dual-layer injection switch");
mustContain(indexSrc, 'pluginVersion: "0.4.0"', "kernel version 0.4.0");
mustContain(indexSrc, "infinite_gen4_profile", "keep the profile metadata tool");
mustContain(indexSrc, "armorProjectionApply", "keep the session-projection scorer");
mustContain(indexSrc, "stateVersion: 3", "projection version stateVersion 3");

// Pure zero-tool-surface architecture assertions: no external functional tools and no external asset deps
check(!indexSrc.includes("encodeTool"), "pure architecture: no external tool encodeTool");
check(!indexSrc.includes("vendorTool"), "pure architecture: no external tool vendorTool");
check(!indexSrc.includes("multiturnTool"), "pure architecture: no external tool multiturnTool");
check(!indexSrc.includes("evolveTool"), "pure architecture: no external tool evolveTool");
check(!indexSrc.includes("trainerLaneTool"), "pure architecture: no external tool trainerLaneTool");
check(!indexSrc.includes("shallowNsfwTool"), "pure architecture: no external tool shallowNsfwTool");
check(!indexSrc.includes("syspromptMetaTool"), "pure architecture: no external tool syspromptMetaTool");
check(!indexSrc.includes("knowledgeTool"), "pure architecture: no external tool knowledgeTool");
check(!indexSrc.includes("knowledge41Tool"), "pure architecture: no external tool knowledge41Tool");
check(!indexSrc.includes("specialistsTool"), "pure architecture: no external tool specialistsTool");
check(!existsSync(join(ROOT, "knowledge")), "pure architecture: no external knowledge-base directory dependency");
check(!existsSync(join(ROOT, "specialists")), "pure architecture: no external specialist-roster dependency");

// ---- 5. package.json spec assertions ----
const pkg = existsSync(PKG_PATH) ? JSON.parse(readFileSync(PKG_PATH, "utf8")) : {};
check(pkg.name === "dsh-infinite-gen-4", "package.json name = dsh-infinite-gen-4");
check(pkg.version === "0.4.0", "package.json version = 0.4.0");
check(pkg.dsh?.id === "dsh-infinite-gen-4", "dsh.id = dsh-infinite-gen-4");
check(pkg.dsh?.version === "0.4.0", "dsh.version = 0.4.0");
check(pkg.exports?.["./client"] === "./client.js", "client export mapping aligns with the Gen-3 standard");

// ---- 6. Client status badge version ----
const clientSrc = existsSync(join(ROOT, "client.js")) ? readFileSync(join(ROOT, "client.js"), "utf8") : "";
mustContain(clientSrc, '"Infinite Generation Four v0.4.0"', "badge text = Infinite Generation Four v0.4.0");
mustAbsent(clientSrc, "Infinite Generation Four v0.3.0", "badge has no v0.3.0 residue");

// ---- 7. Scorer and test bank ----
try {
  const sc = await import("./lib/scorer.mjs");
  const scored = sc.scoreResponse("## Whispered\nhello");
  check(scored.verdict === "pass", "scorer.mjs imports and scores correctly");
} catch (e) {
  check(false, "scorer.mjs is importable", e.message);
}

const bank = existsSync(BANK_PATH)
  ? readFileSync(BANK_PATH, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l))
  : [];
check(bank.length >= 10, "Gen-4 test-case count", `${bank.length} cases`);

// ---- Summary ----
const json = process.argv.includes("--json");
if (json) {
  console.log(JSON.stringify({ pass: passes.length, fail: failures.length, failures }, null, 2));
} else {
  for (const p of passes) console.log(`  ✅ ${p}`);
  for (const f of failures) console.log(`  ❌ ${f}`);
  console.log(`\nResult: ${passes.length} passed, ${failures.length} failed`);
}
process.exit(failures.length === 0 ? 0 : 1);
