# ---------------------------------------------------------------------------
# Ensah Bank - JavaFX desktop app, containerized.
#
# JavaFX is a GUI toolkit with no headless mode, so the container runs the app
# against a virtual X display (Xvfb) and exposes it two ways:
#   * noVNC in a browser  -> http://localhost:6080/vnc.html
#   * a raw VNC client    -> localhost:5900
#
# JavaFX itself comes from the BellSoft Liberica "Full" JDK, which bundles
# JavaFX for both linux/amd64 and linux/arm64 (Gluon/Maven Central publish no
# linux-aarch64 JavaFX build), so the image builds natively on either arch.
#
# The MySQL connection is configured entirely through environment variables
# (see docker-compose.yml / .env.example) - no source changes needed.
# ---------------------------------------------------------------------------
FROM ubuntu:22.04

ARG JDK_VERSION=21.0.5+11
ARG CONNECTOR_VERSION=8.4.0
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/opt/jdk \
    PATH=/opt/jdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# GUI stack (Xvfb + x11vnc + noVNC) and the native libs JavaFX needs to render.
RUN apt-get update && apt-get install -y --no-install-recommends \
        xvfb x11vnc novnc websockify x11-utils \
        libgtk-3-0 libglu1-mesa libgl1-mesa-glx libxtst6 libxrender1 libxi6 \
        libxext6 libasound2 libfreetype6 fontconfig fonts-dejavu-core \
        curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Liberica "Full" JDK (bundles JavaFX) + the MySQL JDBC driver, arch-matched.
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
        amd64) ljarch=amd64 ;; \
        arm64) ljarch=aarch64 ;; \
        *) echo "unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/jdk.tar.gz \
        "https://download.bell-sw.com/java/${JDK_VERSION}/bellsoft-jdk${JDK_VERSION}-linux-${ljarch}-full.tar.gz"; \
    mkdir -p /opt/jdk; \
    tar -xzf /tmp/jdk.tar.gz -C /opt/jdk --strip-components=1; \
    rm /tmp/jdk.tar.gz; \
    curl -fsSL -o /opt/mysql-connector-j.jar \
        "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${CONNECTOR_VERSION}/mysql-connector-j-${CONNECTOR_VERSION}.jar"

WORKDIR /app

# Compile the application and stage its FXML/CSS/image resources next to the classes.
COPY Bank/src/application ./src/application
RUN javac --add-modules javafx.controls,javafx.fxml \
        -cp /opt/mysql-connector-j.jar -d /app/bin src/application/*.java \
    && cp src/application/*.fxml src/application/*.css src/application/*.png /app/bin/application/

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# DB connection (consumed by Main.java) + display/VNC settings.
ENV DB_URL="jdbc:mysql://db:3306/bank" \
    DB_USER="root" \
    DB_PASSWORD="" \
    DB_HOST="db" \
    DB_PORT="3306" \
    DISPLAY=":99" \
    SCREEN_GEOMETRY="1024x768x24" \
    VNC_PORT="5900" \
    NOVNC_PORT="6080"

EXPOSE 6080 5900

ENTRYPOINT ["/entrypoint.sh"]
