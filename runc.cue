package main

import (
	"dagger.io/dagger"
	"universe.dagger.io/go"
	"universe.dagger.io/docker"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/runc"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/md2man"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/targets"
)

dagger.#Plan & {
	client: {
		env: {
			GO_VERSION:   string | *"1.18"
			RUNC_COMMIT?: string
			RUNC_TAGS?:   string
		}
		filesystem: [id=string]: {
			write: {
				contents: actions.build[id].output
				path:     "./bundles/runc/\(id)"
			}
		}
		filesystem: {
			bionic:   _
			focal:    _
			jammy:    _
			buster:   _
			bullseye: _
			centos7:  _
			rhel8:    _
			rhel9:    _
		}
	}

	actions: {
		build: [id=string]: {
			_base: docker.#Build & {
				steps: [
					targets.Targets[id],
					go.#Configure & {
						ref: "golang:\(client.env.GO_VERSION)"
					},
					md2man.#Build & {
						src: md2man.#Source
					},

				]
			}
			runc.#Build & {
				input: _base.output
				src:   runc.#Source & {
					if client.env.RUNC_COMMIT != _|_ {
						checkout: client.env.RUNC_COMMIT
					}
				}
				if client.env.RUNC_TAGS != _|_ {
					tags: [client.env.RUNC_TAGS]
				}
			}
		}

		build: {
			bionic:   _
			focal:    _
			jammy:    _
			buster:   _
			bullseye: _
			centos7:  _
			rhel8:    _
			rhel9:    _
		}
	}
}
