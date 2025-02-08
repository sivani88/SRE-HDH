# Guide d'Intégration du Composant de Test 1

## 1. Introduction

Ce guide explique comment intégrer le composant **Test 1** dans un processus de validation automatisé, notamment dans un pipeline **CI/CD** basé sur **Azure DevOps**.

---

## 2. Intégration avec un Pipeline CI/CD

### 2.1. Ajout au pipeline **Azure DevOps**

Ajoutez l’étape suivante dans votre fichier YAML de pipeline Azure DevOps (`azure-pipelines.yml`) pour exécuter les tests :

```yaml
stages:
  - stage: Tests
    jobs:
      - job: Run_Tests
        pool:
          vmImage: "ubuntu-latest"
        steps:
          - checkout: self
          - script: |
              pip install pytest pytest-html paramiko
              pytest src/ --html=reports/test_results.html --self-contained-html
            displayName: "Exécuter les tests"
          - publish: reports/test_results.html
            artifact: testReports
```

Cette configuration permet :
✅ L’installation des dépendances nécessaires (`pytest`, `pytest-html`, `paramiko`).
✅ L’exécution des tests de connexion SSH, de logs et de paquets.
✅ La génération et la publication d’un rapport HTML dans Azure DevOps.

---

---

## 3. Vérification des résultats

### 3.1. Récupération du rapport dans Azure DevOps

Après l’exécution du pipeline, téléchargez le rapport dans l’onglet **Artifacts** d’Azure DevOps.

---

## 6. Dépannage

### 6.1. Erreur de connexion SSH dans le pipeline

- Vérifiez que les clés SSH sont correctement ajoutées.
- Assurez-vous que l’adresse IP des machines distantes est correcte.

### 6.2. Tests échoués

- Consultez les logs détaillés dans le rapport HTML généré.

### 6.3. Problèmes d’installation des dépendances

- Ajoutez l’option `--break-system-packages` en cas de conflits :

```bash
pip install pytest pytest-html paramiko --break-system-packages
```

---

## 7. Conclusion

En intégrant ce composant dans votre pipeline **CI/CD**, vous automatisez la vérification de l’infrastructure et assurez une validation continue des configurations système et des connexions SSH.
