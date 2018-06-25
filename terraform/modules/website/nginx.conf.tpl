events {
  worker_connections  1024;
}

http {
  server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name ${server_name};

    location / {
      proxy_pass http://localhost:8080;
    }
  }
}
