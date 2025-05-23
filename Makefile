.PHONY: help create start stop shell delete mr-proper

UVX		:= $(shell which uvx)
LIMACTL := $(shell which limactl)

VM_NAME 	:= rocky
IMAGE_NAME 	:= Rocky-9-GenericCloud.latest.aarch64.qcow2
IMAGE_URL 	:= https://download.rockylinux.org/pub/rocky/9/images/aarch64/$(IMAGE_NAME)
PROJECT_DIR := $(shell pwd)

# define standard colors
BLACK        := $(shell tput -Txterm setaf 0)
RED          := $(shell tput -Txterm setaf 1)
GREEN        := $(shell tput -Txterm setaf 2)
YELLOW       := $(shell tput -Txterm setaf 3)
LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
PURPLE       := $(shell tput -Txterm setaf 5)
BLUE         := $(shell tput -Txterm setaf 6)
WHITE        := $(shell tput -Txterm setaf 7)
RESET        := $(shell tput -Txterm sgr0)

help:
	@echo ""
	@echo    "${RED}                        Infra Podman Quadlet Development                        ${RESET}"
	@echo "${YELLOW}--------------------------------------------------------------------------------${RESET}"
	@grep -E '^[a-z-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-30s${RESET} %s\n", $$1, $$2}'
	@echo "${YELLOW}--------------------------------------------------------------------------------${RESET}"

fetch-image: image/$(IMAGE_NAME) ## Image für VM runterladen

create: fetch-image ## Erstellt die VM mit rocky.yml
	@echo "${GREEN}🛠️ Creating VM $(VM_NAME)${RESET}"
	$(LIMACTL) create --tty=false --name=$(VM_NAME) \
	./rocky.yml

start: ## Startet die VM
	@echo "${GREEN}🚀 Starting VM $(VM_NAME)${RESET}"
	@$(LIMACTL) start $(VM_NAME)

stop: ## Stoppt die VM
	@echo "${GREEN}🚫 Stopping VM $(VM_NAME)${RESET}"
	@$(LIMACTL) stop $(VM_NAME)

shell: ## Eini SHH tuan.
	@$(LIMACTL) shell $(VM_NAME)

delete: ## Stoppt und löscht die VM
	@echo "${GREEN}💣 Deleting VM  $(VM_NAME)${RESET}"
	-@$(LIMACTL) stop -f $(VM_NAME)
	@$(LIMACTL) delete $(VM_NAME)

mr-proper: delete create start ## VM löschen, neu anlegen und starten.

serve-docs: ## Dokumentation serve
	$(UVX) --with mkdocs-material mkdocs serve -a localhost:8080


image/$(IMAGE_NAME):
	@mkdir -p images
	@test -f images/$(IMAGE_NAME) || { \
  		echo "${YELLOW}📦 Fetching image ...${RESET}"; \
		curl -o images/$(IMAGE_NAME) -L $(IMAGE_URL); \
  		echo "${green}✅ Image downloaded.${RESET}"; \
	}
