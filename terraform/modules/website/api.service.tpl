[Unit]
Description=Website
After=network.target

[Service]
Type=simple
User=coconut
WorkingDirectory=/mnt/website
Environment=RUST_LOG=actix_web=info,api=debug
ExecStart=/mnt/website/binary/secrets-fetcher api -- /mnt/website/binary/api run --binding 0.0.0.0:8080 --cors ${cors}
Restart=on-failure

[Install]
WantedBy=multi-user.target
