{
  dev: {
    name: 'lab-hello-dev-pipeline',
    role_arn: '${aws_iam_role.codepipeline_role.arn}',
    artifact_store: {
      location: '${aws_s3_bucket.pipeline.bucket}',
      type: 'S3',
    },
    stage: [
      {
        name: 'Source',
        action: [
          {
            version: '1',
            run_order: 1,
            category: 'Source',
            owner: 'AWS',
            name: 'source-code',
            provider: 'CodeCommit',
            output_artifacts: ['source-output'],
            configuration: {
              RepositoryName: 'hello',
              BranchName: 'dev',
            },
          },
        ],
      },

      {
        name: 'Test',
        action: [
          {
            version: '1',
            run_order: 2,
            category: 'Test',
            owner: 'AWS',
            name: 'app-test-gocode',
            input_artifacts: ['source-output'],
            provider: 'CodeBuild',
            configuration: {
              ProjectName: 'akerr-lab-hello-test-gocode',
            },
          },
        ],
      },

      {
        name: 'Build',
        action: [
          {
            version: '1',
            run_order: 3,
            category: 'Build',
            owner: 'AWS',
            name: 'app-build',
            input_artifacts: ['source-output'],
            output_artifacts: ['build-output'],
            provider: 'CodeBuild',
            configuration: {
              ProjectName: 'akerr-lab-hello-build-app',
            },
          },
        ],
      },

    ],
  },
}
