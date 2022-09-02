package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#CentOS7: {
	ref: core.#Ref | *"centos:7"

	_img: docker.#Pull & {
		source: ref
	}

	_build: #_RpmBase & {
		prefix: "centos7"
		input:  _img.output
	}
	output: _build.output
}
