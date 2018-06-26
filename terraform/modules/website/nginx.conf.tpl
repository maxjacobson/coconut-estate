events {
  worker_connections  1024;
}

http {
  server {
    server_name ${server_name};
    return 301 $scheme://www.${server_name}$request_uri;
  }

  server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name www.${server_name};

    location / {
      proxy_pass http://localhost:8080;
    }
  }
}
