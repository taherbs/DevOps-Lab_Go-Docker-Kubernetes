export GOPATH = $(PWD)/code
servers = calc_server_sqrt calc_server_add calc_server_square
DOCKER_REPO = "taherbs"
VERSION ="latest"

###
# BAREBONE APPLICATION MAKE COMMANDS 
###

.PHONY: build_servers
build_servers:
	go build -o ./code/src/calc_util/calc_util ./code/src/calc_util/calc_util.go 
	for server in $(servers); do\
		go build -o "./code/$$server" "./code/$$server.go" ;\
	done

.PHONY: start_servers
start_servers: build_servers
	# this one returns the square of 'a'
	# ret := a
	./code/calc_server_square -port 8080 \
		2>/dev/null &
	# this one transforms 'a' and 'b' via the 8080 server then adds them up
	# ret := square(a) + square(b)
	./code/calc_server_add -port 8081 \
		-squareServerUrl 'http://localhost:8080/compute/square' \
		2>/dev/null &
	# this one transforms 'a' and 'b' via the 8081 server then takes the square root of the result
	# ret := sqrt( square(a) + square(b) )
	./code/calc_server_sqrt -port 8082 \
		-adderServerUrl 'http://localhost:8081/compute/add' \
		2>/dev/null &

.PHONY: stop_servers
stop_servers:
	@killall $(servers) || true

###
# DOCKER MAKE COMMANDS 
###

.PHONY: docker_build
docker_build:
	docker-compose build 

.PHONY: docker_start
docker_start: docker_build
	docker-compose up -d

.PHONY: docker_stop
docker_stop:
	docker-compose down

.PHONY: docker_publish
docker_publish:
	for server in $(servers); do\
		echo "publish $$server/$(VERSION) to $(DOCKER_REPO)";\
		APP_NAME="calcserver_$$server";\
		docker tag $$APP_NAME $(DOCKER_REPO)/$$APP_NAME:$(VERSION);\
		docker push $(DOCKER_REPO)/$$APP_NAME:$(VERSION);\
	done

###
# KUBERNETES MAKE COMMANDS 
###

.PHONY: kubernetes_start_minikube
kubernetes_start_minikube:
	minikube start --vm-driver=xhyve
	kubectl config current-context
	kubectl get nodes

.PHONY: kubernetes_stop_minikube
kubernetes_stop_minikube:
	minikube stop
	minikube delete

.PHONY: kubernetes_details
kubernetes_details:
	kubectl get nodes -o json
	kubectl describe pods
	kubectl get pods

.PHONY: kubernetes_status
kubernetes_status:
	kubectl get nodes
	kubectl get pods
	echo "Node internal IP: $(shell kubectl get nodes -o json | jq '.items[] | .status .addresses[] | select(.type=="InternalIP") | .address')"

.PHONY: kubernetes_start
kubernetes_start: docker_build docker_publish
	kubectl create -f ./kubernetesfiles/rc_calc_server.yml
	kubectl create -f ./kubernetesfiles/svc_calc_server.yml

.PHONY: kubernetes_stop
kubernetes_stop:
	kubectl delete -f ./kubernetesfiles/rc_calc_server.yml || true
	kubectl delete -f ./kubernetesfiles/svc_calc_server.yml || true

###
# TEST APPLICATION MAKE COMMANDS 
###

# Used to test the "barebone" and "docker" application versions
.PHONY: send_req
send_req:
	curl 'http://localhost:8082/compute/sqrt?a=30&b=40'

# Used to test the "kubernetes" application version
.PHONY: kubernetes_send_req
kubernetes_send_req:
	curl "http://$(shell kubectl get nodes -o json | jq '.items[] | .status .addresses[] | select(.type=="InternalIP") | .address'):30003/compute/sqrt?a=30&b=40"