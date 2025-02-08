#!/bin/bash


MEMORY_SCRIPT="/home/$USER/memory_monitor.sh"
LOG_FILE="/home/$USER/memory_usage.log"
CRON_JOB="*/30 * * * * /bin/bash $MEMORY_SCRIPT"


if ! command -v cron >/dev/null 2>&1 && ! command -v crond >/dev/null 2>&1; then
    echo "CRON n'est pas installé. Installation en cours..."
    sudo apt update && sudo apt install cron -y
    sudo systemctl enable cron
    sudo systemctl start cron
fi


if [ ! -f "$MEMORY_SCRIPT" ]; then
    echo "Création du script de monitoring : $MEMORY_SCRIPT"
    echo "#!/bin/bash

DATE=\$(date +\"%Y-%m-%d %H:%M:%S\")


MEM_INFO=\$(free -m | awk 'NR==2{printf \"Mémoire utilisée: %s Mo / %s Mo (%.2f%%)\", \$3, \$2, \$3*100/\$2 }')


echo \"\$DATE - \$MEM_INFO\" >> $LOG_FILE

# Vérification si utilisation dépasse 80%
USAGE=\$(free | awk 'NR==2{printf \"%.0f\", \$3*100/\$2 }')
if [ \"\$USAGE\" -gt 80 ]; then
    echo \"\$DATE - ATTENTION: Utilisation élevée de la mémoire (\$USAGE%)\" >> $LOG_FILE
fi
" > $MEMORY_SCRIPT

    chmod +x $MEMORY_SCRIPT
    echo "Script de monitoring créé et rendu exécutable."
fi


if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
    echo "Fichier log créé : $LOG_FILE"
fi

if ! crontab -l 2>/dev/null | grep -q "$MEMORY_SCRIPT"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Tâche CRON ajoutée pour exécuter le script toutes les 30 minutes."
else
    echo "La tâche CRON est déjà configurée."
fi


echo "Tâches CRON actuelles :"
crontab -l

echo " Logs mémoire disponibles dans : $LOG_FILE"
