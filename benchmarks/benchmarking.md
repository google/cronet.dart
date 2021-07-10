# Benchmarking Setup Guide

This document summarises the whole procedure to setup a test server for benchmarking we used to collect reports. Lookup individual tool's official documentation for more granular information.

## Local Flask Server

Requires python installation.

1. Get flask and waitress from pip.

   ```bash
   pip install flask waitress
   ```

2. Create a new `app.py` file that contains -

   ```python
    from waitress import serve

    from flask import Flask

    SECRET_KEY = b'\xd8p\xff\xac\xceN\xf7\x98\x1a\xef&@i/\xbfZ'
    app = Flask(__name__)

    @app.route('/')
    def hw():
        return 'hello world'

    @app.route('/<id>')
    def lorem(id):
       return f"""
       {id}
       Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque euismod dui nisl, ac dictum leo imperdiet vel. Vestibulum tincidunt augue a enim ullamcorper aliquam. Etiam vel iaculis nunc, cursus dapibus mi. Vivamus in ex nulla. Aliquam maximus, odio at pulvinar scelerisque, felis leo pellentesque lacus, quis suscipit nulla metus a neque. Phasellus et sem a purus placerat ornare sit amet ut ipsum. Donec semper elit lacus, vel posuere leo porta sit amet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed at sapien mi. Nullam scelerisque porta hendrerit. Nulla molestie consectetur enim ac venenatis. Duis euismod viverra magna, at pharetra risus sagittis ac. Ut mollis nibh augue, quis tristique sem interdum in. Donec ac luctus quam, eu dapibus massa. Aliquam maximus tempus volutpat. Cras sagittis lorem ut arcu tempor, a vehicula turpis vehicula.
       """

    serve(app, host='0.0.0.0', port=8080)
   ```

3. Start the server.

   ```bash
   waitress-serve --call 'app:main'
   ```

Now, local server should be accessable from <http://localhost:8080>.

## Local Caddy 2 Server

Requires golang 1.15 and above installation.

1. Install caddy as per your platform accordingly from [Caddy Official Installation Docs](https://caddyserver.com/docs/install).
2. Add a domain name to your `/etc/host` file. Edit and paste

   ```text
   127.0.0.1 localsite.org localsite
   ```

3. Create an SSL Certificate using [mkcert](https://github.com/FiloSottile/mkcert#installation) and install it.

    ```bash
    mkcert localsite.org
    mkcert -install
    ```

4. Create a `Caddyfile` and add the following

    ```text
    {
       servers {
        protocol {
         allow_h2c
         experimental_http3
        }
       }
    }

   localsite.org {
       tls ./localsite.org.pem localsite.org-key.pem
       root * www
       encode zstd gzip
       templates
       file_server browse

       metrics /metrics
   }
    ```

5. Create a `www` folder and add any file to it. index.html will serve as a home page. Example -

   ```bash
   mkdir www
   cd www
   wget https://example.org
   ```

6. Adapt to config and start the Caddy server.

   ```bash
   caddy adapt
   sudo caddy run
   ```

Now, site should be available at <https://localsite.org>.
