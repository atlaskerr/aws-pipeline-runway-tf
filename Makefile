DEFAULT := build

build: terraform-generate go-build

validate: terraform-validate

clean: terraform-clean go-clean

.PHONY: terraform-generate
terraform-generate:
	scripts/terraform/generate.sh

.PHONY: terraform-validate
terraform-validate:
	scripts/terraform/validate.sh

.PHONY: terraform-clean
terraform-clean:
	scripts/terraform/clean.sh

.PHONY: go-build
go-build:
	scripts/go/build.sh

.PHONY: go-clean
go-clean:
	scripts/go/clean.sh

.PHONY: go-test
go-test:
	go test ./...
