events {
  worker_connections  1024;
}

http {
  # redirect bare domain to www, to make sure there's only one canonical URL
  # for everything, but that people who request the bare domain still get
  # where they want to go
  server {
    server_name ${server_name};
    return 301 $scheme://www.${server_name}$request_uri;
  }


  # serve the elm front-end by serving files
  server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name www.${server_name};

    location / {
      include /etc/nginx/mime.types;
      root /mnt/website/website;
      try_files $uri $uri/ /index.html;
    }
  }

  # serve the API by proxying requests to the rust service running locally,
  # which is managed by systemd
  server {
    listen 80;
    listen [::]:80;

    server_name api.${server_name};

    location / {
      proxy_pass http://localhost:8080;
    }
  }
}
