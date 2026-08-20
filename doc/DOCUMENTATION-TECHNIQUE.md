# KitUsager — Documentation technique

**Version app :** 1.4.0 (`c8oProject.yaml` / `getAppVersion()`)  
**Date :** 20 août 2026  
**Studio :** Convertigo 8.4.0.m006  
**Template mobile :** `mobilebuilder_tpl_8_4_0_ngx`  
**Endpoint Studio (dev) :** `http://localhost:18080/convertigo`

> Guide enquêteur : [GUIDE-METIER.md](GUIDE-METIER.md)

---

## 1. Vue d’ensemble

KitUsager est un projet Convertigo **NGX / Ionic**, packagé en **APK Android**. Elle collecte des interviews format `salon` (wizard 5 pages), les persiste **en local** (`localStorage` + cache mémoire), et permet un round-trip **JSON / CSV**.

Le connecteur SQL Postgres, les séquences `Interview_*` / `FS_*` et le FullSync CouchDB sont **dans le projet** mais **non utilisés opérationnellement** : aucune base n’est branchée. Le code de sync reste pour une reprise ultérieure.

Signature affichée : `Urssaf Caisse nationale DRH/DSI-FITT-Studio RAD 2025-2026`.

```
Enquêteur
  → wizard (Page → Step1 → Verbatim → Step2 → Step3 → Step4)
  → completeSalonInterview() → status = saved
  → snapshot localStorage (CACHE_LS_KEY)
  → InterviewDataIO : export / import fichiers
  → [non branché] syncInterview → KitUsager.Interview_Save + Interview_UploadPhoto
  → [non branché] FullSync fs://voxurssafv2_fullsync
```

---

## 2. Stack et prérequis

| Couche | Technologie |
|--------|-------------|
| Backend projet | Convertigo 8.4, YAML `_c8oProject/` |
| Front | Ionic / Angular NGX (template 8.4) |
| Store | Objet `interviewStore` dans `mobileNgxApp.yaml` (`scriptContent`) |
| Persistance actuelle | `localStorage` (`voxurssaf_v2_offline_cache`, device id, liste d’ids) |
| SQL (cible) | Connecteur `voxurssaf` — Postgres JDBC `localhost:5435` / base `voxurssaf_v2` |
| FullSync (cible) | `voxurssafv2_fullsync` |
| Cordova | 13 / engine 14.0.1, minSdk 22, JDK 17, build-tools 35 |
| Plugins app | `cordova-plugin-speechrecognition` ~1.2.0, `cordova-plugin-camera` ~7.0.0 |

**Prérequis pour développer**

- Convertigo Studio 8.4 avec le projet `KitUsager` et la référence `mobilebuilder_tpl_8_4_0_ngx`
- Pour un futur branchement SQL : Postgres joignable ; identifiants JDBC dans `_c8oProject/connectors/voxurssaf.yaml` (ne pas les dupliquer dans ce document)
- Pour un futur FullSync : CouchDB configuré dans l’engine, projet **republier** après changement `secureDatabase` / `anonymousReplication`

**Ne pas activer trop tôt** : `initWithPage` ne fait **pas** de pull/push au démarrage (évite `_bulk_docs` anonymous). Commentaire dans le store : sync seulement quand le serveur est prêt.

---

## 3. Structure du projet

```
KitUsager/
├── c8oProject.yaml                 # racine projet, connectors, sequences, Application
├── _c8oProject/
│   ├── mobileNgxApp.yaml           # app NGX : store, routes, styles, speech
│   ├── mobilePages/                # 10 pages YAML
│   ├── connectors/
│   │   ├── voxurssaf.yaml          # SQL Postgres (cible)
│   │   ├── voxurssafv2_fullsync.yaml
│   │   └── void.yaml               # placeholder template
│   └── sequences/                  # Interview_* , FS_*
├── DisplayObjects/platforms/Android/config.xml
├── build-apk/KitUsager_Android.apk
├── doc/                            # cette documentation
├── readme.md                       # index
├── README_MVP.md                   # historique VoxUrssaf — ne pas suivre à la lettre
└── project.md                      # dump Studio auto-généré
```

Git : `KitUsager/` est un dépôt imbriqué. `_private/` et le build Cordova sont gitignorés.

---

## 4. Application mobile

