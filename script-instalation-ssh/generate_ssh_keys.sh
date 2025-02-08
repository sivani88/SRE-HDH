#!/bin/bash


KEY_DIR="$HOME/.ssh"
OUTPUT_FILE="$KEY_DIR/all_public_keys.txt"


mkdir -p "$KEY_DIR"


KEY1_NAME="sshvm1"
KEY2_NAME="sshvm2"


if [ ! -f "$KEY_DIR/$KEY1_NAME" ]; then
    ssh-keygen -t rsa -b 4096 -f "$KEY_DIR/$KEY1_NAME" -N "" -q
    echo "Clé SSH générée : $KEY_DIR/$KEY1_NAME"
else
    echo "Clé SSH déjà existante : $KEY_DIR/$KEY1_NAME"
fi

if [ ! -f "$KEY_DIR/$KEY2_NAME" ]; then
    ssh-keygen -t rsa -b 4096 -f "$KEY_DIR/$KEY2_NAME" -N "" -q
    echo "Clé SSH générée : $KEY_DIR/$KEY2_NAME"
else
    echo "Clé SSH déjà existante : $KEY_DIR/$KEY2_NAME"
fi

eval "$(ssh-agent -s)"


ssh-add "$KEY_DIR/$KEY1_NAME"
ssh-add "$KEY_DIR/$KEY2_NAME"


echo -e "\nListe des clés chargées dans l'agent SSH :"
ssh-add -l


echo "Clés publiques des VMs :" > "$OUTPUT_FILE"
echo -e "\n### Clé publique 1 (sshvm1) ###" >> "$OUTPUT_FILE"
cat "$KEY_DIR/$KEY1_NAME.pub" >> "$OUTPUT_FILE"
echo -e "\n### Clé publique 2 (sshvm2) ###" >> "$OUTPUT_FILE"
cat "$KEY_DIR/$KEY2_NAME.pub" >> "$OUTPUT_FILE"

echo -e "\nEmplacements des clés SSH générées :"
echo "Clé privée 1 : $KEY_DIR/$KEY1_NAME"
echo "Clé publique 1 : $KEY_DIR/$KEY1_NAME.pub"
echo "Clé privée 2 : $KEY_DIR/$KEY2_NAME"
echo "Clé publique 2 : $KEY_DIR/$KEY2_NAME.pub"
echo "Fichier contenant les clés publiques : $OUTPUT_FILE"

echo -e "\nInstructions :"
echo "1. Ajouter la clé publique à votre VM Azure :"
echo "   cat ~/.ssh/$KEY1_NAME.pub >> ~/.ssh/authorized_keys"
echo "   cat ~/.ssh/$KEY2_NAME.pub >> ~/.ssh/authorized_keys"
echo "2. Se connecter à la VM avec la clé privée :"
echo "   ssh -i ~/.ssh/$KEY1_NAME azureuser@IP_VM_AZURE"
