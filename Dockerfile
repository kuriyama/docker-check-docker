FROM alpine:3.23

RUN apk add --no-cache \
        docker-cli \
        python3 \
        py3-pip \
    && python3 -m venv /opt/check-docker \
    && /opt/check-docker/bin/pip install \
        --no-cache-dir \
        check-docker \
    && { \
        echo '### APK'; \
        apk info -vv | sort; \
        echo '### PIP'; \
        /opt/check-docker/bin/pip freeze --all | sort; \
    } > /usr/local/share/image-packages.txt

ENV PATH="/opt/check-docker/bin:${PATH}"