Logique centrale : `getInterviewStore()` dans `_c8oProject/mobileNgxApp.yaml` (bloc `/*Begin_c8o_AppFunction*/`). Exposé sur `app.global.interviewStore`.

### Routes

| Page YAML | Segment / URL | Rôle |
|-----------|---------------|------|
| `Page.yaml` | `/` (root) | Accueil |
| `InterviewStep1.yaml` | `/interview-step-1` | Wizard 1 — nom salon |
| `InterviewStepVerbatim.yaml` | `/interview-step-verbatim` | Wizard 2 — verbatim + STT |
| `InterviewStep2.yaml` | `/interview-step-2` | Wizard 3 — parcours smileys |
| `InterviewStep3.yaml` | `/interview-step-3` | Wizard 4 — profil |
| `InterviewStep4.yaml` | `/interview-step-4` | Wizard 5 — consentement / validation |
| `InterviewRecap.yaml` | `/interview-recap` | Lecture fiche validée |
| `InterviewAll.yaml` | `/interview-all` | Liste + recherche |
| `InterviewDataIO.yaml` | `/interview-data-io` | Import / export / publish |
| `InvestigatorProfile.yaml` | `/investigator-profile` | Nom + photo enquêteur |

Helper `wizardPageUrl` / `getWizardRoute(step)` :

```
1 → /interview-step-1
2 → /interview-step-verbatim
3 → /interview-step-2
4 → /interview-step-3
5 → /interview-step-4
```

Les commentaires YAML de certaines pages disent encore « étape 1/4 » : **ignorer**, l’UI affiche x/5.

### Store — clés locales

| Constante | Clé | Contenu |
|-----------|-----|---------|
| `CACHE_LS_KEY` | `voxurssaf_v2_offline_cache` | Snapshot config + interviews |
| `DEVICE_LS_KEY` | `voxurssaf_v2_device_id` | Id appareil |
| `INTERVIEWS_LS_KEY` | `voxurssaf_v2_interview_ids` | Index d’ids (fallback FullSync) |
| `LEGACY_KEY` | `voxurssaf_v2_data` | Migration one-shot V1 |

`eventId` par défaut : `salon-externe-2026`.  
`FS_DB` : `voxurssafv2_fullsync`.

Photos trop lourdes (> ~500 000 caractères data URL) sont omises du snapshot.

### Helpers utiles

| Méthode | Rôle |
|---------|------|
| `emptySalonFields()` | Nouveau brouillon salon |
| `listForHome()` / `isInterviewValidated()` | Uniquement `saved` \| `synced` \| `syncing` \| `error` |
| `updateSalonDraft` / `_wizardLiveDraft` | Saisie wizard (mémoire + snapshot) |
| `completeSalonInterview()` | `status=saved`, stamp enquêteur, clear live draft |
| `discardSalonDraft` | Appelé par **Quitter** — perte de saisie |
| `resumeInterview` | → `/interview-recap` |
| `reopenValidatedForEdit` | Repasse en `draft`, route étape 1 |
| `buildExportJson` / `buildExportCsv` / `parseImport*` / `importInterview` | I/O fichiers |
| `syncInterview` / `syncAllPending` | SQL + photos — **non opérationnel sans BDD** |
| `persistInterview` / `fsPostSafe` | FullSync — best-effort, erreurs loguées |

UI accueil : `syncAll()` existe dans `Page.yaml` mais **aucun bouton** « Synchroniser » n’est câblé. La publication SQL exposée à l’utilisateur est **Publier en BDD** sur `InterviewDataIO`.

---

## 5. Parcours wizard

```
Accueil Nouveau
  → new salon interview, wizardStep=1
  → Step1  (salonName obligatoire → sheetCode = "F-" + date + " - " + salonName)
  → Verbatim (wizardStep 2)
  → Step2 parcours (wizardStep 3)
  → Step3 profil (wizardStep 4)
  → Step4 (wizardStep 5) Valider
       → completeSalonInterview()
       → Accueil
```

**Quitter** : `confirmQuitWizard` → alerte → `discardSalonDraft` → home. Pas de reprise de brouillon.

**Validation Step4** (`commitSubmit`) :

1. `sheetCode` non vide
2. `verbatimText` trim non vide
3. e-mail optionnel mais format `^[^\s@]+@[^\s@]+\.[^\s@]+$` si présent

Puis copie `investigatorName` / `investigatorPhoto` depuis la config tablette.

