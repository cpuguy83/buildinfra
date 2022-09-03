package deb

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"github.com/cpuguy83/buildinfra/pkg/build.moby.dev/deb"
	"universe.dagger.io/docker"
)

dagger.#Plan & {
	actions: test: {
		compressXz: {
			_testData: core.#WriteFile & {
				input:    dagger.#Scratch
				path:     "/foo"
				contents: "foobar"
			}

			_compressor: deb.#Xz & {}

			_set: core.#Set & {
				input:  _compressor.output.config
				config: core.#ImageConfig & {
					env: {
						input.env
						SOURCE: "/tmp/compress"
						DEST:   "/tmp/test.tar.\(_compressor.suffix)"
					}
				}
			}

			_compress: docker.#Run & {
				input: docker.#Image & {
					rootfs: _compressor.output.rootfs
					config: _set.output
				}
				mounts: "/tmp/compress": core.#Mount & {
					dest:     _set.config.env.SOURCE
					contents: _testData.output
				}
			}

			_config: core.#Set & {
				input:  _compressor.output.config
				config: core.#ImageConfig & {
					entrypoint: []
					cmd: []
				}
			}

			docker.#Run & {
				input: docker.#Image & {
					rootfs: _compress.output.rootfs
					config: _config.output
				}
				command: {
					name: "/bin/sh"
					// Run this through xz first just to make sure it really is xz
					flags: "-ec": "xz -d -c \(_set.config.env.DEST) | tar -C /tmp -xvf -"
				}
				export: files: {
					"/tmp/foo": =~"foobar"
				}
			}
		}
	}
}
