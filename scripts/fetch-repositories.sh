#!/usr/bin/env bash
#
# Fetch repository metadata for a GitHub account and write it to
# data/repositories.json as a single JSON array.
#
# Read-only: only HTTP GET requests are issued against the GitHub API.
# Authentication is delegated entirely to GitHub CLI (`gh auth login`);
# this script never reads, stores, or prints credentials.
#
# Source endpoint: GET /users/{owner}/repos?type=owner
#   - lists the account's public repositories (the public portfolio);
#   - returns full GitHub API repository objects, preserved unmodified.
#
# Usage:
#   scripts/fetch-repositories.sh
#
# Environment (optional):
#   GITHUB_OWNER  account to collect (default: fnalin)

set -euo pipefail

OWNER="${GITHUB_OWNER:-fnalin}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${REPO_ROOT}/data"
OUTPUT_FILE="${OUTPUT_DIR}/repositories.json"

log() { printf '[fetch-repositories] %s\n' "$*" >&2; }
fail() { printf '[fetch-repositories] ERROR: %s\n' "$*" >&2; exit 1; }

# --- Prerequisites -----------------------------------------------------------

command -v gh >/dev/null 2>&1 \
  || fail "GitHub CLI (gh) is not installed. See https://cli.github.com/"
command -v jq >/dev/null 2>&1 \
  || fail "jq is not installed. It is required to merge and validate pages."

gh auth status --hostname github.com >/dev/null 2>&1 \
  || fail "GitHub CLI is not authenticated. Run 'gh auth login' and retry."

# --- Collection --------------------------------------------------------------

mkdir -p "${OUTPUT_DIR}"
TMP_FILE="$(mktemp "${OUTPUT_DIR}/.repositories.json.XXXXXX")"
trap 'rm -f "${TMP_FILE}"' EXIT

log "Fetching public repositories owned by '${OWNER}'..."

# --paginate follows Link headers; --slurp wraps every page in an outer array,
# which jq flattens into a single array of repository objects.
gh api \
  --method GET \
  --paginate \
  --slurp \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/users/${OWNER}/repos?type=owner&sort=full_name&direction=asc&per_page=100" \
  | jq 'add // []' > "${TMP_FILE}" \
  || fail "Failed to retrieve repository metadata from the GitHub API."

# --- Validation --------------------------------------------------------------

jq -e 'type == "array"' "${TMP_FILE}" >/dev/null \
  || fail "Result is not a JSON array."

jq -e 'all(.[]; (.name | type == "string") and (.name | length > 0))' "${TMP_FILE}" >/dev/null \
  || fail "One or more repositories are missing a name."

jq -e '(map(.id) | length) == (map(.id) | unique | length)' "${TMP_FILE}" >/dev/null \
  || fail "Duplicate repository IDs detected (possible pagination issue)."

jq -e '(map(.name | ascii_downcase) | length) == (map(.name | ascii_downcase) | unique | length)' "${TMP_FILE}" >/dev/null \
  || fail "Duplicate repository names detected."

jq -e --arg owner "${OWNER}" 'all(.[]; (.owner.login | ascii_downcase) == ($owner | ascii_downcase))' "${TMP_FILE}" >/dev/null \
  || fail "Result contains repositories not owned by '${OWNER}'."

# Cross-check against the account's public repository counter.
EXPECTED="$(gh api --method GET "/users/${OWNER}" --jq '.public_repos')" \
  || fail "Failed to retrieve account profile for count validation."
ACTUAL="$(jq 'length' "${TMP_FILE}")"
PUBLIC="$(jq 'map(select(.visibility == "public")) | length' "${TMP_FILE}")"

if [[ "${PUBLIC}" != "${EXPECTED}" ]]; then
  log "WARNING: ${PUBLIC} public repositories collected, but profile reports ${EXPECTED}."
fi

# --- Publish -----------------------------------------------------------------

# Atomic replace: reruns overwrite the dataset instead of appending to it.
chmod 644 "${TMP_FILE}"
mv "${TMP_FILE}" "${OUTPUT_FILE}"
trap - EXIT

log "Wrote ${ACTUAL} repositories (${PUBLIC} public; profile reports ${EXPECTED}) to ${OUTPUT_FILE#"${REPO_ROOT}/"}"
