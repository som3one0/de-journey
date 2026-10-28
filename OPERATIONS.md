# WhiteRabbitNeo Operations

Start the services detached so they continue running after the VS Code terminal
or SSH session closes:

```bash
docker compose up -d
```

The containers use `restart: unless-stopped`, so Docker restarts them after a
container or Docker daemon failure. Check their state with:

```bash
docker compose ps
```

GitHub Codespaces can still stop the entire VM after its idle timeout. When the
Codespace is stopped, its public URLs are unavailable. Reopen or start the
Codespace and run `docker compose up -d` again. For true 24/7 public access,
move this Compose deployment to a persistent VM or cloud server.