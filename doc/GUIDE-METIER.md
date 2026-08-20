# KitUsager — Guide métier

**Version app :** 1.4.0  
**Date :** 20 août 2026  
**Public :** enquêteurs terrain, chefs de projet

> Documentation technique (pages, séquences, build) : [DOCUMENTATION-TECHNIQUE.md](DOCUMENTATION-TECHNIQUE.md)

---

## 1. Présentation

KitUsager est une application Android qui sert à **recueillir des témoignages usagers** sur un salon ou un événement Urssaf.

Sur la tablette, vous :

1. Nommez la fiche (nom du salon)
2. Saisissez ou dictez le **verbatim**
3. Notez le **parcours** avec des smileys
4. Renseignez le **profil** usager (facultatif)
5. Recueillez le **consentement** de recontact, éventuellement prénom, e-mail et photos, puis **validez**

Les fiches restent **sur l’appareil**. Vous pouvez les **exporter** (JSON ou CSV) pour les transmettre à un collègue ou au bureau, et **importer** un fichier reçu. Aucune base de données n’est connectée pour l’instant : la publication serveur arrivera plus tard.

**Support :** téléphone ou tablette Android (APK). Orientation portrait et paysage.

---

## 2. Premier lancement

1. Installez l’APK fourni (`KitUsager_Android.apk`).
2. Ouvrez **KitUsager**.
3. Autorisez le **micro** (dictée vocale) et la **caméra** (photos) quand Android le demande.  
   Si la demande n’apparaît pas : **Paramètres → Applications → KitUsager → Autorisations**.
4. Touchez l’**avatar** ou le nom en haut de l’accueil pour ouvrir le **profil enquêteur**.
5. Saisissez votre **nom** et, si vous le souhaitez, une **photo** (caméra ou galerie). Touchez **Enregistrer**.

Le nom et la photo s’affichent sur la tablette. Ils sont **copiés sur chaque fiche** au moment de la validation (la fiche garde l’enquêteur de ce jour-là, même si vous changez le profil ensuite).

Sans profil enregistré, l’app affiche **Enquêteur Terrain**.

---

## 3. Écran d’accueil

En haut : votre photo / nom et **Bonjour**.

| Élément | Rôle |
|---------|------|
| **Nouveau** / **Nouveau verbatim salon** | Démarre une nouvelle fiche (étape 1) |
| **Interviews récentes** | Dernières fiches **validées** |
| **Voir tout** | Liste complète des fiches validées, avec recherche |
| **Vue d’ensemble** | Compteurs (interviews, validées) |
| **Import / Export** | Transfert de fiches par fichier |

Les fiches **non validées** n’apparaissent pas ici. Si vous quittez le formulaire en cours, la saisie est **perdue** (voir §5).

Toucher une carte ouvre le **récapitulatif** (lecture), pas le formulaire.

---

## 4. Parcours interview (5 étapes)

Barre de progression en haut. **Retour** / **Étape suivante**. **Quitter** (confirmation) abandonne la fiche.

### Étape 1/5 — Nommer la fiche

**Objectif :** identifier l’événement. Aucune donnée personnelle à cette étape.

| Champ | Obligatoire | Règle |
|-------|-------------|--------|
| Nom du salon | Oui | Texte libre. L’app génère un code du type `F-20/08/2026 10:41 - Nom du salon`. |

Sans nom de salon, vous ne pouvez pas passer à la suite.

### Étape 2/5 — Votre verbatim

**Objectif :** recueillir le témoignage, à la dictée ou au clavier.

| Champ | Obligatoire | Règle |
|-------|-------------|--------|
| Verbatim | Oui à la validation finale | Peut rester vide pendant le wizard ; **obligatoire** pour valider à l’étape 5. |

**Dictée vocale**

1. Touchez le micro / démarrez la dictée.
2. Parlez après le signal (sur Android, une fenêtre « Parlez maintenant… » peut s’afficher).
3. Le texte s’ajoute au champ. Vous pouvez le corriger au clavier.

La dictée utilise les services de reconnaissance vocale de la tablette, en français (`fr-FR`). Sans pack langue français, la dictée peut échouer : saisissez alors le texte à la main.

### Étape 3/5 — Parcours et ressenti

**Objectif :** noter les étapes du parcours Urssaf qui concernent la personne.

1. Choisissez la **catégorie d’usager** (Auto-entrepreneur, TI, Tiers-déclarant, RG, ACT, PAJE, Changement de situation).
2. Pour chaque sous-étape affichée, touchez un smiley :

| Smiley | Signification |
|--------|----------------|
| 😠 | Très insatisfait |
| 😕 | Moyen |
| 🙂 | Satisfait |
| 😄 | Très satisfait |

Retouchez le même smiley pour **retirer** la note (étape non concernée).

Tout est **facultatif**. Certaines catégories n’ont pas encore de parcours : un message l’indique, vous pouvez passer à l’étape suivante.

### Étape 4/5 — Votre profil

**Objectif :** informations optionnelles sur l’usager. Vous pouvez **passer cette étape**.

