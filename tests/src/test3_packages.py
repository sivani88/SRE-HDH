import paramiko
import pytest
import json
import os


VM_FILE = "config/VMs_list.json"
PKG_FILE = "config/packages_list.json"


if not os.path.exists(VM_FILE):
    pytest.exit(f"Fichier {VM_FILE} introuvable. Vérifiez son emplacement.")
if not os.path.exists(PKG_FILE):
    pytest.exit(f"Fichier {PKG_FILE} introuvable. Vérifiez son emplacement.")


with open(VM_FILE, "r") as file:
    VMS = json.load(file)


with open(PKG_FILE, "r") as file:
    EXPECTED_SIZES = json.load(file)

ssh_connections = {}

@pytest.fixture(scope="module", autouse=True)
def setup_teardown():
    """Établit les connexions SSH et les ferme après les tests."""
    global ssh_connections
    for vm in VMS:
        try:
            print(f"Connexion SSH en cours avec {vm['host']} ...")
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(vm["host"], username=vm["user"], key_filename=vm["key_path"])
            ssh_connections[vm["host"]] = ssh
            print(f"Connexion SSH établie avec {vm['host']}")
        except Exception as e:
            pytest.fail(f"Échec de connexion à {vm['host']}: {e}")

    yield

    for vm in VMS:
        if vm["host"] in ssh_connections:
            ssh_connections[vm["host"]].close()
            print(f"Connexion SSH fermée pour {vm['host']}")

@pytest.mark.parametrize("package,expected_size", EXPECTED_SIZES.items())
@pytest.mark.parametrize("vm", VMS)
def test_install_and_verify_package(vm, package, expected_size):
    """Installe et vérifie la taille des paquets sur chaque VM."""
    ssh = ssh_connections.get(vm["host"])
    if not ssh:
        pytest.fail(f"Aucune connexion SSH active pour {vm['host']}")

    print(f"Vérification du package {package} sur {vm['host']} ...")

    # Vérifier si le package est installé
    check_cmd = f"dpkg -l | grep -i {package}"
    stdin, stdout, stderr = ssh.exec_command(check_cmd)
    output = stdout.read().decode().strip()

    if not output:
        print(f"{package} non trouvé sur {vm['host']}. Installation en cours...")
        install_cmd = f"sudo apt update -y && sudo apt install -y {package}"
        stdin, stdout, stderr = ssh.exec_command(install_cmd)
        stdout.channel.recv_exit_status()

    # Vérifier la taille du package
    size_cmd = f"dpkg-query --showformat='${{Installed-Size}}' --show {package}"
    stdin, stdout, stderr = ssh.exec_command(size_cmd)
    package_size = stdout.read().decode().strip()

    assert package_size, f"Le package {package} n'a pas été trouvé après installation sur {vm['host']}"
    
    package_size = int(package_size)
    
    # Vérification avec une tolérance de ±50%
    assert expected_size * 0.5 <= package_size <= expected_size * 1.5, (
        f"Taille incorrecte pour {package} sur {vm['host']} "
        f"(Attendu: ~{expected_size} Ko, Trouvé: {package_size} Ko)"
    )

    print(f"Le package {package} est installé et valide sur {vm['host']} (Taille : {package_size} Ko)")
