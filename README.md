# Ensah Bank

A JavaFX desktop banking application backed by MySQL. Customers can create an
account, sign in, manage their balance (deposit / withdraw), and apply for a
loan with a monthly repayment schedule.

## Features

- **Sign up / Sign in** — account registration and authentication against a
  MySQL database.
- **Account dashboard** — view balance and personal details.
- **Deposit & withdraw** — update the balance, with each movement recorded as
  an operation.
- **Credit / loan** — request a loan and compute the monthly repayment.

## Tech stack

- **Java** + **JavaFX** (FXML views, CSS styling)
- **MySQL** for persistence (via the MySQL JDBC connector)

## Project layout

```
Bank/src/application/   Java sources, FXML views, CSS, and image assets
  Main.java             Entry point; reads DB config and launches the GUI
  SignUp.java / Login.java / Menu.java / operation.java / creditinfo.java
docker/                 schema.sql (DB schema) and container entrypoint
docker-compose.yml      MySQL + app services
Dockerfile              App image (JavaFX on a virtual display over VNC)
DOCKER.md               Full Docker usage guide
```

The database schema lives in [`docker/schema.sql`](docker/schema.sql) — tables
for `information`, `login`, `operations`, and `credits`.

## Running with Docker (recommended)

The app is a desktop GUI, so the container runs it on a virtual X display and
streams it over VNC — no local Java or MySQL needed, only Docker.

```bash
docker compose up --build
```

Then open the app:

- **Browser (noVNC):** http://localhost:6080/vnc.html — click *Connect*
- **VNC client:** connect to `localhost:5900` (no password)

See [DOCKER.md](DOCKER.md) for configuration, external databases, and details.

## Running locally

1. Install a JDK with JavaFX and start a MySQL server.
2. Load the schema:

   ```bash
   mysql < docker/schema.sql
   ```

3. The app reads `DB_URL`, `DB_USER`, and `DB_PASSWORD` from the environment,
   falling back to `jdbc:mysql://localhost:3306/bank` as user `root` with an
   empty password (see `Bank/src/application/Main.java`). Override them if your
   setup differs, then build and run the project from your IDE (e.g. Eclipse —
   the repo includes `.classpath` / `.project`).

## Configuration

| Variable      | Default                        | Purpose                     |
|---------------|--------------------------------|-----------------------------|
| `DB_URL`      | `jdbc:mysql://localhost:3306/bank` | JDBC URL the app connects to |
| `DB_USER`     | `root`                         | Database user               |
| `DB_PASSWORD` | *(empty)*                      | Database password           |

Copy [`.env.example`](.env.example) to `.env` to override these (and the Docker
display/port settings).
