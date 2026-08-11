# FullSync data model — voxurssafv2_fullsync

## Design document

Publish once per environment via `KitUsager.FS_InitDesign` or by putting [`design_vu.json`](design_vu.json) into CouchDB:

```bash
curl -X PUT "http://127.0.0.1:5983/voxurssafv2_fullsync/_design/vu" \
  -H "Content-Type: application/json" \
  --data-binary @_c8oProject/fullsync/design_vu.json
```

Views:

| View | Key | Value |
|------|-----|-------|
| `interviews_by_device` | `deviceId` | `{ interviewId, status, updatedAt }` |
| `config_by_device` | `deviceId` | `null` |

Document types: `interview` (`_id` = `interview:{id}`), `config` (`_id` = `config:{deviceId}`).

The mobile store also seeds `_design/vu` locally via `ensureDesignDoc()` so view queries work offline without a prior pull.
