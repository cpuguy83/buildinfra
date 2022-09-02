package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#RHEL8: {
	ref: core.#Ref | *"almalinux:8"

	_img: docker.#Pull & {
		source: ref
	}

	_build: #_RpmBase & {
		prefix: "rhel8"
		input:  _img.output
	}
	output: _build.output
}
