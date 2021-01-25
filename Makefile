
TERRAFORM_VERSION=0.14.5

define trrfrm
	@docker run -i -t --rm 								\
			--net=host 									\
			--user ${id -u}:${id -g} 					\
			-v ${HOME}/.ssh:/root/.ssh					\
			-v ${PWD}:/app 								\
			-w /app 									\
			-e DIGITALOCEAN_TOKEN=${DIGITALOCEAN_TOKEN} \
			hashicorp/terraform:${TERRAFORM_VERSION}
endef

init:
	$(trrfrm) init -input=false

validate: init
	$(trrfrm) validate

refresh: init
	$(trrfrm) refresh

whats-up: refresh
	$(trrfrm) show

it: refresh
	$(trrfrm) plan -input=false -out=thats_the_plan
	$(trrfrm) apply -input=false "thats_the_plan"
