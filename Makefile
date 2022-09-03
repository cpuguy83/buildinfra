export DAGGER_LOG_FORMAT ?= plain
export DAGGER_LOG_LEVEL

TESTDIR ?= pkg/build.moby.dev

.PHONY: test
test: TESTPLANS = $(wildcard $(TESTDIR)/**/test/*.cue)
test:
	@for i in $(TESTPLANS); do \
		dagger do -p $${i} test; \
	done
