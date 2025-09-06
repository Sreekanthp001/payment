# Stage 1: Build 
FROM python:3.9.23-alpine3.22 AS builder
WORKDIR /build 
# install build dependencies
RUN apk add --no-cache python3-dev build-base linux-headers pcre-dev
COPY requirements.txt .
RUN pip3 install --no-cache-dir --prefix=/install -r requirements.txt

# stage 2: final image
FROM python:3.9.23-alpine3.22
EXPOSE 8080
WORKDIR /opt/server
#runtime dependencies only
RUN apk add --no-cache pcre
# create app user
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop
USER roboshop
#copy installed python package from builder
COPY --from=builder /install /usr/local
#copy application code
COPY --chown=roboshop:roboshop payment.ini .
COPY --chown=roboshop:roboshop *.py .
CMD ["uwsgi", "--ini", "payment.ini"]