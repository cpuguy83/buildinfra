package main

import (
	"dagger.io/dagger"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/runc"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/targets"
)

dagger.#Plan & {
	client: {
		filesystem: {
			for id, kind in targets.Targets {
				if kind == targets.Linux {
					"bundles/runc/\(id)": write: contents: actions.build[id].output
				}
			}
		}
	}

	actions: {
		build: {
			for id, kind in targets.Targets {
				if kind == targets.Linux {
					"\(id)": {
						_base: targets.#Base & {
							goRef:  "golang:1.18"
							target: targets.#Target & {
								"id": id
							}
						}
						_build: runc.#Build & {
							input: _base.output
							src:   runc.#Source
						}
						output: _build.output
					}
				}
			}
		}
	}
}
