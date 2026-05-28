# VoxUrssafV2 — Validation responsive

Checklist manuelle après publication mobile (DevTools responsive ou appareils réels).

## Paliers CSS

| Palier | Largeur | Comportement attendu |
|--------|---------|----------------------|
| Mobile | &lt; 640px | Pleine largeur, 1 colonne, nav basse centrée (hors wizard) |
| Tablette + PC | ≥ 640px | **Colonne unique centrée** (max 720px) sur tous les écrans |

Variables : `--vu-shell-max`, `--vu-content-col-max`, `--vu-safe-bottom` dans `mobileNgxApp.yaml`.

## Matrice de test

| Viewport | Pages à vérifier |
|----------|------------------|
| 375×812 (iPhone) | Accueil, wizard étapes 1–4, dictée étape 2 |
| 768×1024 (iPad portrait) | Accueil colonne centrée, formulaires wizard |
| 1180×820 / desktop | Même colonne centrée ; pas de grille 2 cols |
| 412×915 (Android) | Safe area, caméra étape 4 (device) |

## Parcours wizard salon

| # | Test | Attendu |
|---|------|---------|
| 1 | Accueil → **Nouveau verbatim salon** | Étape 1, brouillon `format: salon` |
| 2 | Étapes 1 → 4 (desktop + 375px) | Barre progression 25/50/75/100 %, boutons Retour / Suivant |
| 3 | Étape 2 — dictée | Placeholder dictée ; micro ; texte dans verbatim |
| 4 | Brouillon | Quitter à l’étape 2 → accueil → reprise étape 2 |
| 5 | Sync accueil | CouchDB + SQL `answers_json` avec champs salon |
| 6 | Photo étape 4 | Aperçu + `Interview_UploadPhoto` à la sync |

## Critères OK

- [ ] Aucun contenu masqué sous nav basse (accueil / liste / profil)
- [ ] Pas de scroll horizontal sur les 4 étapes wizard
- [ ] Touch targets ≥ 44px (toggles, satisfaction, micro)
- [ ] Wizard : pas de `BottomNavPill` sur les étapes 1–4
- [ ] Validation étape 4 : consentement obligatoire, messages d’erreur visibles

## Fichiers concernés

- `_c8oProject/mobileNgxApp.yaml` — store salon + styles `.vu-wizard-*`
- `_c8oProject/mobilePages/InterviewStep1.yaml` … `InterviewStep4.yaml`
- `_c8oProject/mobilePages/Page.yaml` — accueil + reprise brouillon
- `_c8oProject/mobileSharedComponents/BottomNavPill.yaml` — FAB → étape 1
