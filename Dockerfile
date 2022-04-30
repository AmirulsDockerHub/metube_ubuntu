FROM ubuntu:latest as builder

WORKDIR /metube
COPY ui ./
RUN apt update -y && apt upgrade -y && apt install git python3 python3-pip nodejs npm -y && npm ci && node_modules/.bin/ng build --prod


FROM ubuntu:latest

WORKDIR /app

COPY Pipfile* ./

RUN apt update -y && apt upgrade -y && apt install git python3 python3-pip nodejs npm ffmpeg -y

RUN apt-get update -y && apt-get upgrade -y && apt-get gcc g++ -y && \
    pip install --no-cache-dir pipenv && \
    pipenv install --system --deploy --clear && \
    pip uninstall pipenv -y && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/*

COPY favicon ./favicon
COPY app ./app
COPY --from=builder /metube/dist/metube ./ui/dist/metube

ENV DOWNLOAD_DIR /downloads
ENV STATE_DIR /downloads/.metube
VOLUME /downloads
EXPOSE 8081
CMD ["python3", "app/main.py"]
