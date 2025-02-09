# Architecture et Design des Tests d'Infrastructure

## 1. Introduction

L'objectif de cette section est de décrire l'architecture des tests d'infrastructure mis en place pour garantir la disponibilité, la sécurité et la conformité des machines virtuelles et des logiciels du projet HDH.

## 2. Structure des Tests

L'architecture des tests repose sur plusieurs niveaux de validation :

- **Tests de connectivité SSH** : Vérifie l'accessibilité des machines distantes et la validité des clés d'authentification.
- **Tests de journaux système** : S'assure que les fichiers critiques, comme `/var/log/auth.log`, sont bien présents et accessibles.
- **Tests de processus critiques** : Valide l'exécution régulière des tâches planifiées via `cron`.
- **Tests de conformité logicielle** : Vérifie la présence et l'intégrité des packages essentiels sur chaque VM.

## 3. Technologies et Outils

Le projet s'appuie sur une combinaison de technologies adaptées aux tests d'infrastructure :

- **Python + pytest** : Framework de test modulaire et évolutif.
- **Testinfra** : Extension de pytest pour les tests d'infrastructure.
- **Paramiko** : Gestion des connexions SSH et exécution des commandes à distance.
- **Pytest-html** : Génération de rapports détaillés pour le suivi des tests.

## 4. Organisation des Tests

Les tests sont organisés en modules distincts pour une meilleure maintenabilité :

- **`test_ssh.py`** : Vérifie la connectivité et l'intégrité de l'accès SSH.
- **`test_cron.py`** : Analyse la présence des processus critiques dans les logs.
- **`test_packages.py`** : Vérifie la présence et la taille des packages système attendus.

## 5. Exécution et Reporting

Les tests sont exécutés via `pytest` et génèrent des rapports HTML détaillés. Ces rapports sont archivés dans le répertoire `reports/` pour une analyse ultérieure.

Commande d'exécution :

```bash
pytest -s --html=reports/test_results.html --self-contained-html
```

## 6. Évolutivité et Intégration Future

À terme, ces tests pourront être intégrés dans un pipeline CI/CD sur Azure DevOps pour une validation continue de l'infrastructure. Une extension pourrait également inclure des tests de charge et de sécurité avancés.

---

Ce document sert de référence pour la conception et l'évolution de l'architecture de tests du projet HDH.
