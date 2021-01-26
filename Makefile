
TERRAFORM_VERSION=0.14.5

define trrfrm
	@docker run -i -t --rm 								\
			--net=host 									\
			--user ${id -u}:${id -g} 					\
			-v ${HOME}/.ssh/id_rsa:/root/.ssh/id_rsa:ro	\
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

destroy: refresh
	$(trrfrm) destroy -force

lets-plan: refresh
	$(trrfrm) plan -input=false -out=thats_the_plan

lets-apply: lets-plan
	$(trrfrm) apply -input=false "thats_the_plan"

it: lets-apply
