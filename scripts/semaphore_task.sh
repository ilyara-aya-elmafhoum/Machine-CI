#!/bin/bash
set -euo pipefail

# -----------------------------
# Paramètres
# -----------------------------
ACTION=${1:-create}        # create / ansible / destroy
TEMPLATE_ID=${2:-18}       # Template Semaphore

# Variables globales
SEMAPHORE_URL="${SEMAPHORE_URL:-http://84.234.24.138:3000}"
PROJECT_ID="${PROJECT_ID:-1}"
TOKEN="${SEMAPHORE_TOKEN:-}"
GITHUB_REPO="${GITHUB_REPO:-ilyara-aya-elmafhoum/backend}"
GITHUB_RUNNER_TOKEN="${GITHUB_RUNNER_TOKEN:-}"

# -----------------------------
# Vérifications
# -----------------------------
if [[ -z "$TOKEN" ]]; then
  echo " SEMAPHORE_TOKEN non défini."
  exit 1
fi

if [[ "$ACTION" == "ansible" && -z "$GITHUB_RUNNER_TOKEN" ]]; then
  echo "GITHUB_RUNNER_TOKEN non défini pour l’action ansible."
  exit 1
fi

echo "🔹 Action: $ACTION (template_id=$TEMPLATE_ID)"
echo "🔹 Semaphore URL: $SEMAPHORE_URL"
echo "🔹 Project ID: $PROJECT_ID"

# -----------------------------
# Préparation du payload JSON
# -----------------------------
if [[ "$ACTION" == "ansible" ]]; then
  JSON_PAYLOAD=$(jq -n \
    --arg template_id "$TEMPLATE_ID" \
    --arg action "$ACTION" \
    --arg github_token "$GITHUB_RUNNER_TOKEN" \
    --arg github_repo "$GITHUB_REPO" \
    '{
      template_id: ($template_id | tonumber),
      environment_variables: {
        ACTION: $action,
        github_token: $github_token,
        github_repo: $github_repo
      }
    }')
else
  JSON_PAYLOAD=$(jq -n \
    --arg template_id "$TEMPLATE_ID" \
    --arg action "$ACTION" \
    '{
      template_id: ($template_id | tonumber),
      environment_variables: { ACTION: $action }
    }')
fi

# -----------------------------
# Appel à l’API Semaphore
# -----------------------------
API_URL="$SEMAPHORE_URL/api/project/$PROJECT_ID/tasks"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [[ "$HTTP_STATUS" != "201" ]]; then
  echo " Erreur lors du déclenchement de la tâche Semaphore (HTTP $HTTP_STATUS)"
  echo "$BODY" | jq . || echo "$BODY"
  exit 1
fi

TASK_ID=$(echo "$BODY" | jq -r '.id // empty')
echo " Task Semaphore déclenchée avec succès !"
echo "🔗 Lien : $SEMAPHORE_URL/projects/$PROJECT_ID/tasks/$TASK_ID"
