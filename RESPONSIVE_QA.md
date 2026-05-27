# VoxUrssafV2 — Validation responsive

Checklist manuelle après publication mobile (DevTools responsive ou appareils réels).

## Paliers CSS

| Palier | Largeur | Comportement attendu |
|--------|---------|----------------------|
| Mobile | &lt; 640px | Pleine largeur, 1 colonne, capture/nav centrés en bas |
| Tablette + PC | ≥ 640px | **Colonne unique centrée** (max 720px) sur tous les écrans ; capture en bas au centre ; KPI 2×2 |

Variables : `--vu-shell-max`, `--vu-scroll-pad`, `--vu-scroll-pad-active`, `--vu-safe-bottom` dans `mobileNgxApp.yaml`.

## Matrice de test

| Viewport | Pages à vérifier |
|----------|------------------|
| 375×812 (iPhone) | Accueil, Interview active (feed + capture), Questions |
| 768×1024 (iPad portrait) | Accueil colonne centrée, KPI 2×2, pas de chevauchement bas |
| 1180×820 (tablette paysage) | Accueil **une colonne centrée** (pas grille 2 cols) |
| 1024×768 / 1180×820 / desktop | Même colonne centrée que tablette ; pas de grille 2 cols ni sidebar |
| 412×915 (Android) | Safe area, select questions (popover) |

## Critères OK

- [ ] Aucun contenu masqué sous panneau capture / nav basse
- [ ] Pas de scroll horizontal
- [ ] Touch targets ≥ 44px (onglets capture, pilule nav)
- [ ] Textes badges/cartes lisibles sans zoom
- [ ] Interview active : `vu-active-shell` actif — pas de `padding-bottom` inline résiduel
- [ ] Select question : popover lisible (contraste option sélectionnée)

## Fichiers concernés

- `_c8oProject/mobileNgxApp.yaml` — styles VU globaux
- `_c8oProject/mobilePages/InterviewActive.yaml` — shell actif + feed
- `_c8oProject/mobileSharedComponents/BottomNavPill.yaml` — nav basse
