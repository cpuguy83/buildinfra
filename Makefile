export DAGGER_LOG_FORMAT ?= plain
export DAGGER_LOG_LEVEL

.PHONY: test
test: TESTPLANS = $(wildcard $(TESTDIR)/**/test/*.cue)
test:
	@for i in $$(find . -ipath '**/test/*.cue' | grep -v 'cue\.mod'); do \
		echo "Running testplan: $$i" >&2; \
		dagger do -p $${i} test; \
	done
