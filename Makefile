DEFAULT := generate

generate: terraform-generate

validate: terraform-validate

clean: terraform-clean

.PHONY: terraform-generate
terraform-generate:
	scripts/terraform/generate.sh

.PHONY: terraform-validate
terraform-validate:
	scripts/terraform/validate.sh

.PHONY: terraform-clean
terraform-clean:
	scripts/terraform/clean.sh

