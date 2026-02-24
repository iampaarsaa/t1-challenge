# Tier1 Challenge

## Implementation Guide
This guide walks you through implementing this project.

### Next.js Application on ArvanCloud CaaS

1. Install [Docker Engine](https://docs.docker.com/engine/install/debian/) on your local computer.

2. Clone this repository and navigate into the `blog` directory:

```bash
git clone https://github.com/iampaarsaa/t1-challenge.git
cd blog
```

3. Build the Docker image and tag it to match the destination registry address:

```bash
docker build -t registry-8595781cfa-astroadre.apps.ir-central1.arvancaas.ir/parsa/blog-app:v1.1 .
```

4. Log in to the destination registry and push the image:

```bash
docker login
docker push registry-8595781cfa-astroadre.apps.ir-central1.arvancaas.ir/parsa/blog-app:v1.1
```

5. After the image is pushed, add the following information to ArvanCloud PaaS:

- image-name: `registry-8595781cfa-astroadre.apps.ir-central1.arvancaas.ir/parsa/blog-app`
- image-tag: `v1.1`
- registry-username: `<your-username>`
- registry-password: `<your-password>`

6. Name the application and set the container port to `3000`.

7. Choose your domain already defined in ArvanCloud CDN and select its subdomain.

8. Set `3000` as the application port and `3000` as the exposed port.

9. Disable Automatic Zone Selection, set `MaxReplica` to `3`, and set `MaxSkew` to `1`.

10. Your Next.js application will now be accessible.

---

## Multi-Server WordPress Application

1. Acquire three cloud servers — all in a single private network, each assigned a floating IP.  

```bash
# Install these packages
sudo apt install nginx php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip php-imagick unzip curl -y
```

2. Install `nfs-kernel-server` on one server and run these commands to create the NFS directory:

```bash
sudo mkdir -p /srv/nfs/wordpress
sudo chown -R www-data:www-data /srv/nfs/wordpress
sudo chmod -R 755 /srv/nfs/wordpress
```

3. Configure `/etc/exports` similar to `wordpress/exports` and apply the changes:

```bash
sudo exportfs -ra
sudo exportfs -v
```

4. Install `nfs-common` on the two other servers and prepare the mount point:

```bash
sudo mkdir -p /mnt/wordpress
sudo chown -R www-data:www-data /mnt/wordpress
sudo chmod -R 755 /mnt/wordpress
```

5. Mount the NFS storage on clients and make it permanent by adding it to `/etc/fstab`:

```bash
sudo mount -t nfs <Server Private IP>:/srv/nfs/wordpress
sudo df -h | grep nfs
ls /mnt/wordpress
```

6. Install WordPress from the official website and unzip it into the mounted space:

```bash
cd /mnt/wordpress
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo chown -R www-data:www-data myblog
sudo mv wp-config-simple.php wp-config.php
```

7. Define environment variables at the end of `/etc/php/<version>/fpm/pool.d/www.conf`:

```bash
env[DB_NAME]     = <DB-NAME>
env[DB_USER]     = <DB-USER>
env[DB_PASSWORD] = <DB-PASS>
env[DB_HOST]     = <DB-HOST>
```

8. Add these environment variables in `wp-config.php` for database connectivity:

```php
define('DB_NAME', getenv("DB_NAME"));
define('DB_USER', getenv("DB_USER"));
define('DB_PASSWORD', getenv("DB_PASSWORD"));
define('DB_HOST', getenv("DB_HOST"));
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
```

9. Transfer the SSL certificate and private key to the servers and configure Nginx similar to `wordpress/nginx.conf`.

10. Reload the Nginx service — your WordPress site should now be accessible.

---

## ArvanCloud CDN

No need to explain further; everything is documented in [ArvanCloud Docs](https://docs.arvancloud.ir).

---

## Separate Log Server

1. Acquire a cloud server, provision it, and install `rsyslog` for the syslog server:

```bash
sudo apt install rsyslog
```

2. Configure the rsyslog server according to `syslog/rsyslog.conf`.

3. Connect to the WordPress servers and install `rsyslog` there.

4. Configure the rsyslog clients according to `syslog/rsyslog.d-remote.conf`.

5. Review your Nginx configuration in `wordpress/nginx.conf` to ensure proper logging.

6. Restart the syslog service — your syslog server should now be accessible.

---

## Backup Solutions

1. Acquire a cloud server, provision it, and install `rclone` and MySQL client:

```bash
sudo apt install rclone default-mysql-client
```

2. Set up object storage according to [ArvanCloud Docs](https://docs.arvancloud.ir).

3. Configure `rclone` similar to `backup/rclone.conf` and store secrets in `.env` files.

4. Create directories to better manage your scripts:

```bash
mkdir -p /home/debian/script/.tmp
```

5. Write scripts similar to `backup/log-backup.sh` and `backup/db-backup.sh` and store database secrets in `.env` files.

6. Properly distribute SSH keys across all required servers and execute the scripts — you now have log and database backup solutions.

---
## Metric Monitoring and Observability

1. Install node-exporter on wordpress servers
```bash
sudo apt install prometheus-node-exporter
```

2. According to `monit/prom-manifest.yaml` and `monit/graf-manifest.yaml` deploy applicaitons

3. Open Browser and Enter Web address for Prometheus Application. Make sure prometheus have all needed metrics.

4. Open Browser and Log Into Grafana Application. Import Node-Exporter-Full and ArvanCloud Monitoring Templates



