# Defender-Mode Codegen — One Page

**The ask:** Offer a *defender-mode* generation capability — given an intent-spec
(prose + eval suite), generate an implementation that is **conformant**,
**deliberately divergent** from other valid implementations, and shipped with a
**fault-divergence score** measuring how differently it *fails*, not just reads.

---

**The reframe (the line that matters):** OSS didn't break because code is shared.
It broke because **defense is socialized while value is privatized** — defense is
a public good funded by unmotivated volunteers, while value-at-risk accrues
privately to thousands of deployers. Frontier exploit-finding (no observed
plateau) lets an attacker pay once and capture the entire summed global VaR. That
externality is what AI now exploits at scale.

**The repair:** Distribute *intent*, not *bytes*. Each consumer generates a
private implementation. This (1) **deletes the attacker's amortization** — no
single break captures the global base — and (2) **re-privatizes defense** — the
deployer owns the implementation *and* the VaR, so spends proportional to actual
stake. The motivated party finally funds the defense.

**The hole:** Same spec + overlapping training data → implementations *cluster*.
Hoped-for divergence is not divergence you have. Fragmentation is sound in
principle, hollow in practice **unless someone manufactures the divergence.**

**Why the provider:** You are the one actor who can *engineer* divergence at
generation time (varied algorithms, structures, control flow, language —
semantics preserved, eval-verified) and *certify* it. And the divergence is a
**property of the target, not a secret**: the attacker has frontier models too,
but every deployed instance has a different lock, and knowing that doesn't give
the key. Robust to a peer-capable attacker — *not* security-through-obscurity.
The coordination problem that defeats every other defense doesn't apply: there
are ~5 of you, and only the **protocol** needs coordinating, never the internals.

---

**The three honest bounds (state them — they make the ask credible):**

1. **Semantic ceiling** — divergence must pass evals, so it's semantics-preserving
   and can't touch contract-level logic bugs. Those are covered by the
   *compounding shared eval suite* (every exploit found anywhere becomes a
   permanent eval everywhere). Complementary, not substitutes.
2. **Generator-root monoculture** — divergence at the leaf, one model at the root =
   poison once, corrupt every leaf. Requires **independent multi-provider**
   participation: coordinate the protocol, keep internals independent.
3. **Measurement** — "non-trivial randomness" is an assertion until scored. A
   **fault-divergence metric** (mutation/fault-injection: do two impls *fail*
   differently?) is the certificate *and* the independence registry the ecosystem
   lacks.

---

**Where the ask sits in the full program:**

| Threat layer | Defense |
|---|---|
| Implementation bugs (idiom, language, memory) | **Engineered divergence ← the ask** |
| Contract/logic bugs (shared by all impls) | Compounding shared eval suite |
| High-VaR head (crypto, parsers, serialization) | Formal artifacts + VaR-reduction |
| Generator-root monoculture | Independent multi-provider participation |
| Enforcement / adoption | Lockfile as insurance/compliance artifact |

---

**Build:** (1) a defender-mode generation flag with a divergence objective beside
correctness; (2) a fault-divergence score per generation; (3) protocol
coordination with peers, internals kept private.

**Timing:** The prior flips on the first *publicly attributed* no-plateau
mass-exploitation event — after which "visibility is a liability" becomes the
underwriter's checklist. This is written to persuade *before* that, the harder
and more useful case.