**Modifier** (récap) : `reopenValidatedForEdit` → status `draft` + live draft → étape 1.

Typologies (`getUserTypologies`) : `auto_entrepreneur`, `ti`, `tiers_declarant`, `rg`, `act`, `paje`, `changement_situation`. Parcours détaillé surtout pour auto-entrepreneur / tiers-déclarant ; les autres affichent un empty state.

Smileys Step2 : `tres_insatisfait` | `moyen` | `satisfait` | `tres_satisfait`. Retouch = suppression de la note. Stocké dans `journeyRatings[]` `{ stepId, family, satisfaction }`.

---

## 6. Modèle de données

### Interview salon (objet store)

| Champ | Type | Notes |
|-------|------|--------|
| `interviewId` | string UUID | Clé |
| `format` | `"salon"` | |
| `status` | `draft` / `saved` / `syncing` / `synced` / `error` | Home = validées sauf `draft` |
| `sheetCode` | string | `F-jj/mm/aaaa hh:mm - {salonName}` |
| `salonName` | string | Saisi étape 1 |
| `verbatimText` | string | |
| `userTypology` | string | défaut `auto_entrepreneur` |
| `journeyRatings` | array | |
| `sector` / `sectorFamily` | string | |
| `age` / `urssafSince` | string | |
| `multiProfile` | boolean \| null | |
| `profileCount` | string | |
| `contactMode` | string | |
| `consentAccepted` | boolean | présent au modèle ; UI Step4 = surtout `recontactOk` |
| `recontactOk` | boolean | |
| `firstName` / `intervieweeEmail` / `intervieweeName` | string | `intervieweeName` dérivé à la validation |
| `photoDataUrl` | string | 1re photo (legacy) |
| `salonPhotos` | string[] | max 4 data URL |
| `investigatorName` / `investigatorPhoto` | string | figés à la validation |
| `wizardStep` | 1–5 | |
| `createdAt` / `updatedAt` / `syncedAt` | ISO | |
| `syncError` / `syncErrorStep` | string \| null | |

Config tablette : `investigatorName` (défaut `"Enquêteur Terrain"`), `investigatorPhoto`, `deviceId`, `eventId`, `speechLocale` (`fr-FR`).

### SQL cible (non branché)

Tables créées par `Interview_EnsureSchema` :

**`interview`** : `interview_id`, `event_id`, `status`, `created_at`, `updated_at`, `synced_at`, `device_id`, `participant_label`, `zone`, `answers_json`, `photos_json`, `sync_error`.

**`interview_photo`** : `photo_id`, `interview_id`, `sort_order`, `mime_type`, `content_base64`.

Payload sync salon : `buildSalonSyncPayload` / `buildSyncPayload` → `answers_json`. Photos envoyées une par une via `Interview_UploadPhoto`.

### FullSync cible (non branché)

Docs `interview:{id}` et `config:{deviceId}`. Design `_design/vu` (vues `interviews_by_device`, `config_by_device`) via `FS_InitDesign` / `ensureDesignDoc`. Replication `fs://voxurssafv2_fullsync.replicate_pull|push`.

Dev : `anonymousReplication: allow`, `secureDatabase` false (voir commentaire connecteur). Prod : inverse + auth.

---

## 7. Séquences et transactions

Préfixe d’appel app : `KitUsager.{Sequence}`.

| Séquence | Rôle | Statut |
|----------|------|--------|
| `Interview_EnsureSchema` | `Interview_InitInterviewTable_Tx` + `Interview_InitPhotoTable_Tx` | Code prêt, BDD absente |
| `Interview_Save` | DELETE puis INSERT `Interview_Save_Tx` | idem |
| `Interview_UploadPhoto` | DELETE + INSERT photo | idem |
| `Interview_Delete` | photos puis interview | idem |
| `FS_ExportInterviewToSql` | même INSERT SQL, params app | legacy / parallèle à `Interview_Save` |
| `FS_InitDesign` | design CouchDB | non requis tant que FS inactif |

Transactions SQL : `_c8oProject/connectors/voxurssaf.yaml`. Commentaire connecteur : Postgres Docker `voxurssaf_v2 @ localhost:5435`, user `kitusager`.

`syncInterview` : `Interview_Save` puis boucle photos ; échec → `status=error` + `syncError`. `syncAllPending` tente `Interview_EnsureSchema` puis push CouchDB **non bloquant**, puis sync de `saved`/`error`/`synced`.

