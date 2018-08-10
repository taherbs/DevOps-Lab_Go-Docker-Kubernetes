FROM golang:1.8

MAINTAINER TAHERBS

ENV DEBIAN_FRONTEND noninteractive

# -------- #
#  SET UP  #
# -------- #

RUN 	 mkdir -p /app
WORKDIR  /app
COPY     ./code /app
RUN      export GOPATH="/app" && \
		 go build -o ./calc_server_add ./calc_server_add.go && \
		 go build -o ./src/calc_util/calc_util ./src/calc_util/calc_util.go 
CMD 	 ["/bin/sh","-c","./calc_server_add -port 8081 -squareServerUrl http://$SQUAREHOST:$SQUAREPORT/compute/square"]

# ---------------- #
#   Expose Ports   #
# ---------------- #

# calc_server_add port
EXPOSE 8081
