# Benchmarking Setup Guide

This document summarises the whole procedure to setup a test server for benchmarking we used to collect reports. Lookup individual tool's official documentation for more granular information.

## Local Flask Server

Requires python installation.

1. Get flask and waitress from pip.

   ```bash
   pip install flask waitress
   ```

2. Start the server.

   ```bash
   cd test_servers/flask
   waitress-serve --call 'app:main'
   ```

Now, local server should be accessable from <http://localhost:8080>. See [Flask Docs](https://flask.palletsprojects.com/en/2.0.x/) and [Waitress Docs](https://docs.pylonsproject.org/projects/waitress/en/latest/) for more information.

## Local Caddy 2 Server

Requires golang 1.15 and above installation.

1. Install caddy as per your platform accordingly from [Caddy Official Installation Docs](https://caddyserver.com/docs/install).

2. Add a domain name to your `/etc/host` file.

   ```text
   127.0.0.1 localsite.org localsite
   ```

3. Create an SSL Certificate using [mkcert](https://github.com/FiloSottile/mkcert#installation) inside `test_servers/caddy` folder and install it.

   ```bash
   cd test_servers/caddy
   mkcert localsite.org
   mkcert -install
   ```

4. Adapt to config and start the Caddy server.

   ```bash
   cd test_servers/caddy
   caddy adapt
   sudo caddy run
   ```

Now, site should be available at <https://localsite.org>. See [Caddy Docs](https://caddyserver.com/docs/) for more information.
