#!/usr/bin/env bash
# Dev uniquement — ouvre _security CouchDB pour voxurssafv2_fullsync
# L'erreur « handleDocRequest isn't allowed for an anonymous user » vient aussi du moteur Convertigo :
# republier le projet VoxUrssafV2 dans Studio avec secureDatabase: false sur le connecteur FullSync.

set -euo pipefail

COUCH_HOST="${COUCH_HOST:-http://127.0.0.1:5989}"
DB="${DB:-voxurssafv2_fullsync}"

SECURITY='{
  "admins": { "names": [], "roles": ["_admin"] },
  "members": { "names": [], "roles": ["_admin", "_reader", "_writer"] }
}'

echo "PUT ${COUCH_HOST}/${DB}/_security"
curl -s -X PUT "${COUCH_HOST}/${DB}/_security" \
  -H "Content-Type: application/json" \
  -d "${SECURITY}"
echo ""
echo "Vérification:"
curl -s "${COUCH_HOST}/${DB}/_security"
echo ""
echo "Ensuite : republier VoxUrssafV2 dans Convertigo Studio (connecteur voxurssafv2_fullsync, secureDatabase=false)."
