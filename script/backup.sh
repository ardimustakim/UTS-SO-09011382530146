#!/bin/bash
# Nama   : Ardi Mustakim
# NIM    : 09011382530146
# Kelas  : [ISI KELAS ANDA]
#
# backup.sh - Mencari file catatan praktikum di direktori sumber (termasuk
# di dalam subdirektori), mengarsipkan dan mengompresinya menjadi satu file
# .tar.gz bernama tanggal dan jam, lalu mencatat proses backup ke file log.

# ===================== 2. Variabel utama =====================
NIM="09011382530146"
SOURCE_DIR="$HOME/data_${NIM}"
BACKUP_DIR="$HOME/backup_${NIM}"
LOG_FILE="${BACKUP_DIR}/backup.log"

# Fitur tambahan "Parameter": ekstensi file yang dicari bisa diisi lewat
# argumen pertama, misalnya ./backup.sh pdf. Jika tidak diisi, memakai nilai
# bawaan "txt" sesuai ketentuan wajib.
EXT="${1:-txt}"

# Fitur tambahan "Rotasi arsip": jumlah arsip terbaru yang tetap disimpan.
MAX_ARSIP=5

# ===================== 3. Pastikan direktori tujuan ada =====================
mkdir -p "$BACKUP_DIR"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Direktori sumber ${SOURCE_DIR} tidak ditemukan." >&2
    exit 1
fi

# ===================== 4. Pencarian file =====================
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DAFTAR_FILE="${BACKUP_DIR}/daftar_file_${TIMESTAMP}.txt"

# Dicari relatif terhadap SOURCE_DIR agar nama di dalam arsip rapi (tidak
# membawa path absolut), lalu disimpan ke sebuah file teks.
find "$SOURCE_DIR" -type f -name "*.${EXT}" | sed "s|^${SOURCE_DIR}/||" > "$DAFTAR_FILE"

JUMLAH_FILE=$(wc -l < "$DAFTAR_FILE" | tr -d ' ')

if [ "$JUMLAH_FILE" -eq 0 ]; then
    echo "Tidak ada file .${EXT} yang ditemukan di ${SOURCE_DIR}."
    rm -f "$DAFTAR_FILE"
    exit 1
fi

# ===================== 5. Pengarsipan dan kompresi =====================
NAMA_ARSIP="backup_${NIM}_${TIMESTAMP}.tar.gz"
PATH_ARSIP="${BACKUP_DIR}/${NAMA_ARSIP}"

tar -czvf "$PATH_ARSIP" -C "$SOURCE_DIR" -T "$DAFTAR_FILE"

# ===================== 6. Verifikasi arsip =====================
echo "Isi arsip ${NAMA_ARSIP}:"
tar -tzvf "$PATH_ARSIP"

# ===================== 7. Log =====================
UKURAN_ARSIP=$(du -h "$PATH_ARSIP" | cut -f1)
WAKTU=$(date +"%Y-%m-%d %H:%M:%S")
echo "${WAKTU} | ${NAMA_ARSIP} | ${JUMLAH_FILE} | ${UKURAN_ARSIP}" >> "$LOG_FILE"

rm -f "$DAFTAR_FILE"

# ===================== Fitur tambahan: Rotasi arsip =====================
# Hanya menyimpan MAX_ARSIP arsip .tar.gz terbaru, menghapus yang lebih lama.
JUMLAH_ARSIP=$(ls -1 "${BACKUP_DIR}"/backup_"${NIM}"_*.tar.gz 2>/dev/null | wc -l)
if [ "$JUMLAH_ARSIP" -gt "$MAX_ARSIP" ]; then
    ls -1t "${BACKUP_DIR}"/backup_"${NIM}"_*.tar.gz | tail -n +$((MAX_ARSIP + 1)) | \
    while read -r arsip_lama; do
        echo "Rotasi arsip: menghapus arsip lama ${arsip_lama}"
        rm -f "$arsip_lama"
    done
fi

echo "Backup selesai: ${PATH_ARSIP}"
