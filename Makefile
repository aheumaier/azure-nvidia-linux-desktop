#  Generates a nvidia enabled desktop machine in Azure 
#  make test : runs all tests available 
#  make bats : runs all bash tests available in scripts/test
#  

# Directory containing scripts
scripts := scripts

# Directory containing bats source
bats := $(wildcard $(scripts)/test/*.bats)


all: bats

# Recipe for converting a Markdown file into PDF using Pandoc
bats:
	./scripts/test/libs/bats/bin/bats $(bats)

