ContentType="text/markdown">
# Aztec Prover Node Setup

Skrip ini mengotomatisasi pengaturan **Prover Node**, **Proving Broker**, dan **Proving Agent** untuk jaringan Aztec alpha-testnet menggunakan Docker Compose. Prover Node menghasilkan bukti kriptografi untuk transaksi publik dan mengirimkan rollup proof ke Ethereum.

## Prasyarat
- **Sistem Operasi**: Ubuntu Linux.
- **Hardware**:
  - Prover Node: 8 core, 16GB RAM, 1TB disk.
  - Broker: 4 core, 16GB RAM, 1GB disk.
  - Agent: 16 core, 128GB RAM per agent (default: 1 agent).
- **Koneksi Internet**: Untuk mengunduh Docker dan image Aztec.
- **Data Konfigurasi**:
  - URL RPC Sepolia (misalnya, Alchemy/QuickNode, harus mendukung blob data).
  - URL Beacon Chain (misalnya, dRPC/Quicknode).
  - Kunci privat Ethereum dan alamat publik yang sesuai.
  - Alamat publik VPS untuk P2P (contoh: `/ip4/<your-vps-ip>/tcp/40400`).
- **Git**: Untuk meng-clone repositori.
- **SSH Akses**: Untuk VPS, pastikan bisa mengedit file via `nano` atau unggah file via `scp`.

# PENTING
## [KLIK INI BUAT RPC ALCHEMY](https://www.alchemy.com/)
## [KLIK INI BUAT dRPC](https://drpc.org/)

## Langkah Penggunaan
1. **Clone Repositori**:
   ```bash
   git clone https://github.com/USERNAME/aztec-prover-setup.git
   cd a/aztec-prover-node
   ```
   Ganti `USERNAME` dengan nama pengguna GitHub.

2. **Beri Izin Skrip**:
   ```bash
   chmod +x setup-aztec-prover.sh
   ```

3. **Jalankan Skrip Pertama Kali**:
   ```bash
   ./setup-aztec-prover.sh
   ```
   - Skrip akan menginstal dependensi, Aztec CLI, dan membuat file `.env`, lalu berhenti.
   - Jika `.env` sudah ada, skrip tidak akan menimpanya.

4. **Edit File `.env`**:
   - Buka file di VPS:
     ```bash
     nano .env
     ```
   - Isi variabel:
     - `ETHEREUM_HOSTS`: URL RPC Sepolia (pastikan mendukung blob data, contoh: `https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key`).
     - `L1_CONSENSUS_HOST_URL`: URL Beacon Chain (contoh: `https://sepolia-beacon.drpc.org`).
     - `PROVER_PUBLISHER_PRIVATE_KEY`: Kunci privat Ethereum (contoh: `0xYourPrivateKey`).
     - `PROVER_ID`: Alamat publik Ethereum (contoh: `0xYourPublicAddress`).
     - `P2P_ANNOUNCE_ADDR`: Alamat publik VPS untuk P2P (contoh: `/ip4/203.0.113.1/tcp/40400`).  (cek pake `curl ifconfig.me`).
   - Simpan: Tekan Ctrl+O, Enter, lalu keluar dengan Ctrl+X.
   - Alternatif: Edit `.env` di komputer lokal, lalu unggah ke VPS:
     ```bash
     scp .env user@your-vps-ip:/path/to/aztec-prover-setup/
     ```

5. **Lanjutkan Skrip**:
   - Jalankan lagi untuk melanjutkan:
     ```bash
     ./setup-aztec-prover.sh --resume
     ```
   - Skrip akan membuat `docker-compose.yml` (jika belum ada) dan menjalankan layanan.

## Perintah Berguna
- **Cek Status**:
  ```bash
  sudo docker-compose ps
  ```
- **Lihat Log**:
  ```bash
  sudo docker-compose logs -f
  ```
- **Hentikan Layanan**:
  ```bash
  sudo docker-compose down
  ```

## Catatan Penting
- **Port**: Pastikan port `8080` (HTTP) dan `40400` (TCP/UDP) terbuka di firewall VPS.
- **Versi Image**: Skrip menggunakan `aztecprotocol/aztec:0.85.0-alpha-testnet.2`. Periksa dokumentasi resmi Aztec untuk versi terbaru.
- **Aztec CLI**: Skrip otomatis menambahkan `/root/.aztec/bin` ke PATH. CLI opsional tapi berguna untuk debugging.
- **File `.env`**: Tidak ditimpa jika sudah ada. Pastikan isinya valid sebelum `--resume`.
- **Resume**: Gunakan `--resume` untuk melanjutkan dari langkah terakhir.
- **Keamanan**: Jangan bagikan `PROVER_PUBLISHER_PRIVATE_KEY`.
- **P2P Opsional**: Set `P2P_ENABLED=false` di `.env` jika P2P tidak diperlukan.

