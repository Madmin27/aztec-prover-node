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
  - URL RPC Sepolia (misalnya, Alchemy/Infura).
  - URL Beacon Chain (misalnya, dRPC/Quicknode).
  - Kunci privat Ethereum dan alamat publik yang sesuai.
- **Git**: Untuk meng-clone repositori.
- **SSH Akses**: Untuk VPS, pastikan bisa mengedit file via `nano` atau unggah file via `scp`.

## Langkah Penggunaan
1. **Clone Repositori**:
   ```bash
   git clone https://github.com/0xmugi/aztec-prover-node.git
   cd aztec-prover-node
   ```

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
     - `ETHEREUM_HOSTS`: URL RPC Sepolia (contoh: `https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key`).
     - `L1_CONSENSUS_HOST_URL`: URL Beacon Chain (contoh: `https://sepolia-beacon.drpc.org`).
     - `PROVER_PUBLISHER_PRIVATE_KEY`: Kunci privat Ethereum (contoh: `0xYourPrivateKey`).
     - `PROVER_ID`: Alamat publik Ethereum (contoh: `0xYourPublicAddress`).
   - Simpan: Tekan Ctrl+O, Enter, lalu keluar dengan Ctrl+X.

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
- **Port**: Pastikan port `8080` (HTTP) dan `40400` (TCP')
- **Versi Image**: Skrip menggunakan `aztecprotocol/aztec:0.85.0-alpha-testnet.2`. Periksa dokumentasi resmi Aztec untuk versi terbaru.
- **Aztec CLI**: Skrip otomatis menambahkan `/root/.aztec/bin` ke PATH dan mencoba instalasi via `https://install.aztec.network` atau npm (`@aztec/cli`). CLI opsional untuk Docker Compose, tapi berguna untuk debugging.
- **File `.env`**: File tidak akan ditimpa jika sudah ada. Pastikan isinya valid sebelum melanjutkan dengan `--resume`.
- **Resume**: Gunakan `--resume` untuk melanjutkan dari langkah terakhir, menghemat waktu dengan melewati instalasi yang sudah selesai.
- **Keamanan**: Jangan bagikan `PROVER_PUBLISHER_PRIVATE_KEY`.
- **P2P Opsional**: Untuk menggunakan validator node, uncomment `P2P_ENABLED` dan `PROVER_COORDINATION_NODE_URL` di `.env` dan `docker-compose.yml`.

## Troubleshooting
- **Error Edit `.env`**: Jika sulit mengedit via SSH, gunakan `scp` untuk unggah file dari lokal. Pastikan variabel di `.env` valid.
- **Aztec CLI Gagal**: Jika CLI tidak terdeteksi, cek PATH dengan `echo $PATH`. Tambahkan manual ke `.bashrc` jika perlu:
  ```bash
  echo 'export PATH=$PATH:/root/.aztec/bin' >> ~/.bashrc
  source ~/.bashrc
  ```
- **Image Tidak Ditemukan**: Periksa versi image di dokumentasi atau Docker Hub.
- **Log Error**: Gunakan `sudo docker-compose logs -f` untuk detail.

Untuk bantuan, cek dokumentasi resmi Aztec atau tanyakan di komunitas (misalnya, Discord Aztec).
