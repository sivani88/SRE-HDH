import paramiko
import pytest
import json
import os

# Charger les VM
VM_FILE = "config/VMs_list.json"

if not os.path.exists(VM_FILE):
    pytest.exit(f"Fichier {VM_FILE} introuvable. Vérifiez son emplacement.")

with open(VM_FILE, "r") as file:
    VMS = json.load(file)

@pytest.fixture(scope="module", params=VMS)
def ssh_connection(request):
    """Setup: Vérification de la connectivité SSH sur Debian."""
    vm = request.param
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(vm["host"], username=vm["user"], key_filename=vm["key_path"])
        print(f"Connexion SSH réussie à {vm['host']}")
    except Exception as e:
        pytest.fail(f"Erreur de connexion SSH à {vm['host']}: {e}")

    yield ssh, vm["host"]  # Fournit la connexion et l'IP pour les tests

    ssh.close()
    print(f"Teardown connexion SSH fermée pour {vm['host']}.")

def test_auth_log_exists(ssh_connection):
    """Test : Vérifie si /var/log/auth.log existe sur la VM Debian."""
    ssh, host = ssh_connection
    stdin, stdout, stderr = ssh.exec_command("ls /var/log/auth.log")
    output = stdout.read().decode().strip()

    if output:
        print(f"Fichier trouvé sur {host}: /var/log/auth.log")
    else:
        print(f"Le fichier /var/log/auth.log est manquant sur {host}")

    assert output, f"Le fichier /var/log/auth.log n'existe pas sur la VM {host}."


