.PHONY: help create start stop shell delete mr-proper

LIMACTL := $(shell which limactl)

VM_NAME := rocky

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


create: ## Erstellt die VM mit rocky.yml
	@$(LIMACTL) create --tty=false --name=$(VM_NAME) ./rocky.yml

start: ## Startet die VM
	@$(LIMACTL) start $(VM_NAME)

stop: ## Stoppt die VM
	@$(LIMACTL) stop $(VM_NAME)

shell: ## Eini SHH tuan.
	@$(LIMACTL) shell $(VM_NAME)

delete: ## Stoppt und löscht die VM
	-@$(LIMACTL) stop -f $(VM_NAME)
	@$(LIMACTL) delete $(VM_NAME)

mr-proper: delete create start ## VM löschen, neu anlegen und starten.
