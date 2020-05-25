#  Generates a nvidia enabled desktop machine in Azure 
#  make test : runs all tests available 
#  make bats : runs all bash tests available in scripts/test
#  

# Directory containing scripts
scripts := scripts

# Directory containing bats source
bats := $(wildcard $(scripts)/test/*.bats)

all: test packer-build

test: bats packer-validate

bats:
	scripts/test/libs/bats/bin/bats $(bats)

packer-validate:
	packer validate packer/linux-template.json

install:
	packer build packer/linux-template.json

terraform-init:
	cd tf && terraform init

terraform-validate:
	cd tf && terraform validate 


terraform: terraform-validate
	cd tf && terraform apply

deploy: terraform 	`
