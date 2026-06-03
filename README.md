# commonsformat-zoom

A [Commons Format](https://commonsformat.dev/) module — **verifiable intent, not
compiled code.** This repo ships a prose specification and a machine-checkable
eval suite for `zoom`: multi-resolution document indexing and progressive zoom.
You generate your own implementation from it.

Distilled from the [`zoom`](https://github.com/hays-hutton) library.

## What's in here

| File | Purpose |
|------|---------|
| `commonsformat.toml` | Module metadata, version, license, eval pointer |
| `commonsformat.md` | Canonical prose: `<intent>`, `<constraints>`, `<avoid>`, `<interface>`, `<threat-model>`, `<example>` |
| `evals.toml` | Conformance suite — functional, adversarial, and generator-adversary cases |
| `schema.sql` | Data shape of the four-column contract (shape, not storage) |
| `LICENSE` | MIT |

## Reference it

This module is identified by its Git URL — there is no central registry:

```
github.com/hays-hutton/commonsformat-zoom@v0.0.3
```

A consumer's toolchain:

1. **Resolve** — fetch this spec at a pinned commit.
2. **Generate** — produce an implementation in your target language from
   `commonsformat.md`, against your own style/constitution and seed.
3. **Verify** — run `evals.toml` against the generated code.
4. **Lock** — record the spec commit, generator, and verification results.

## What it specifies

A four-column contract — `(documentId, pyramidId, level, key)` — and three
operations over it:

- **index** — decompose a document into aspects, summarize each into a level
  chain, store the rows.
- **pack** — fill a word budget with the most common keys, expanding the
  highest-count ones (fills a context window).
- **zoom** — return the next level of detail beneath a key (progressive
  disclosure).

Navigation (`pack`, `zoom`, `group`) is pure and deterministic — no LLM. The
intelligence is in the decompose/summarize prompts; the schema is fixed and
small; storage is the consumer's via a three-method `Store` interface.

See `commonsformat.md` for the full contract.
