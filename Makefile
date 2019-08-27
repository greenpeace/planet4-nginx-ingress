# SHELL := /bin/bash

RELEASE := nginx-ingress
NAMESPACE := nginx-ingress

CHART_NAME := stable/nginx-ingress
CHART_VERSION ?= 1.15.1

DEV_CLUSTER ?= p4-development
DEV_PROJECT ?= planet-4-151612
DEV_ZONE ?= us-central1-a

PROD_CLUSTER ?= planet4-production
PROD_PROJECT ?= planet4-production
PROD_ZONE ?= us-central1-a

.DEFAULT_TARGET: all

all: lint connect init prod history

lint:
	@find . -type f -name '*.yml' | xargs yamllint
	@find . -type f -name '*.yaml' | xargs yamllint

dev:
# ifndef CI
# 	$(error Please commit and push, this is intended to be run in a CI environment)
# endif
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)
	helm init --client-only
	helm repo update
	helm upgrade --install --force --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		-f env/dev/values.yaml \
		$(CHART_NAME)

connect:
	gcloud config set project $(PROD_PROJECT)
	gcloud container clusters get-credentials $(PROD_CLUSTER) --zone $(PROD_ZONE) --project $(PROD_PROJECT)

init:
	helm repo update
	helm init --client-only
	helm repo update

prod:
ifndef CI
	$(error Please commit and push, this is intended to be run in a CI environment)
endif
	helm upgrade --install --force --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		-f env/prod/values.yaml \
		$(CHART_NAME)

destroy:
	helm delete --purge $(RELEASE)

history:
	helm history $(RELEASE) --max=5
