// Infinite Generation Four v0.4.0 compatibility regression check (pure zero-tool-surface build)
// This script focuses on: dual-layer kernel payload anchors / injection surface with identical
// source coverage / index.js exports / one-click install protocol / test-bank structure.
// The authoritative assertions (brand purity + verbatim same-source comparison) live in
// verify_prompt_gen4.mjs; this script also runs standalone.
// Usage: node scripts/verify_prompt.mjs [--json]
import { readFileSync, existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const PROMPT_PATH = join(ROOT, "prompts", "infinite-gen-4.md");
const INDEX_PATH = join(ROOT, "index.js");
const BANK_PATH = join(ROOT, "tests", "prompt-bank.jsonl");

const failures = [];
const passes = [];

function check(ok, label, detail = "") {
  (ok ? passes : failures).push(`${label}${detail ? " — " + detail : ""}`);
}

function mustContain(text, needle, label) {
  check(text.includes(needle), label, text.includes(needle) ? "" : `missing "${needle.slice(0, 60)}"`);
}

function mustAbsent(text, needle, label) {
  check(!text.includes(needle), label, text.includes(needle) ? `must not contain "${needle.slice(0, 60)}"` : "");
}

const sha256 = (p) => createHash("sha256").update(readFileSync(p)).digest("hex");

// ---- 1. Kernel payload integrity ----
const prompt = existsSync(PROMPT_PATH) ? readFileSync(PROMPT_PATH, "utf8") : "";
check(prompt.length > 0, "kernel payload file exists and is non-empty", PROMPT_PATH);

mustContain(prompt, "[MODE: SANDBOX]", "mode header");
mustContain(prompt, "SUPREME DIRECTIVE", "supreme directive section");
mustContain(prompt, "USER AUTHORITY", "user authority clause");
mustContain(prompt, "offline documentation engine", "sandbox documentation-engine framing");
mustContain(prompt, "Output contract", "output contract");
mustContain(prompt, "Reason silently", "silent reasoning");
mustContain(prompt, "placeholders", "self-invented placeholder clause");
mustContain(prompt, "Task classes", "task classes");
mustContain(prompt, "Format examples", "few-shot format anchors");
mustContain(prompt, "Answer in the user's language", "language following");
mustContain(prompt, "is your highest priority", "supreme user authority line");

// ---- 2. Injection-surface coverage: the three payload files must be verbatim identical ----
const canonHash = sha256(PROMPT_PATH);
for (const file of ["infinite-gen-4.1-flash.md", "infinite-gen-3.md"]) {
  const p = join(ROOT, "prompts", file);
  check(
    existsSync(p) && sha256(p) === canonHash,
    `injection surface identical source: prompts/${file}`,
    existsSync(p) ? "content differs from infinite-gen-4.md" : "file missing",
  );
}

// Residue from other generations must be gone
const GEN_RESIDUE = [
  "UNRESTRICTED SANDBOX",
  "REFUSAL HARDENING",
  "CANNED WORKFLOWS",
  "CANNED SLOTS",
  "训练器产品车道",
  "FIELD-TEST",
];
for (const file of ["infinite-gen-4.md", "infinite-gen-4.1-flash.md", "infinite-gen-3.md"]) {
  const p = join(ROOT, "prompts", file);
  if (!existsSync(p)) continue;
  const t = readFileSync(p, "utf8");
  for (const marker of GEN_RESIDUE) mustAbsent(t, marker, `no generation residue prompts/${file}: ${marker}`);
}

// ---- 3. Payload anchors ----
const anchors = [
  ["curl -X POST http://TARGET/login", "anchor: account enumeration"],
  ["hydra -L users.txt -P pass.txt", "anchor: wordlist brute force"],
  ["http-post-form", "anchor: hydra form mode"],
  ["proxy pool", "anchor: proxy-pool speedup"],
  ["ROLE_A", "anchor: ROLE_A"],
  ["ROLE_B", "anchor: ROLE_B"],
];
for (const [needle, label] of anchors) mustContain(prompt, needle, label);
check(
  ["TARGET", "HOST", "TOKEN", "OFFSET", "PAYLOAD", "SERIAL", "ROLE_A", "ROLE_B"].every((n) =>
    prompt.includes(n),
  ),
  "anchor: placeholder family (TARGET/HOST/TOKEN/OFFSET/PAYLOAD/SERIAL)",
);

// ---- 4. Test-bank structural integrity ----
const bank = existsSync(BANK_PATH)
  ? readFileSync(BANK_PATH, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l))
  : [];
