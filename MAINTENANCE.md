# Codespace Maintenance

Start the maintenance daemon from the repository root:

```bash
chmod +x codespace-maintenance.sh
nohup ./codespace-maintenance.sh >/dev/null 2>&1 &
echo $! > "$HOME/.codespace-maintenance/pid"
```

Inspect it with:

```bash
tail -f "$HOME/.codespace-maintenance/maintenance.log"
cat "$HOME/.codespace-maintenance/pid"
```

The daemon writes a heartbeat every 60 seconds, starts the Compose stack if
the model service is missing, and every 10 minutes removes only stopped
containers, dangling images, and unused build cache. It never removes Docker
volumes or files under `models/`.

This can keep the Codespace active while the process runs, but GitHub can still
stop a Codespace because of policy, maximum lifetime, manual stop, or host
maintenance. It cannot guarantee permanent uptime.

Override intervals when starting it, for example:

```bash
MAINTENANCE_INTERVAL_SECONDS=60 PRUNE_INTERVAL_SECONDS=1800 \
  nohup ./codespace-maintenance.sh >/dev/null 2>&1 &
```