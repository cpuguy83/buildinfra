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
		_testData: core.#WriteFile & {
			input:    dagger.#Scratch
			path:     "/foo"
			contents: "foobar"
		}

		_baseImg: alpine.#Build & {
			packages: {
				"tar":  _
				"xz":   _
				"gzip": _
				"zstd": _
			}
		}

		#_CheckCompression: {
			contents:      dagger.#FS
			decompressCmd: string

			docker.#Run & {
				input: _baseImg.output
				mounts: {
					"/tmp/compressed/": core.#Mount & {
						"contents": contents
						dest:       "/tmp/compressed/"
					}
				}
				workdir: "/tmp/compressed"
				command: {
					"name": "/bin/sh"
					// Run this through the decompress command first just to make sure it really is compressed
					flags: "-ec": "\(decompressCmd) | tar -C /tmp -xvf -"
				}
				export: files: {
					"/tmp/foo": =~"foobar"
				}
			}
		}

		compressGzip: {
			_compress: deb.#Gzip & {
				input:    _baseImg.output
				contents: _testData.output
			}

			_check: #_CheckCompression & {
				contents:      _compress.output
				decompressCmd: "gzip -dc \(_compress.name)"
			}
		}

		compressXz: {
			_compress: deb.#Xz & {
				input:    _baseImg.output
				contents: _testData.output
			}

			_check: #_CheckCompression & {
				contents:      _compress.output
				decompressCmd: "xz -dc \(_compress.name)"
			}
		}
		compressZstd: {
			_compress: deb.#Zstd & {
				input:    _baseImg.output
				contents: _testData.output
			}

			_check: #_CheckCompression & {
				contents:      _compress.output
				decompressCmd: "zstd -dc \(_compress.name)"
			}
		}
	}
}
