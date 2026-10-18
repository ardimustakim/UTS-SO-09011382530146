#!/bin/bash
# Nama   : Ardi Mustakim
# NIM    : 09011382530146
# Kelas  : [SKU3B]
#
# backup_loop.sh - Menjalankan backup.sh secara berulang setiap INTERVAL
# detik, sehingga backup berjalan terus-menerus di latar belakang.
# Jalankan di background dengan : ./backup_loop.sh &
# Lihat daftar job            : jobs -l
# Hentikan                    : kill <PID>   atau   kill %<nomor_job>

# ===================== Variabel =====================
# Lokasi script backup.sh diambil relatif terhadap lokasi file ini, supaya
# backup_loop.sh tetap bisa dipanggil dari direktori mana pun.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="${SCRIPT_DIR}/backup.sh"

# Lama jeda antar proses backup (detik). Nilai bawaan 60 detik, tetapi bisa
# diganti lewat argumen pertama, misalnya ./backup_loop.sh 30
INTERVAL="${1:-60}"

echo "backup_loop.sh berjalan (PID $$), backup setiap ${INTERVAL} detik."
echo "Hentikan dengan: kill $$"

# ===================== 8. Background job =====================
while true; do
    "$BACKUP_SCRIPT"
    sleep "$INTERVAL"
done
