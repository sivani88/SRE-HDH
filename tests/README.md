# Test 1 - Suite de Tests Automatisés pour VMs Debian/Ubuntu

## 📌 Description

Le projet **Test 1** est une suite de tests automatisés permettant de vérifier la connectivité SSH, la présence des logs système, et la conformité des paquets installés sur des machines **Debian/Ubuntu**.

✅ **Fonctionnalités principales :**

- Vérification de la connexion SSH aux VMs cibles.
- Vérification de l’existence du fichier `/var/log/auth.log`.
- Vérification de la présence d’exécutions du processus `CRON`.
- Contrôle de l’installation et de la taille des paquets essentiels.
- Génération d’un **rapport HTML** détaillant les résultats des tests.

---

## 📂 Structure du projet

```
Test_1/
│── docs/                 # Documentation du projet
│── src/                  # Code source des tests
│   ├── test_ssh.py       # Test connexion SSH et auth.log
│   ├── test_cron.py      # Vérification des tâches CRON
│   ├── test_packages.py  # Vérification des paquets installés
│── config/               # Fichiers de configuration
│── reports/              # Rapports de tests générés
│── requirements.txt      # Dépendances nécessaires
│── README.md             # Présentation du projet
│── CHANGELOG.md          # Historique des versions
│── version.txt           # Version actuelle du projet
```

---

## 🛠 Installation

### 1️⃣ Cloner le projet

```bash
git clone https://github.com/nom-utilisateur/Test_1.git
cd Test_1
```

### 2️⃣ Installer les dépendances

```bash
pip install -r requirements.txt
```

---

## 🚀 Utilisation

### Exécuter tous les tests et générer un rapport HTML

```bash
pytest src/ --html=reports/test_results.html --self-contained-html
```

### Exécuter un test spécifique

🔹 **Connexion SSH & logs auth** :

```bash
pytest src/test_ssh.py -v
```

🔹 **Présence du processus CRON** :

```bash
pytest src/test_cron.py -v
```

🔹 **Vérification des paquets installés** :

```bash
pytest src/test_packages.py -v
```

### Consulter le rapport HTML

Ouvrir le fichier généré dans un navigateur :

```bash
xdg-open reports/test_results.html  # Linux
open reports/test_results.html  # macOS
```

---

## 🔄 Intégration CI/CD (À venir)

- **Azure DevOps, GitHub Actions, Jenkins**
- Exécution automatique des tests après chaque modification.
- Validation continue de l’infrastructure.

---

## 📌 Contact

En cas de problème, contactez **support@example.com**.
