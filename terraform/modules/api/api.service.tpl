[Unit]
Description=api
After=network.target

[Service]
Type=simple
User=coconut
WorkingDirectory=/mnt/api
Environment=RUST_LOG=actix_web=info,api=debug
ExecStart=/mnt/api/binary/secrets-fetcher api -- /mnt/api/binary/api run --binding 0.0.0.0:8080 --cors ${cors}
Restart=on-failure

[Install]
WantedBy=multi-user.target
