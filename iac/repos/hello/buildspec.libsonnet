{
  version: '0.2',
  phases: {
    install: {
      'runtime-versions': {
        golang: '1.13',
      },
    },
    pre_build: {
      commands: [
        'cd $${CODEBUILD_SRC_DIR}',
        'ls',
        'make test',
      ],
    },
  },
}
