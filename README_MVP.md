# VoxUrssafV2 — Application concrète

Interface **voxUrssafReact** + persistance **FullSync** (PouchDB local / CouchDB serveur) + export **SQL** métier.

## Architecture données

```text
Mobile (PouchDB)  ←── pull/push ──→  CouchDB (voxurssafv2_fullsync)
                                           │
                                           ▼
                                    HSQLDB (voxurssaf_v2)
                                    via FS_ExportInterviewToSql
```

| Couche | Rôle |
|--------|------|
| **FullSync** `fs://voxurssafv2_fullsync` | Source principale offline (config + interviews) |
| **localStorage** `voxurssaf_v2_data` | Migration one-shot au premier lancement post-mise à jour |
| **SQL** `voxurssaf` | SI métier (export après push, pas d’écriture directe depuis chaque note) |

Modèle CouchDB : [`_c8oProject/fullsync/DATA_MODEL.md`](_c8oProject/fullsync/DATA_MODEL.md)

## Prérequis Studio / serveur

1. **CouchDB** configuré dans les *engine settings* Convertigo.
2. Connecteur **voxurssafv2_fullsync** publié en dev avec :
   - `anonymousReplication: allow` (pull/push réplication)
   - `secureDatabase: false` (sinon *handleDocRequest isn't allowed for an anonymous user* sur `_bulk_docs`)
   - **Republier** le projet après changement (Convertigo met à jour la sécurité CouchDB).
   - Si l’erreur persiste : dans Fauxton, base `voxurssafv2_fullsync` → supprimer ou assouplir le document `_security`, puis republier.
   - En prod : `secureDatabase: true`, `anonymousReplication: deny`, authentification obligatoire.
3. Transactions `PostDocument`, `GetDocument`, `GetView`, `PostBulkDocuments`.
4. Une fois par environnement : exécuter **VoxUrssafV2.FS_InitDesign** (design `_design/vu` — voir `fullsync/design_vu.json`).
5. Connecteur SQL **voxurssaf** (HSQLDB `hsqldb/voxurssaf_v2` en dev).

## Parcours

1. **Accueil** — liste des interviews (vue `interviews_by_device`), KPI, **Synchroniser** = push FullSync + export SQL
2. **Nouvelle fiche** — création interview (`draft`) → doc CouchDB local
3. **Interview active** — capture texte / dictée / photo, fin de session → `saved`
4. **Toutes les interviews** — recherche et reprise
5. **Questions** / **Profil** — doc `config:{deviceId}`

## Backend (Convertigo)

| Élément | Chemin |
|---------|--------|
| FullSync | `_c8oProject/connectors/voxurssafv2_fullsync.yaml` |
| SQL | `_c8oProject/connectors/voxurssaf.yaml` |
| Séquences | `Interview_Save`, `Interview_UploadPhoto`, `FS_ExportInterviewToSql`, `FS_InitDesign` |

## Responsive

**Mobile** &lt; 640px pleine largeur ; **≥ 640px** (tablette et PC) colonne centrée unique (720px max). Checklist : [`RESPONSIVE_QA.md`](RESPONSIVE_QA.md).

## Tests manuels

| Scénario | Attendu |
|----------|---------|
| Hors ligne | Créer interview + notes + photo → rechargement app → données présentes (PouchDB) |
| En ligne | Pull au démarrage → push depuis accueil → documents visibles dans CouchDB |
| Export | Interview `saved` → sync → statut `synced` + lignes dans HSQLDB |
| Migration | Avec ancienne clé `voxurssaf_v2_data` → premier lancement migre puis supprime la clé |

## Build

1. Ouvrir **VoxUrssafV2** dans Convertigo Studio
2. Synchroniser le projet mobile
3. **Build and run** (micro + caméra : device ou HTTPS)

## Plugins Cordova

- `cordova-plugin-speechrecognition`
- `cordova-plugin-camera`