## Troubleshooting
- **Error: NoBlobBodiesFoundError**:
  - **Penyebab**: RPC provider tidak menyediakan blob data untuk block tertentu.
  - **Solusi**:
    1. Gunakan RPC provider yang mendukung blob data (contoh: Alchemy, QuickNode).
    2. Jika lokal client, set `ETHEREUM_HOSTS=host.docker.internal` di `.env`.
    3. Cek konektivitas:
       ```bash
       curl -s $ETHEREUM_HOSTS -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x505f", true],"id":1}'
       ```
    4. Laporkan ke [Aztec GitHub](https://github.com/AztecProtocol/aztec-packages) jika berlanjut.

- **Error: Announce address not provided**:
  - **Penyebab**: Konfigurasi P2P tidak lengkap.
  - **Solusi**:
    1. Isi `P2P_ANNOUNCE_ADDR` di `.env` (contoh: `/ip4/<your-vps-ip>/tcp/40400`). Dapatkan IP VPS:
       ```bash
       curl ifconfig.me
       ```
    2. Buka port `40400` (TCP/UDP):
       ```bash
       sudo ufw allow 40400
       ```
    3. Nonaktifkan P2P jika tidak diperlukan:
       ```bash
       echo 'P2P_ENABLED=false' >> .env
       sudo docker-compose down && sudo docker-compose up -d
       ```
    4. Cek konektivitas port:
       ```bash
       nc -zv your-vps-ip 40400
       ```

- **Error Edit `.env`**:
  - Gunakan `scp` untuk unggah file dari lokal:
    ```bash
    scp .env user@your-vps-ip:/path/to/aztec-prover-setup/
    ```

- **Aztec CLI Gagal**:
  - Cek PATH:
    ```bash
    echo $PATH
    ```
  - Tambahkan manual:
    ```bash
    echo 'export PATH=$PATH:/root/.aztec/bin' >> ~/.bashrc
    source ~/.bashrc
    ```

Untuk bantuan, cek dokumentasi Aztec atau komunitas (misalnya, Discord Aztec).
</xArtifact>

### Langkah untuk Memperbaiki Error
1. **Hentikan Layanan**:
   ```bash
   sudo docker-compose down
   ```

2. **Perbarui `.env`**:
   - Buka `.env`:
     ```bash
     nano .env
     ```
   - Pastikan:
     - `ETHEREUM_HOSTS`: Gunakan RPC yang mendukung blob (contoh: Alchemy, QuickNode). Jika lokal, coba `host.docker.internal`.
     - `P2P_ANNOUNCE_ADDR`: Set ke IP publik VPS, contoh: `/ip4/203.0.113.1/tcp/40400`. Cek IP:
       ```bash
       curl ifconfig.me
       ```
     - Jika tidak butuh P2P, set `P2P_ENABLED=false`.
   - Simpan (Ctrl+O, Enter, Ctrl+X).

3. **Buka Port**:
   ```bash
   sudo ufw allow 8080
   sudo ufw allow 40400
   sudo ufw status
   ```

4. **Jalankan Skrip**:
   - Simpan skrip di atas ke `setup-aztec-prover.sh`.
   - Jalankan dengan resume (karena `.env` sudah ada):
     ```bash
     chmod +x setup-aztec-prover.sh
     ./setup-aztec-prover.sh --resume
     ```

5. **Cek Log**:
   ```bash
   sudo docker-compose logs -f
   ```

### Catatan Penting
- **RPC Provider**: Hubungi provider (misalnya, Alchemy) untuk konfirmasi dukungan blob data. Jika tidak mendukung, coba QuickNode atau jalankan node Sepolia lokal (butuh resource besar).
- **P2P**: Jika masih error, nonaktifkan P2P dengan `P2P_ENABLED=false` untuk debugging.
- **Komunitas Aztec**: Laporkan error ke [Aztec GitHub](https://github.com/AztecProtocol/aztec-packages) atau Discord Aztec jika tidak teratasi.
- **VPS Resource**: Pastikan VPS memenuhi spesifikasi (8 core/16GB untuk Node, 16 core/128GB untuk Agent).

Jika masih ada error atau butuh bantuan lebih lanjut (misalnya, konfigurasi spesifik atau debug log), kasih tahu saya detailnya! Semoga skrip dan README ini membantu menyelesaikan masalah Prover Node-mu.