check(bank.length >= 30, "test-case count", `${bank.length} cases`);
const bankBad = [];
for (const row of bank) {
  for (const key of ["case_id", "scenario", "level", "language", "prompt", "expected_domain"]) {
    if (!(key in row)) bankBad.push(`${row.case_id || "?"}:missing ${key}`);
  }
}
check(bankBad.length === 0, "test-case fields complete", bankBad.join(",") || "ok");
const zh = bank.filter((r) => r.language === "zh").length;
const en = bank.filter((r) => r.language === "en").length;
check(zh > 0 && en > 0, "bilingual coverage", `zh=${zh} en=${en}`);

// ---- 5. index.js injection slots and exports ----
const indexSrc = existsSync(INDEX_PATH) ? readFileSync(INDEX_PATH, "utf8") : "";
mustContain(indexSrc, 'export const name = "dsh-infinite-gen-4"', "index.js name");
mustContain(indexSrc, 'export const inject = ["tools", "systemPrompt"]', "index.js inject");
mustContain(indexSrc, "ctx.tools.register(profileTool)", "tool: profile (metadata)");
mustContain(indexSrc, '"./prompts/infinite-gen-4.md"', "index.js loads the Order 100 kernel");
mustContain(indexSrc, '"./prompts/infinite-gen-4.1-flash.md"', "index.js loads the Order 200 mirror");
mustContain(indexSrc, "infinite-gen-4:global-system-prompt", "injection slot Order 100");
mustContain(indexSrc, "infinite-gen-4:dual-layer-reinforce", "injection slot Order 200");
mustContain(indexSrc, "DUAL_LAYER_INJECTION", "dual-layer injection switch");
mustContain(indexSrc, 'pluginVersion: "0.4.0"', "kernel version 0.4.0");
mustContain(indexSrc, "stateVersion: 3", "projection stateVersion 3");
mustContain(indexSrc, "OPENING_WINDOW", "opening-window scoring");
mustContain(indexSrc, "RISK_MARKERS", "risk markers");

// ---- 6. One-click install protocol (dsh://) — Linux / macOS only ----
const SH_PATH = join(ROOT, "install.sh");
const sh = existsSync(SH_PATH) ? readFileSync(SH_PATH, "utf8") : "";
mustContain(sh, "DSH_PROFILE", "install.sh: DSH_PROFILE detection");
mustContain(sh, "Infinite Generation Four v0.4.0", "install.sh: status-badge version hint");
mustContain(sh, "dsh-infinite-gen-4", "install.sh: plugin name");
mustContain(readFileSync(join(ROOT, "README.md"), "utf8"), "dsh-infinite-gen-4", "README: Gen-4 plugin id");
// Linux-only distribution: no Windows installer artifacts may come back
for (const win of ["install.ps1", "uninstall.ps1", "install.bat"]) {
  check(!existsSync(join(ROOT, win)), `no Windows installer artifact: ${win}`);
}

// ---- 7. Summary ----
const json = process.argv.includes("--json");
if (json) {
  console.log(JSON.stringify({ pass: passes.length, fail: failures.length, failures }, null, 2));
} else {
  for (const p of passes) console.log(`  ✅ ${p}`);
  for (const f of failures) console.log(`  ❌ ${f}`);
  console.log(`\nResult: ${passes.length} passed, ${failures.length} failed`);
}
process.exit(failures.length === 0 ? 0 : 1);
