# Guide d'Installation du Composant de Test 1

## 1. Prérequis

Avant d'installer et d'exécuter ce composant, assurez-vous que votre environnement répond aux conditions suivantes :

### 1.1. Système d'exploitation

- Une machine locale sous **Linux**, **macOS** ou **Windows avec WSL**.
- Une ou plusieurs **VMs Debian ou Ubuntu** accessibles via SSH.

### 1.2. Logiciels nécessaires

- **Python 3.8+** installé sur votre machine locale
- **Pip** pour gérer les dépendances Python
- **OpenSSH** pour l’accès SSH aux machines distantes

### 1.3. Accès SSH aux VMs

- Assurez-vous d'avoir des **clés SSH valides** et les permissions pour vous connecter aux machines distantes.
- Les adresses IP et chemins des clés SSH doivent être correctement renseignés dans `config/VMs_list.json`.

---

## 2. Installation

### 2.1. Cloner le dépôt du projet

Si le projet est hébergé sur un gestionnaire de versions comme Git, utilisez :

```bash
git clone https://github.com/nom-utilisateur/Test_1.git
cd Test_1
```

### 2.2. Installer les dépendances

Installez uniquement la bibliothèque nécessaire pour la génération de rapports HTML :

```bash
pip install pytest-html
```

---

## 3. Configuration

### 3.1. Vérifier la configuration des VMs

Modifiez le fichier `config/VMs_list.json` pour ajouter les machines à tester :

```json
[
  { "host": "ip_pub", "user": "user", "key_path": "/Users/user/.ssh/sshvm1" },
  { "host": "ip_pub", "user": "user", "key_path": "/Users/user/.ssh/sshvm2" }
]
```

### 3.2. Vérifier l’accès SSH

Assurez-vous que vous pouvez vous connecter à chaque VM en exécutant :

```bash
ssh -i /Users/.ssh/sshvm1 azureuser@52.169.122.88
```

Si la connexion échoue, vérifiez :

- Que l’IP de la VM est correcte.
- Que votre clé SSH est bien ajoutée (`ssh-add /Users/.ssh/sshvm1`).

---

## 4. Exécution des tests

### 4.1. Lancer les tests unitaires

Exécutez tous les tests et générez un rapport :

```bash
pytest src/ --html=reports/test_results.html --self-contained-html
```

### 4.2. Vérifier les résultats

Les résultats des tests sont disponibles sous `reports/test_results.html`.
Ouvrez le fichier dans un navigateur :

```bash
xdg-open reports/test_results.html  # Linux
open reports/test_results.html  # macOS
```

---

## 5. Désinstallation

Si vous souhaitez supprimer le projet et ses dépendances, exécutez :

```bash
rm -rf Test_1
```

---

## 6. Dépannage

Si vous rencontrez des erreurs :

- **Problème de connexion SSH ?** Vérifiez les permissions et la présence des clés SSH.
- **Erreur "ModuleNotFoundError" ?** Vérifiez que `pip install pytest-html` a bien été exécuté.
- **Tests échoués ?** Consultez le rapport de test pour plus de détails.
