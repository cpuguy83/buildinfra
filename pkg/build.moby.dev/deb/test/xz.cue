package deb

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/deb"
	"universe.dagger.io/docker"
	"universe.dagger.io/alpine"
)

dagger.#Plan & {
	actions: test: {
		compressXz: {
			_testData: core.#WriteFile & {
				input:    dagger.#Scratch
				path:     "/foo"
				contents: "foobar"
			}

			_compress: deb.#Xz & {
				contents: _testData.output
			}

			_img: alpine.#Build & {
				packages: {
					xz: _
				}
			}
			docker.#Run & {
				input: _img.output
				mounts: {
					"/tmp/compressed/": core.#Mount & {
						contents: _compress.output
						dest:     "/tmp/compressed/"
					}
				}
				workdir: "/tmp/compressed"
				command: {
					name: "/bin/sh"
					// Run this through xz first just to make sure it really is xz
					flags: "-ec": "xz -d -c \(_compress.name) | tar -C /tmp -xvf -"
				}
				export: files: {
					"/tmp/foo": =~"foobar"
				}
			}
		}
	}
}
