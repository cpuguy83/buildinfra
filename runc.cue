package main

import (
	"dagger.io/dagger"
	"universe.dagger.io/go"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/runc"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/targets"
)

let goVersion = "1.18"

dagger.#Plan & {
	client: {
		filesystem: [id=string]: {
			write: {
				contents: actions.build[id].output
				path:     "./bundles/runc/\(id)"
			}
		}
		filesystem: {
			bionic: _
			focal:  _
		}
	}

	actions: {
		build: [id=string]: {
			img:   targets.Targets[id]
			_base: go.#Configure & {
				input: img.output
				ref:   "golang:\(goVersion)"
			}
			runc.#Build & {
				input: _base.output
				src:   runc.#Source
			}
		}
		build: {
			bionic: _
			focal:  _
		}
	}
}