| Champ | Exemples |
|-------|----------|
| Famille de métier / métier | Listes selon la famille ; « Autre » = saisie libre |
| Tranche d’âge | Moins de 25 ans, 25–34, 35–44, 45–54, 55 ans et plus, Autre |
| Ancienneté Urssaf | Moins de 2 ans, De 2 à 5 ans, Plus de 5 ans, Autre |
| Plusieurs profils Urssaf | Oui / Non ; si Oui, nombre de profils |
| Mode de contact | Contact direct Urssaf / Via un intermédiaire |

### Étape 5/5 — Consentement et envoi

**Objectif :** recontact, coordonnées, photos, validation.

| Champ | Obligatoire | Règle |
|-------|-------------|--------|
| J’accepte d’être recontacté | Non | Case à cocher |
| Prénom | Non | |
| E-mail | Non | Si renseigné, doit être une adresse valide |
| Photos | Non | Jusqu’à **4** photos (caméra) |

**Valider l’envoi** contrôle :

- un **nom de salon** (étape 1)
- un **verbatim** non vide (étape 2)

Si c’est bon, la fiche est **enregistrée sur la tablette** et vous revenez à l’accueil. Elle apparaît dans les interviews récentes.

---

## 5. Quitter, modifier, supprimer

### Quitter en cours de saisie

**Quitter** affiche : *« Si vous quittez maintenant, votre saisie sera perdue. »*

- **Annuler** : vous restez sur le formulaire.
- **Quitter** : la fiche en cours est **jetée**. Rien n’est conservé.

Il n’y a pas de brouillon repris depuis l’accueil.

### Consulter une fiche validée

Depuis l’accueil ou **Toutes les interviews**, touchez une carte → **récapitulatif** (parcours, smileys, verbatim, profil, consentement, photos, nom de l’enquêteur).

### Modifier

Sur le récap, **Modifier** rouvre le wizard à l’étape 1 avec les données déjà saisies. Après une nouvelle validation, la fiche est à jour **en local**.

### Supprimer

**Supprimer** (avec confirmation) retire définitivement la fiche de la tablette. Action irréversible.

---

## 6. Toutes les interviews

**Voir tout** depuis l’accueil.

- Liste des fiches **validées** uniquement
- Recherche sur le code fiche, le prénom / libellé, le début du verbatim
- Toucher une ligne → récapitulatif

---

## 7. Import / Export

Depuis l’accueil : **Import / Export**. Seules les fiches **validées** sont listées.

### Exporter

1. Cochez les fiches (toutes pré-cochées ; **Tout cocher** / **Tout décocher**).
2. **JSON** : fichier complet (recommandé pour réimporter dans KitUsager).
3. **CSV** : tableur (point-virgule, Excel). Moins fidèle : pas de photos, parcours en une colonne JSON.

Le fichier part dans **Téléchargements**, nom du type `interviews-20260820-1041.json`.

**Les photos ne sont pas exportées** (ni JSON ni CSV).

### Importer

1. **Choisir JSON / CSV** (indépendant des cases cochées).
2. Fichier `.json` ou `.csv` (éventuellement `.txt`).
3. Si une fiche existe déjà (même identifiant) : **Ignorer**, **Remplacer**, **Ignorer tous**, **Remplacer tous**.
4. Un message peut indiquer que les **photos sont ignorées** à l’import.

Après import, les fiches apparaissent sur l’accueil.

### Publier en BDD

Le bouton **Publier en BDD** est visible mais **sans serveur connecté pour l’instant**. N’utilisez pas cette action en production terrain : l’échange se fait par **export / import de fichiers**.

---

## 8. Données : ce qui reste sur la tablette

| Donnée | Où | Remarque |
|--------|-----|----------|
| Fiches validées | Appareil | Disparaissent si désinstallation / vidage des données de l’app |
| Profil enquêteur | Appareil | Idem |
| Photos de fiche | Appareil | Non incluses dans l’export fichier |
| Copie de sauvegarde | Fichier JSON/CSV | À faire régulièrement si les entretiens doivent être conservés |

Pensez à **exporter** en fin de journée salon.

---

## 9. FAQ terrain

**Le micro ne marche pas.**  
Autorisez le micro dans les réglages Android. Parlez après le démarrage de la dictée. Si « aucun son détecté », rapprochez-vous du micro. Si le pack langue français est absent sur la tablette, saisissez le verbatim au clavier.

**La photo ne se prend pas.**  
Autorisez la caméra. Jusqu’à 4 photos par fiche.

**J’ai quitté par erreur.**  
La saisie en cours est perdue. Recommencez **Nouveau verbatim salon**. Les fiches déjà validées ne sont pas touchées.

**La fiche n’apparaît pas sur l’accueil.**  
Seules les fiches **validées** (étape 5, bouton Valider l’envoi) s’affichent.

**Import : « Choisissez un fichier .json ou .csv ».**  
Le fichier n’a pas la bonne extension. Exportez depuis une autre tablette KitUsager, ou utilisez un CSV aux colonnes attendues.

**Import : conflit.**  
La fiche existe déjà. **Ignorer** conserve la version locale ; **Remplacer** écrase avec le fichier.

**L’export dit « Export impossible ».**  
Vérifiez qu’au moins une fiche est cochée et que le dossier Téléchargements est accessible.

**La dictée ne reconnaît pas le français.**  
Limitation de la tablette (services Google / pack langue), pas un paramètre KitUsager. Dictée manuelle.

**Je veux envoyer les fiches au SI / à une base.**  
Pas encore. Utilisez l’export JSON ou CSV.
