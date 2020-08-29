###################
# PARAMETRIZACOES #
###################

.DEFAULT_GOAL := help

SHELL := /bin/bash
CONTEXT = "Gostgres Processes"

NO_COLOR=\x1b[0m
GREEN_COLOR=\x1b[32;01m
RED_COLOR=\x1b[31;01m
ORANGE_COLOR=\x1b[33;01m

OK_STRING=$(GREEN_COLOR)[OK]$(NO_COLOR)
ERROR_STRING=$(RED_COLOR)[ERRORS]$(NO_COLOR)
WARN_STRING=$(ORANGE_COLOR)[WARNINGS]$(NO_COLOR)


#############
# FUNCTIONS #
#############

define critical_question
    echo -e "\t$(RED_COLOR)$(1)$(NO_COLOR) "
		while true; do \
	    read -p '          Informe: (y/n)' yn ; \
	    case $$yn in  \
	        y|Y ) echo -e "              $(GREEN_COLOR)Continuando...$(NO_COLOR)"; break ;; \
	        n|N ) echo -e "              Ok... $(RED_COLOR)saindo, cancelando, desistindo....$(NO_COLOR)"; sleep 2; exit 255 ;; \
	        * ) echo "              Por favor, escolha y ou n." ;; \
	     esac ; \
	  done
endef
define msg_critical
    echo -e "$(RED_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define msg_warn
    echo -e "$(ORANGE_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define msg_ok
    echo -e "$(GREEN_COLOR)-->[$(1)]$(NO_COLOR)\n"
endef

define menu
    echo -e "$(GREEN_COLOR)[$(1)]$(NO_COLOR)"
endef


###########################
# INTERNO PARA O MAKE.... #
###########################
.PHONY: clear_screen
clear_screen:
	@clear

.PHONY: quit
sair:
	@clear

###############
# FERRAMENTAS #
###############
.PHONY: db_init
db_init: ## Start postgres database
		@docker-compose up -d --build --remove-orphans

.PHONY: db_stop
db_stop: ## Stop database container
		@docker-compose down --no-orphans

.PHONY: db_prune
db_prune: ## Remove database's container and volume
		@docker-compose rm -fsv
		@sudo rm -rf /tmp/pgdata

.PHONY: run
run: ## Run application
		@go run ./main.go

#######################
## tools - MENU MAKE ##
#######################
.PHONY: help
help: clear_screen
	@$(call menu, "============== $(CONTEXT) ==============")
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36m%-30s\033[0m %s\n", $$1, $$2}'
