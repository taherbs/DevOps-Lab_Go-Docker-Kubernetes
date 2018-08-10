FROM golang:1.8

MAINTAINER TAHERBS

ENV DEBIAN_FRONTEND noninteractive

# -------- #
#  SET UP  #
# -------- #

RUN 	 mkdir -p /app
WORKDIR  /app
COPY     ./code /app
RUN		 export GOPATH="/app" && \
		 go build -o ./calc_server_square ./calc_server_square.go && \
		 go build -o ./src/calc_util/calc_util ./src/calc_util/calc_util.go
CMD 	 ["/bin/sh","-c","./calc_server_square -port 8080"]

# ---------------- #
#   Expose Ports   #
# ---------------- #

# calc_server_square port
EXPOSE 8080
