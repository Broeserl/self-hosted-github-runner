# GitHub Actions Runner (Docker, official image)

This repository provides a **self‑hosted GitHub Actions runner**  
running **on a Docker‑enabled virtual machine** and using the **official GitHub Actions runner image**.

The runner itself is **only a control process**.  
All builds (e.g. Dockerfiles, devcontainers, CI containers) are executed **as separate Docker containers** on the host.

---

## 🧱 Architecture

```
Ubuntu VM
├── Docker Daemon
│
├── GitHub Runner (Container)
│    └── controls docker build / docker run
│
├── Build containers (from project repositories)
└── Docker image / layer cache
```

✅ **No Docker‑in‑Docker**  
✅ **Runner is independent from build containers**  
✅ **The VM is the security boundary**

---

## 📁 Repository structure

```
.
├── Dockerfile
├── entrypoint.sh
├── docker-compose.yml
├── .env
└── README.md
```

---

## ⚙️ Configuration

All configuration is done via the **`.env`** file.  
The `docker-compose.yml` usually **does not need to be modified**.

A template file **`.env.template`** is provided in this repository.

### Using the environment file

1. Copy the template file:
   ```bash
   cp .env.template .env
   ```

2. Edit `.env` and set the required values:
   ```env
   RUNNER_NAME=runner-01
   RUNNER_URL=https://github.com/OWNER/REPOSITORY
   RUNNER_TOKEN=TOKEN_FROM_GITHUB_UI
   ```

3. **Do not commit the `.env` file**.  
   It contains sensitive information and should remain local.

The `.env.template` file can be safely committed and serves as documentation for the required configuration variables.

---

### Variable description

| Variable | Description |
|--------|------------|
| `RUNNER_NAME` | Display name of the runner in GitHub |
| `RUNNER_URL` | Repository or organization URL |
| `RUNNER_TOKEN` | Short‑lived registration token from GitHub |

> ⚠️ **Note:**  
> The `RUNNER_TOKEN` is only valid for a limited time and must be regenerated when re‑registering the runner.

---

## ▶️ Starting the runner

```bash
docker compose build
docker compose up
```

After a successful start, the runner appears under:

```
Repository → Settings → Actions → Runners
```

Status:
```
Idle
```

---

## 🧠 How it works

- The runner automatically registers itself with GitHub on startup
- GitHub Actions sends jobs to the runner
- The runner executes these jobs
- Docker builds and container runs are executed **on the VM’s Docker daemon**
- The runner container itself remains lightweight and unchanged

---

## 🔒 Security

- The runner has access to the Docker socket (`/var/run/docker.sock`)
- This effectively grants **root access on the VM**
- **Recommended:**
  - Use a dedicated VM for runners only
  - Do not store sensitive data on the VM
  - Do not run other services on the same VM

---

## 🔁 Maintenance & updates

Update the runner:

```bash
docker compose pull
docker compose build
docker compose up -d
```

Re‑register the runner:

1. Generate a new token in GitHub
2. Update `.env`
3. Run `docker compose down && docker compose up`

---

## ✅ Why this setup

- Uses the **official GitHub Actions runner image**
- Full control over entrypoint and lifecycle
- No dependency on third‑party images
- Clear separation of infrastructure and project code
- Well suited for devcontainer‑based builds

---

## 📌 Notes

- This repository contains **no project‑specific build logic**
- It provides **CI infrastructure only**
- Project‑specific Dockerfiles and devcontainers belong in the respective project repositories

## 🔐 Security

A self‑hosted runner executes workflow code **on this machine**. Use it
**only for private repositories** (or trusted contributors): in public
repos, anyone opening a PR can run arbitrary code on the runner and its
host. For private repos, consider `RUNNER_EPHEMERAL=1` for a clean state
per job. The Docker socket mount gives jobs full Docker access — the VM is
the security boundary, so keep the runner on a dedicated VM.

## 🏷️ Labels

Jobs select this runner via labels from `.env`:

```yaml
runs-on: [self-hosted, linux, x64]
```

Labels are set during initial registration only — after changing
`RUNNER_LABELS`, remove the container (`docker compose down`) and the
runner's state volume, then start again.

## ➕ Multiple runners on one VM

Clone this repository once per runner (each clone = its own `.env`):

```bash
git clone https://github.com/Broeserl/self-hosted-github-runner runner-1
git clone https://github.com/Broeserl/self-hosted-github-runner runner-2
# je Verzeichnis: cp .env.template .env, RUNNER_NAME=pi-runner-0X setzen
# (CONTAINER_NAME optional — Default ist der RUNNER_NAME), dann:
cd runner-1 && docker compose up -d
cd runner-2 && docker compose up -d
```

Der Container-Name kommt aus `CONTAINER_NAME` (sonst `RUNNER_NAME`, sonst
`github-runner`) — **lowercase, nur `[a-zA-Z0-9_.-]`**. Jeder Runner
registriert sich mit eigenem Namen + eigenem Token bei GitHub; für
verschiedene Repos einfach `RUNNER_URL` pro Clone anpassen.
