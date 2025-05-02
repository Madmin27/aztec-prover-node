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

## Langkah Penggunaan
1. **Clone Repositori**:
   ```bash
   git clone https://github.com/USERNAME/aztec-prover-setup.git
   cd aztec-prover-setup
   ```
   Ganti `USERNAME` dengan nama pengguna GitHub.

2. **Beri Izin Skrip**:
   ```bash
   chmod +x setup-aztec-prover.sh
   ```

3. **Jalankan Skrip**:
   ```bash
   ./setup-aztec-prover.sh
   ```

4. **Edit File `.env`**:
   - Saat diminta, buka `nano .env` dan isi:
     - `ETHEREUM_HOSTS`: URL RPC Sepolia (contoh: `https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key`).
     - `L1_CONSENSUS_HOST_URL`: URL Beacon Chain (contoh: `https://sepolia-beacon.drpc.org`).
     - `PROVER_PUBLISHER_PRIVATE_KEY`: Kunci privat Ethereum (contoh: `0xYourPrivateKey`).
     - `PROVER_ID`: Alamat publik Ethereum (contoh: `0xYourPublicAddress`).
   - Simpan (Ctrl+O, Enter, Ctrl+X di nano).

5. **Lanjutkan**:
   - Tekan Enter untuk membuat `docker-compose.yml` dan menjalankan layanan.

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
- **Port**: Pastikan port `8080` (HTTP) dan `40400` (TCP/UDP) terbuka di firewall.
- **Versi Image**: Skrip menggunakan `aztecprotocol/aztec:0.85.0-alpha-testnet.2`. Periksa dokumentasi resmi Aztec untuk versi terbaru.
- **Aztec CLI**: Skrip mencoba menginstal CLI via `https://install.aztec.network` atau npm (`@aztec/cli`). CLI opsional untuk Docker Compose, tapi berguna untuk debugging.
- **Keamanan**: Jangan bagikan `PROVER_PUBLISHER_PRIVATE_KEY`.
- **P2P Opsional**: Untuk menggunakan validator node, uncomment `P2P_ENABLED` dan `PROVER_COORDINATION_NODE_URL` di `.env` dan `docker-compose.yml`.

## Troubleshooting
- **Error 404 CLI**: Jika instalasi CLI gagal, skrip beralih ke npm. Hubungi komunitas Aztec jika masalah berlanjut.
- **Image Tidak Ditemukan**: Periksa versi image di dokumentasi atau Docker Hub.
- **Log Error**: Gunakan `sudo docker-compose logs -f` untuk detail.

Untuk bantuan, cek dokumentasi resmi Aztec atau tanyakan di komunitas (misalnya, Discord Aztec).