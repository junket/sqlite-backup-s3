FROM alpine:latest
ARG TARGETARCH

RUN apk add bash
ADD src/install.sh install.sh
RUN bash install.sh && rm install.sh

ENV SQLITE_DATABASE_DIRECTORY ''
ENV AWS_ACCESS_KEY_ID ''
ENV AWS_SECRET_ACCESS_KEY ''
ENV S3_BUCKET ''
ENV AWS_REGION 'us-east-1'
ENV S3_PATH '/backup'
ENV S3_ENDPOINT ''
ENV S3_S3V4 'no'
ENV SCHEDULE ''
ENV PASSPHRASE ''
ENV BACKUP_KEEP_DAYS ''

ADD src/run.sh run.sh
ADD src/env.sh env.sh
ADD src/backup.sh backup.sh

CMD ["bash", "run.sh"]
