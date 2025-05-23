ll
mkdir -p ~/.config/containers/systemd
mkdir -p ~/.local/share/containers/storage/volumes
ln -s ~/.config/containers/systemd ~/containers
ln -s ~/.local/share/containers/storage/volumes ~/volumes
ll
systemctl --user enable podman-auto-update.timer --now
gst
ls -la
ll
exit
