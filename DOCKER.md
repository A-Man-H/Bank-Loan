# Running Ensah Bank with Docker

The app is a **JavaFX desktop GUI**. Since JavaFX has no headless mode, the
container runs it on a virtual X display and streams the window to you over
VNC — so you can use the app from a browser, on any host OS, with only Docker
installed.

## Quick start

```bash
docker compose up --build
```

Then open the app:

- **Browser (noVNC):** http://localhost:6080/vnc.html — click *Connect*
- **VNC client:** connect to `localhost:5900` (no password)

`docker compose up` starts two services:

| Service | What it is |
|---------|-----------|
| `db`    | MySQL 8.4, initialized with `docker/schema.sql` (the `bank` database + tables) |
| `app`   | The JavaFX app on a virtual display (Xvfb) exposed via VNC + noVNC |

The `app` container waits for the database to be healthy before launching.

To stop and remove everything (including the database volume):

```bash
docker compose down -v
```

## Configuration

Everything is environment-driven — copy `.env.example` to `.env` to override.
The most relevant variables:

| Variable      | Default                          | Purpose |
|---------------|----------------------------------|---------|
| `DB_URL`      | `jdbc:mysql://db:3306/bank`      | JDBC URL the app connects to |
| `DB_USER`     | `root`                           | DB user |
| `DB_PASSWORD` | *(empty)*                        | DB password |
| `NOVNC_PORT`  | `6080`                           | Browser (noVNC) port on the host |
| `VNC_PORT`    | `5900`                           | Raw VNC port on the host |
| `SCREEN_GEOMETRY` | `1024x768x24`                | Virtual display size |

The app reads `DB_URL` / `DB_USER` / `DB_PASSWORD` at startup (see
`Bank/src/application/Main.java`); with no env set it falls back to the
original `jdbc:mysql://localhost:3306/bank` defaults, so local (non-Docker)
runs are unaffected.

## Pointing at an external database

Set `DB_URL` (and credentials) to your server and start only the app:

```bash
DB_URL='jdbc:mysql://my-host:3306/bank' DB_HOST=my-host \
  docker compose up --build app
```
