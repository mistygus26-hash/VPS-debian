#!/bin/bash

# ==========================================
# VPS PostgreSQL Backup Script - SAFE MODE
# Auteur: Auto-Healing Agent
# ==========================================
# Ce script est 100% SAFE :
# - Lecture seule de la base de données
# - Ne supprime RIEN
# - Ne modifie RIEN
# - Crée uniquement des fichiers de backup
# ==========================================

set -e

# Configuration
BACKUP_DIR="/opt/backups/postgres"
CONTAINER_NAME="n8n-postgres-prod"
POSTGRES_USER="n8n"
POSTGRES_DB="n8n"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="n8n_backup_${DATE}.sql.gz"

echo "🔒 Démarrage du backup PostgreSQL (Mode SAFE - Lecture seule)..."

# 1. Créer le dossier de backup s'il n'existe pas
echo "📁 Création du répertoire de backup..."
mkdir -p "${BACKUP_DIR}"

# 2. Vérifier que le conteneur PostgreSQL est en marche
echo "🐳 Vérification du conteneur PostgreSQL..."
if ! docker ps | grep -q "${CONTAINER_NAME}"; then
    echo "❌ ERREUR: Le conteneur ${CONTAINER_NAME} n'est pas en marche."
    exit 1
fi

echo "✅ Conteneur PostgreSQL actif"

# 3. Dump de la base de données (LECTURE SEULE)
echo "💾 Création du dump PostgreSQL..."
docker exec "${CONTAINER_NAME}" pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "${BACKUP_DIR}/${BACKUP_FILE}"

# 4. Vérifier que le backup a été créé
if [ -f "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
    echo "✅ Backup créé avec succès !"
    echo "   📦 Fichier: ${BACKUP_FILE}"
    echo "   📏 Taille: ${BACKUP_SIZE}"
    echo "   📍 Emplacement: ${BACKUP_DIR}/${BACKUP_FILE}"
else
    echo "❌ ERREUR: Le backup n'a pas été créé."
    exit 1
fi

# 5. Lister tous les backups existants
echo ""
echo "📚 Backups disponibles dans ${BACKUP_DIR}:"
ls -lh "${BACKUP_DIR}/"

echo ""
echo "✅ Backup terminé avec succès !"
echo "⚠️  NOTE: Ce script NE SUPPRIME AUCUN ancien backup pour votre sécurité."
echo "   Pour libérer de l'espace, supprimez manuellement les anciens backups si nécessaire."