---

## 8. Import / Export

Page : `_c8oProject/mobilePages/InterviewDataIO.yaml`. Liste = `listForHome()` (validées). Export / publish = sélection ; import = fichier indépendant.

### JSON `kitusager-interviews-v1`

```json
{
  "format": "kitusager-interviews-v1",
  "exportedAt": "…",
  "eventId": "salon-externe-2026",
  "includePhotos": false,
  "interviews": [ { } ]
}
```

`stripPhotos` à l’export et à l’import. Toast « Photos ignorées à l'import (MVP) ».

### CSV

- Séparateur `;`, BOM UTF-8 `\uFEFF`
- En-têtes : `CSV_HEADERS` dans le store (`interviewId`, `sheetCode`, … `investigatorName`, `createdAt`, `updatedAt`)
- `journeyRatings` sérialisé dans `journeyRatingsJson`
- MIME download CSV : `text/plain` (Android refuse souvent `text/csv`)
- Photo absente

### Conflits

Clé = `interviewId` uniquement. Modes : `skip` / `replace` / `skip_all` / `replace_all`. Replace : overlay champs, wipe photos et meta sync, `status=saved`, `persistInterview`.

### Publish

`publishSelected` → `syncInterview` par id. UI disabled si hors-ligne ou sélection vide. **Sans Postgres, l’action échoue** — documenté métier comme non branché.

Fichiers : `Blob` + `<a download>` / partage ; import `<input type="file" accept="*/*">`. Pas de plugin Cordova File dédié.

---

## 9. Plugins Cordova et permissions

Fichier : `DisplayObjects/platforms/Android/config.xml` (versionné ; le gitignore iOS `config.xml` reste actif).

| Plugin | Usage |
|--------|--------|
| `cordova-plugin-speechrecognition` | Dictée Android (pas de fallback Web Speech sous Cordova) |
| `cordova-plugin-camera` | Photos salon + photo profil |
| device, file, file-transfer, whitelist, network-information, statusbar, ionic-webview | Template / FlashUpdate |

Permission : `RECORD_AUDIO` + query `android.speech.RecognitionService`.  
`preference permissions=none` est toujours là (héritage PhoneGap) : la permission micro est ajoutée via `config-file` Manifest.

STT : locale `fr-FR`. Erreurs métier dans `InterviewStepVerbatim.yaml` (permission, no-speech). Pack langue OEM hors scope code.

Caméra : `usesCleartextTraffic` + `largeHeap` (photos data URL).

---

## 10. Build APK

1. Ouvrir le projet **KitUsager** dans Convertigo Studio.
2. Synchroniser l’application mobile NGX si le Studio le demande.
3. Build plateforme **Android** (localbuild / `_private` gitignoré).
4. Livrable copié / attendu : `KitUsager/build-apk/KitUsager_Android.apk`.

`content src="index.html"` : APK standalone, FlashUpdate remote check sauté.

iOS est déclaré dans `c8oProject.yaml` mais le livrable courant est Android.

Responsive : `< 640px` pleine largeur ; `≥ 640px` colonne max ~720px. Détail historique : `RESPONSIVE_QA.md` (certains tests sync/wizard 4 étapes sont **obsolètes**).

---

## 11. Points d’attention

- **`README_MVP.md`** décrit VoxUrssafV2 / CouchDB / HSQLDB / sync accueil : architecture héritée, **pas** l’état terrain actuel (local + fichiers).
- **`project.md`** : dump Studio, utile pour lister transactions, pas un guide.
- Commentaires YAML « étape n/4 » vs UI **n/5**.
- `consentAccepted` dans le modèle / CSV ; l’étape 5 expose surtout `recontactOk`.
- `wizardStep` d’anciennes fiches (map d’avant le 13/08/2026) peut atterrir sur une étape voisine si un jour on reprend des brouillons persistés — aujourd’hui les brouillons sont jetés au Quitter.
- JDBC et mots de passe : uniquement dans le connecteur YAML, jamais dans les docs métier.
- Ne pas documenter un Postgres live. Quand il sera branché : republier le projet, `Interview_EnsureSchema` une fois, puis activer Publish / `syncAllPending`.
- Logs store encore préfixés `[VoxUrssafV2]`.
- Tests : pas de suite auto ; checklist manuelle (wizard 1→5, dictée, photo, quit = perte, export/import, conflit).
