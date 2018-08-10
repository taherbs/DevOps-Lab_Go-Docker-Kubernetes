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
		 go build -o ./calc_server_sqrt ./calc_server_sqrt.go && \
		 go build -o ./src/calc_util/calc_util ./src/calc_util/calc_util.go 
CMD 	 ["/bin/sh","-c","./calc_server_sqrt -port 8082 -adderServerUrl http://$ADDHOST:$ADDPORT/compute/add"]
# ---------------- #
#   Expose Ports   #
# ---------------- #

# calc_server_sqrt port
EXPOSE 8082
