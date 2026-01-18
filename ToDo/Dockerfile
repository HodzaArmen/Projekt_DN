# ═══════════════════════════════════════════════════════════
# STAGE 1: BUILDER 
# 
# KAJ: Uporabimo Python 3.12 slim image za build
# ZAKAJ:  Potrebujemo build tools (gcc, make, itd) za kompajlanje Python packages
#        Ampak te toole NE potrebujemo v runtime - samo zavzamejo prostor
# ═══════════════════════════════════════════════════════════
FROM python:3.12-slim AS builder

WORKDIR /app

# Namestimo build dependencies (gcc, etc)
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

# Kopirajmo requirements in instalirajmo v /install prefix
# --mount=type=cache :  Docker BuildKit cache - hitrejši rebuildi
# --prefix=/install  : Instalira v /install namesto /usr/local
COPY requirements.txt . 
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --prefix=/install --no-cache-dir -r requirements.txt

# ═══════════════════════════════════════════════════════════
# STAGE 2: RUNTIME
# 
# KAJ: Uporabimo ALPINE (manjši image)
# ZAKAJ: slim je ~100MB, alpine je ~50MB
#        Alpine je minimalistična Linux distribucija
#        SECURITY:  Manj kode = manj attack surface
# ═══════════════════════════════════════════════════════════
FROM python:3.12-alpine AS runtime

WORKDIR /app

# ═══════════════════════════════════════════════════════════
# KAJ: Dodamo Tini init system
# ZAKAJ:  Containerji ne morajo pravilno handle-ati signals (SIGTERM, SIGINT)
#        Tini je mini init system ki to popravi
#        REZULTAT: Graceful shutdowns, no zombie processes
# ═══════════════════════════════════════════════════════════
RUN apk add --no-cache tini

# ═══════════════════════════════════════════════════════════
# KAJ: Ustvarimo non-root user "appuser" z UID/GID 1000
# ZAKAJ:  SECURITY!  Nikoli ne poženi containerja kot root! 
#        Če napadalec escapa iz containerja, ne bo imel root privileges
#        
#        addgroup -g 1000  :  Ustvari grupo z GID 1000
#        adduser -D -u 1000: Ustvari userja z UID 1000, brez passworda (-D)
# ═══════════════════════════════════════════════════════════
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# ═══════════════════════════════════════════════════════════
# KAJ: Kopirajmo samo INSTALLED packages iz builder stage
# ZAKAJ:  Ne potrebujemo build tools (gcc, etc) v runtime!
#        REZULTAT: Manjši image (~50% manj)
# ═══════════════════════════════════════════════════════════
COPY --from=builder /install /usr/local

# ═══════════════════════════════════════════════════════════
# KAJ:  Kopirajmo aplikacijsko kodo
# ZAKAJ: To je naša Flask app
#        --chown=appuser:appuser :  Datoteke pripadajo appuser (ne root!)
# ═══════════════════════════════════════════════════════════
COPY --chown=appuser:appuser app.py . 
COPY --chown=appuser:appuser templates templates/

# ═══════════════════════════════════════════════════════════
# KAJ:  Ustvarimo /app/data direktorij za SQLite
# ZAKAJ: Flask app shranjuje SQLite bazo v /app/data/tasks.db
#        appuser mora imeti write permissions!
# ═══════════════════════════════════════════════════════════
RUN mkdir -p /app/data && chown -R appuser:appuser /app

# ═══════════════════════════════════════════════════════════
# KAJ:  Switch na non-root user
# ZAKAJ: Vse od tu naprej se izvaja kot appuser (ne root)
# ═══════════════════════════════════════════════════════════
USER appuser

EXPOSE 5000

# ═══════════════════════════════════════════════════════════
# KAJ:  Uporabimo Tini kot entrypoint
# ZAKAJ:  Tini bo PID 1, Python bo child process
#        REZULTAT: Proper signal handling
# ═══════════════════════════════════════════════════════════
ENTRYPOINT ["/sbin/tini", "--"]

CMD ["python", "app.py"]
