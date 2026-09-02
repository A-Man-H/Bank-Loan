#!/usr/bin/env bash
# Boots a virtual X display, exposes it over VNC + noVNC, waits for the
# database, then launches the JavaFX app.
set -euo pipefail

: "${DISPLAY:=:99}"
: "${SCREEN_GEOMETRY:=1024x768x24}"
: "${VNC_PORT:=5900}"
: "${NOVNC_PORT:=6080}"
: "${DB_HOST:=db}"
: "${DB_PORT:=3306}"

echo ">> Starting virtual display ${DISPLAY} (${SCREEN_GEOMETRY})"
Xvfb "${DISPLAY}" -screen 0 "${SCREEN_GEOMETRY}" -nolisten tcp &
for _ in $(seq 1 40); do
    xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 && break
    sleep 0.25
done

echo ">> Starting VNC server on :${VNC_PORT} and noVNC on :${NOVNC_PORT}"
x11vnc -display "${DISPLAY}" -forever -shared -nopw -rfbport "${VNC_PORT}" -bg -quiet
websockify --web=/usr/share/novnc "${NOVNC_PORT}" "localhost:${VNC_PORT}" >/tmp/novnc.log 2>&1 &

echo ">> Waiting for database ${DB_HOST}:${DB_PORT} ..."
for _ in $(seq 1 60); do
    if (exec 3<>"/dev/tcp/${DB_HOST}/${DB_PORT}") 2>/dev/null; then
        exec 3>&- 3<&-
        echo ">> Database is reachable."
        break
    fi
    sleep 1
done

echo ">> Open the app at: http://localhost:${NOVNC_PORT}/vnc.html (auto-connects), or VNC to localhost:${VNC_PORT}"
echo ">> Launching Ensah Bank ..."
# JavaFX modules ship inside the Liberica Full JDK, so no --module-path is needed.
# -Dprism.order=sw forces JavaFX software rendering (no GPU under Xvfb).
exec java \
    --add-modules javafx.controls,javafx.fxml \
    -Dprism.order=sw -Dprism.verbose=false -Djava.awt.headless=false \
    -cp "/app/bin:/opt/mysql-connector-j.jar" \
    application.Main
