import paramiko
import pytest
import os
import json


LOCAL_LOG_DIR = "./logs"

VM_FILE = "config/VMs_list.json"

if not os.path.exists(VM_FILE):
    pytest.exit(f"Fichier {VM_FILE} introuvable. Vérifiez son emplacement.")

with open(VM_FILE, "r") as file:
    VMS = json.load(file)

@pytest.fixture(scope="module", params=VMS)
def ssh_connection(request):
    """Setup : Vérification de la connectivité SSH avant d'exécuter les tests."""
    vm = request.param
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(vm["host"], username=vm["user"], key_filename=vm["key_path"])
        print(f"Connexion SSH réussie à {vm['host']}")
    except Exception as e:
        pytest.fail(f"Erreur de connexion SSH à {vm['host']}: {e}")

    
    os.makedirs(LOCAL_LOG_DIR, exist_ok=True)

    yield ssh, vm["host"] 

    # Teardown : Fermeture propre de la connexion après les tests
    ssh.close()
    print(f"Connexion SSH fermée pour {vm['host']}.")

def test_cron_log_exists(ssh_connection):
    """Test : Vérifie qu'au moins une occurrence du processus CRON est présente dans /var/log/auth.log."""
    ssh, host = ssh_connection
    command = "grep 'CRON' /var/log/auth.log | wc -l"
    stdin, stdout, stderr = ssh.exec_command(command)
    cron_count = int(stdout.read().decode().strip())

    assert cron_count > 0, f"Aucune occurrence du processus CRON trouvée dans /var/log/auth.log sur {host}."
    print(f"CRON s'est exécuté {cron_count} fois sur {host}.")

    # Téléchargement du fichier log
    local_file = os.path.join(LOCAL_LOG_DIR, f"{host}_auth.log")
    sftp = ssh.open_sftp()
    sftp.get("/var/log/auth.log", local_file)
    sftp.close()

    print(f"Fichier téléchargé : {local_file}")

@pytest.fixture(scope="module", autouse=True)
def cleanup_logs():
    """Teardown : Supprime les fichiers récupérés après les tests."""
    yield  # Attend la fin des tests
    for file in os.listdir(LOCAL_LOG_DIR):
        file_path = os.path.join(LOCAL_LOG_DIR, file)
        os.remove(file_path)
        print(f"Fichier supprimé : {file_path}")
    os.rmdir(LOCAL_LOG_DIR)
    print("Dossier des logs supprimé.")
