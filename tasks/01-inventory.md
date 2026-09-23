# Task 01 — Repository Inventory

## Status

READY

## Objective

Create a complete and factual inventory of the GitHub repositories contained in the supplied GitHub API metadata.

This is a metadata analysis only.

Do not inspect repository source code during this task.

---

## Inputs

Read:

- `data/github-repos-1.json`
- `data/github-repos-2.json`

Treat both files as read-only.

---

## Output

Create:

`reports/01-inventory.md`

Do not modify any other project file unless required to complete this task.

---

## Instructions

Combine repositories from both input files into one inventory.

Detect and report duplicates if they exist.

For each repository, extract available metadata relevant to the audit, including when available:

- repository name;
- description;
- GitHub URL;
- created date;
- last updated date;
- last pushed date;
- primary language;
- fork status;
- archived status;
- disabled status;
- visibility;
- default branch;
- stars;
- forks;
- open issues;
- repository size;
- license;
- topics.

Do not infer missing values.

Use `UNKNOWN` or an equivalent explicit representation when information is unavailable.

---

## Analysis

After the factual inventory, provide a preliminary metadata-only assessment.

Identify repositories that appear to deserve deeper investigation based on signals such as:

- potentially substantial original projects;
- relevance to .NET/backend development;
- unusual technical scope;
- significant documentation or activity;
- potentially useful historical projects;
- repositories that may represent studies/tutorials;
- forks;
- apparently abandoned or empty repositories.

Do not make strong code-quality claims from metadata.

---

## Constraints

During this task:

- Do NOT clone repositories.
- Do NOT inspect repository source code remotely.
- Do NOT modify GitHub.
- Do NOT archive repositories.
- Do NOT delete repositories.
- Do NOT change repository visibility.
- Do NOT classify repositories as final portfolio decisions.
- Do NOT execute later tasks.

All recommendations must clearly state that they are preliminary and metadata-based.

---

## Report Structure

`reports/01-inventory.md` should contain:

### Executive Summary

Include:

- total repositories;
- original repositories;
- forks;
- archived repositories;
- primary languages;
- repository age distribution when useful;
- other notable metadata observations.

### Repository Inventory

Create a table containing the most useful metadata for every repository.

### Potential Deep-Review Candidates

Identify repositories that appear worth inspecting further.

Explain the metadata evidence behind each selection.

### Potential Low-Priority Repositories

Identify obvious forks, experiments, empty repositories, or other repositories that may not require immediate deep analysis.

Do not recommend deletion based only on metadata.

### Data Quality / Missing Information

Document incomplete, inconsistent, duplicated, or missing metadata.

### Proposed Next Step

Describe what should be investigated next.

Do not perform that next step.

---

## Acceptance Criteria

The task is complete only when:

- both JSON files have been read;
- every unique repository appears in the inventory;
- duplicates have been identified;
- repository counts reconcile with the input data;
- no repositories have been cloned;
- no remote GitHub changes have been made;
- metadata facts are distinguished from interpretation;
- `reports/01-inventory.md` exists;
- the report explicitly states that recommendations are preliminary.

After satisfying these criteria, STOP and present a concise summary to the user.