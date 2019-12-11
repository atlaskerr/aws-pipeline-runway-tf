{
  version: '0.2',
  artifacts: {
    files: ['$${CODEBUILD_SRC_DIR}/build/main.zip'],
  },
  phases: {
    install: {
      'runtime-versions': {
        golang: '1.13',
      },
    },
    pre_build: {
      commands: [
        'pwd',
        'cd $${CODEBUILD_SRC_DIR}',
        'make test',
      ],
    },
    build: {
      commands: [
        'pwd',
        'cd $${CODEBUILD_SRC_DIR}',
        'make build',
        'make bundle',
      ],
    },
  },
}
