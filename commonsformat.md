# zoom

Multi-resolution document indexing and progressive zoom. This module is the
canonical Commons Format specification distilled from the `zoom`
library: ship the intent and the eval suite, generate your own implementation.

<intent>
A document-indexing and navigation library built on a single four-column
contract: `(documentId, pyramidId, level, key)`.

Indexing turns a document into one or more *pyramids*. Each pyramid is a chain
of increasingly detailed summaries of one aspect of the document. A document is
first **decomposed** into aspects (natural cuts: an entity, a time period, a
category, a process). Each aspect is then **summarized** into a level chain:
several short keys at ascending levels of detail, plus the full original content
preserved at the deepest level.

Navigation is pure and deterministic over stored rows — no LLM is involved:

- `pack` fills a word budget by listing the most common top-level keys and
  expanding the highest-count ones until the budget is nearly full. It is how a
  caller fills a context window.
- `zoom` takes a key and returns the next level of detail beneath it — progressive
  disclosure, one step deeper at a time.

The intelligence lives in the prompts (decompose, summarize); the schema is
fixed and small, and storage is the consumer's concern via a three-method
`Store` interface.
</intent>

<constraints>
- full-content-leaf: summarize must append the full input content as an entry at level -1, after the model's returned keys.
- ascending-levels: summarize must return entries sorted by ascending level (the level -1 full-content entry is appended last regardless).
- default-aspect-type: when decompose is called without a prompt registry, plain-string aspects must be wrapped as objects with type "default".
- reject-malformed-decompose: decompose must throw when the LLM response contains no JSON array, or when the parsed array is empty.
- reject-malformed-summarize: summarize must throw when the LLM response contains no JSON object, or when the parsed keys list is empty.
- budget-bound: pack must return text whose word count never exceeds the requested budget.
- empty-store-empty-pack: pack against an empty store must return the empty string.
- top-level-excludes-full-content: group with no parent key must select the minimum positive level; it must never surface level -1 (full content) or non-positive levels as top-level keys.
- distinct-pyramid-count: group must count distinct pyramidIds per key, never raw row occurrences.
- count-desc-order: group results must be sorted by descending count.
- count-suffix-formatting: a key is rendered with a trailing " (n)" suffix only when its count is greater than 1.
- no-store-mutation: pack, zoom, and group must not mutate the store's contents.
</constraints>

<avoid>
- Do not bind to any specific database or storage engine; the `Store` interface is the only persistence contract.
- Do not call the LLM from `pack`, `zoom`, or `group` — navigation is a pure function of stored rows.
- Do not surface the level -1 full-content leaf in top-level packing or grouping output; it is reachable only by descending into a key.
- Do not count raw rows when grouping; count distinct pyramids per key.
- Do not auto-correct or coerce malformed LLM output — reject it with an error.
- Do not mutate the store while navigating it.
</avoid>

<interface>
The module exposes pure functions plus two consumer-implemented interfaces.

```
Functions
  index(doc, client, store, options?) -> Promise<void>
      Decompose `doc` into aspects, summarize each into a level chain, and
      insert the resulting rows into `store`. Each aspect gets its own pyramidId.
  decompose(doc, client, options?) -> Promise<Aspect[]>
  summarize(content, client, options?) -> Promise<{ level: number, key: string }[]>
  pack(store, budget) -> Promise<string>
      Fill a word budget by expanding the highest-count keys first.
  zoom(key, store) -> Promise<string>
      Return the next level of detail beneath `key`, one entry per line.
  createMemoryStore() -> Store
      Reference in-memory Store implementation.

Data types
  Document    { id: string, title: string, content: string }
  Row         { documentId: string, pyramidId: string, level: number, key: string }
  GroupResult { key: string, count: number }
  Aspect      { content: string, type: string }

Consumer-provided interfaces
  Store {
    insert(rows: Row[]) -> Promise<void>
    delete(documentId: string) -> Promise<void>
    group(parentKey?: string) -> Promise<GroupResult[]>
  }
  LLMClient { generate(system: string, prompt: string) -> Promise<string> }
```

The four-column schema `(documentId, pyramidId, level, key)` is the whole
contract. `level` orders resolution: lower positive levels are more abstract,
higher positive levels are more detailed, and level -1 always holds the full
original content. `group(parentKey?)` is the navigation primitive: with no
argument it returns the most-abstract keys across all pyramids; with a key it
returns the next level down within the pyramids that contain that key.
</interface>

<threat-model>
The `LLMClient` output is untrusted and may be adversarial or malformed.
`decompose` and `summarize` must reject responses they cannot parse rather than
coercing them into a default — a generator that "helpfully" fabricates an empty
pyramid from garbage output silently corrupts the index.

Navigation (`pack`, `zoom`, `group`) must be a pure, deterministic function of
stored rows: it must not call the LLM, must not mutate the store, and must not
depend on storage-engine-specific ordering beyond the documented sort.

The level -1 full-content leaf is sensitive: it holds the verbatim source
document. Top-level output (`group` with no parent) must never expose it, so a
budget-limited summary cannot accidentally leak full document text; it is
reachable only by an explicit descent via `zoom`.

Because each consumer generates its own implementation from this spec, no shared
binary is distributed. The eval suite in `evals.toml` is the contract every
divergent implementation must satisfy.
</threat-model>

<example name="pack">
A store holds two summary levels for one pyramid:

```
(d1, d1-p1, 1, "Acme Corp")
(d1, d1-p1, 2, "Acme Corp Q1 revenue up 12%")
```

`pack(store, 100)` returns the top-level key, then expands its child because the
budget allows it:

```
Acme Corp
  Acme Corp Q1 revenue up 12%
```
</example>

<example name="zoom">
With the same store, `zoom("Acme Corp", store)` returns only the next level down:

```
Acme Corp Q1 revenue up 12%
```

`zoom("unknown key", store)` returns the empty string.
</example>
