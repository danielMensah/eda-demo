lint.terraform:
	terraform -chdir=terraform fmt -recursive -check

lint.terraform.fix:
	terraform -chdir=terraform fmt -recursive

lint: lint.terraform lint.terraform.fix

build:
	GOOS=linux GOARCH=amd64 go build -o ./terraform/.bin/lambdas/part1/bootstrap ./cmd/lambdas/part1
	GOOS=linux GOARCH=amd64 go build -o ./terraform/.bin/lambdas/part2/bootstrap ./cmd/lambdas/part2
	GOOS=linux GOARCH=amd64 go build -o ./terraform/.bin/lambdas/part3/bootstrap ./cmd/lambdas/part3

terraform.get:
	terraform -chdir=terraform get

terraform.plan: build
	terraform -chdir=terraform plan

terraform.apply: build
	terraform -chdir=terraform apply

deploy: mock lint test terraform.apply