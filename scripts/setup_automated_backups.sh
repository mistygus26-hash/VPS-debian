#!/bin/bash

# ==========================================
# Setup Automated PostgreSQL Backups
# Auteur: Auto-Healing Agent
# ==========================================
# Configure backup quotidien + rotation 7 jours
# ==========================================

set -e

echo "🔧 Configuration des backups automatiques PostgreSQL..."

# 1. Copier le script de backup dans /usr/local/bin
echo "📋 Installation du script de backup..."
BACKUP_SCRIPT="/usr/local/bin/backup_postgres.sh"
cat > "$BACKUP_SCRIPT" << 'BACKUP_EOF'
#!/bin/bash
set -e

BACKUP_DIR="/opt/backups/postgres"
CONTAINER_NAME="n8n-postgres-prod"
POSTGRES_USER="n8n"
POSTGRES_DB="n8n"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="n8n_backup_${DATE}.sql.gz"
RETENTION_DAYS=7

# Créer le répertoire de backup
mkdir -p "${BACKUP_DIR}"

# Dump PostgreSQL
docker exec "${CONTAINER_NAME}" pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "${BACKUP_DIR}/${BACKUP_FILE}"

# Rotation: Supprimer les backups de plus de 7 jours
find "${BACKUP_DIR}" -name "n8n_backup_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -delete

echo "✅ Backup créé: ${BACKUP_FILE}"
echo "🗑️  Backups de plus de ${RETENTION_DAYS} jours supprimés"
BACKUP_EOF

chmod +x "$BACKUP_SCRIPT"
echo "✅ Script installé dans $BACKUP_SCRIPT"

# 2. Configurer le cron job (quotidien à 3h du matin)
echo "⏰ Configuration du cron job..."
CRON_JOB="0 3 * * * $BACKUP_SCRIPT >> /var/log/postgres_backup.log 2>&1"

# Vérifier si le cron existe déjà
if crontab -l 2>/dev/null | grep -q "backup_postgres.sh"; then
    echo "⚠️  Cron job déjà existant, pas de modification"
else
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job ajouté (backup quotidien à 3h00)"
fi

# 3. Créer le fichier de log
touch /var/log/postgres_backup.log
chmod 644 /var/log/postgres_backup.log

# 4. Tester le backup immédiatement
echo ""
echo "🧪 Test du backup..."
$BACKUP_SCRIPT

echo ""
echo "✅ Configuration terminée avec succès !"
echo ""
echo "📅 Récapitulatif:"
echo "   • Backup quotidien à 3h00 du matin"
echo "   • Rotation: Conservation de 7 jours"
echo "   • Log: /var/log/postgres_backup.log"
echo "   • Emplacement: /opt/backups/postgres/"
echo ""
echo "🔍 Pour vérifier le cron:"
echo "   crontab -l"
echo ""
echo "📊 Pour voir les logs:"
echo "   tail -f /var/log/postgres_backup.log"
