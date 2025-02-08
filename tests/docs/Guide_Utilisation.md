# Guide d'Utilisation du Composant de Test 1

## 1. Introduction

Ce guide explique comment utiliser le composant **Test 1** pour vérifier la connectivité SSH, la présence des logs système et la validation des paquets installés sur des machines Debian ou Ubuntu.

---

## 2. Exécution des Tests

### 2.1. Vérification de la connectivité SSH

Avant d'exécuter les tests, assurez-vous que votre connexion SSH est fonctionnelle en testant la connexion manuelle :

```bash
ssh -i /Users/.ssh/sshvm1 azureuser@ip_a_vous
```

Si la connexion échoue, vérifiez les **permissions** et la **présence des clés SSH**.

### 2.2. Lancer l’ensemble des tests

Exécutez les tests avec la commande suivante :

```bash
pytest src/ --html=reports/test_results.html --self-contained-html
```

Cela va :
✅ Tester la connexion SSH et la présence des logs (`/var/log/auth.log`)
✅ Vérifier la présence d'exécutions `cron`
✅ Contrôler l’intégrité des paquets installés
✅ Générer un rapport HTML détaillé des résultats

---

## 3. Comprendre les résultats des tests

### 3.1. Affichage en console

Les résultats des tests sont affichés directement dans le terminal après exécution.
Exemple de sortie console :

```
======================== test session starts ========================
...
✔ Connexion SSH réussie à ip
✔ Fichier /var/log/auth.log trouvé sur ip
✔ CRON détecté sur ip
✔ Package curl présent et conforme sur ip
...
========================= test session ends ========================
```

### 3.2. Rapport HTML détaillé

Un rapport complet est généré dans `reports/test_results.html`.

Pour ouvrir le rapport dans un navigateur :

```bash
xdg-open reports/test_results.html  # Linux
open reports/test_results.html  # macOS
```

Le rapport fournit :

- ✅ Statut des tests
- 📊 Détails des erreurs éventuelles
- 📌 Logs d’exécution des commandes

---

## 4. Exécution de tests spécifiques

### 4.1. Exécuter uniquement la vérification SSH

```bash
pytest src/test_ssh.py -v
```

### 4.2. Exécuter uniquement la vérification des tâches CRON

```bash
pytest src/test_cron.py -v
```

### 4.3. Exécuter uniquement la vérification des paquets installés

```bash
pytest src/test_packages.py -v
```

---

## 5. Nettoyage et suppression des fichiers temporaires

Après exécution des tests, les fichiers téléchargés sont supprimés automatiquement.
Si nécessaire, vous pouvez forcer un nettoyage manuel :

```bash
rm -rf logs/* reports/*
```

---

## 6. En cas de problème

Si vous rencontrez des erreurs :

- **Problème de connexion SSH ?** Vérifiez que votre clé SSH est bien chargée avec `ssh-add`.
- **Tests échoués ?** Consultez le fichier `reports/test_results.html`.
- **Paquets non conformes ?** Assurez-vous qu’ils sont installés sur la VM cible.

En cas de besoin, contactez l’équipe support à `support@example.com`.
