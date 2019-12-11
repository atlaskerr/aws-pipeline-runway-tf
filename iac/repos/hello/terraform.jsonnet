local pipeline = import 'pipelines.libsonnet';

{
  terraform: {
    backend: {
      s3: {
        bucket: 'akerr-lab-tfstate',
        key: 'repos/hello/terraform.tfstate',
        region: 'us-east-1',
      },
    },
  },

  provider: { aws: { region: 'us-east-1' } },

  data: {
    aws_iam_policy_document: {

      codebuild_policy: {
        statement: [
          {
            effect: 'Allow',
            resources: [
              '${aws_cloudwatch_log_group.hello_codebuild.arn}',
              '${aws_cloudwatch_log_stream.codebuild.arn}',
            ],
            actions: [
              'logs:CreateLogGroup',
              'logs:CreateLogStream',
              'logs:PutLogEvents',
            ],
          },
          {
            effect: 'Allow',
            resources: [
              '${aws_s3_bucket.pipeline.arn}',
              '${aws_s3_bucket.pipeline.arn}/*',
            ],
            actions: [
              's3:PutObject',
              's3:GetObject',
              's3:GetObjectVersion',
            ],
          },
        ],
      },

      codepipeline_policy: {
        statement: [

          {
            effect: 'Allow',
            resources: [
              '${aws_cloudwatch_log_group.hello_codebuild.arn}',
              '${aws_cloudwatch_log_group.hello_codebuild.arn}/*',
            ],
            actions: [
              's3:PutBucketPolicy',
              's3:PutObject',
            ],
          },

          {
            effect: 'Allow',
            resources: ['${aws_codecommit_repository.main.arn}'],
            actions: [
              'codecommit:GetBranch',
              'codecommit:GetCommit',
              'codecommit:UploadArchive',
              'codecommit:GetUploadArchiveStatus',
              'codecommit:CancelUploadArchive',
            ],
          },

          {
            effect: 'Allow',
            resources: ['${aws_codebuild_project.test_go_code.arn}'],
            actions: [
              'codebuild:StartBuild',
              'codebuild:BatchGetBuilds',
            ],
          },

          {
            effect: 'Allow',
            resources: [
              '${aws_s3_bucket.pipeline.arn}',
              '${aws_s3_bucket.pipeline.arn}/*',
            ],
            actions: [
              's3:PutObject',
              's3:GetObject',
              's3:GetObjectVersion',
            ],
          },

        ],
      },

      codedeploy_policy: {
        statement: [

          {
            effect: 'Allow',
            resources: [
              '${aws_s3_bucket.pipeline.arn}',
              '${aws_s3_bucket.pipeline.arn}/*',
            ],
            actions: [
              's3:PutObject',
              's3:GetObject',
              's3:GetObjectVersion',
            ],
          },

        ],
      },

      codepipeline_assume_role: {
        statement: {
          sid: '1',
          effect: 'Allow',
          principals: [{
            type: 'Service',
            identifiers: ['codepipeline.amazonaws.com'],
          }],

          actions: ['sts:AssumeRole'],
        },
      },

      codebuild_assume_role: {
        statement: {
          sid: '1',
          effect: 'Allow',

          principals: [{
            type: 'Service',
            identifiers: ['codebuild.amazonaws.com'],
          }],

          actions: ['sts:AssumeRole'],
        },
      },

      codedeploy_assume_role: {
        statement: {
          sid: '1',
          effect: 'Allow',

          principals: [{
            type: 'Service',
            identifiers: ['codedeploy.amazonaws.com'],
          }],

          actions: ['sts:AssumeRole'],
        },
      },

    },
  },

  resource: {

    aws_codecommit_repository: { main: {
      repository_name: 'hello',
      description: 'sample lambda hello app.',
    } },

    aws_iam_role: {
      codebuild_role: {
        name: 'akerr-lab-codebuild-hello',
        assume_role_policy:
          '${data.aws_iam_policy_document.codebuild_assume_role.json}',
      },
      codepipeline_role: {
        name: 'akerr-lab-codepipeline-hello',
        assume_role_policy:
          '${data.aws_iam_policy_document.codepipeline_assume_role.json}',
      },
      codedeploy_role: {
        name: 'akerr-lab-codedeploy-hello',
        assume_role_policy:
          '${data.aws_iam_policy_document.codedeploy_assume_role.json}',
      },
    },

    aws_iam_role_policy_attachment: {
      codepipeline: {
        role: '${aws_iam_role.codepipeline_role.name}',
        policy_arn: '${aws_iam_policy.codepipeline.arn}',
      },
      codebuild: {
        role: '${aws_iam_role.codebuild_role.name}',
        policy_arn: '${aws_iam_policy.codebuild.arn}',
      },
      codedeploy: {
        role: '${aws_iam_role.codedeploy_role.name}',
        policy_arn: '${aws_iam_policy.codedeploy.arn}',
      },
    },

    aws_cloudwatch_log_group: {
      hello_codebuild: {
        name: 'akerr-lab-codebuild-hello-log-group',
      },
    },

    aws_cloudwatch_log_stream: {
      codebuild: {
        name: 'akerr-lab-codebuild-hello-log-stream-01',
        log_group_name: '${aws_cloudwatch_log_group.hello_codebuild.name}',
      },
    },

    aws_iam_policy: {
      codebuild: {
        name: 'codebuild-hello',
        policy: '${data.aws_iam_policy_document.codebuild_policy.json}',
      },
      codepipeline: {
        name: 'codepipeline-hello',
        policy: '${data.aws_iam_policy_document.codepipeline_policy.json}',
      },
      codedeploy: {
        name: 'codedeploy-hello',
        policy: '${data.aws_iam_policy_document.codedeploy_policy.json}',
      },
    },

    aws_codebuild_project: {
      test_go_code: {
        name: 'akerr-lab-hello-test-gocode',
        description: 'Run go unit tests.',
        service_role: '${aws_iam_role.codebuild_role.arn}',
        build_timeout: '5',
        artifacts: { type: 'CODEPIPELINE' },
        environment: {
          compute_type: 'BUILD_GENERAL1_SMALL',
          image: 'aws/codebuild/amazonlinux2-x86_64-standard:2.0',
          type: 'LINUX_CONTAINER',
          image_pull_credentials_type: 'CODEBUILD',
        },
        source: {
          type: 'CODEPIPELINE',
          buildspec: std.manifestYamlDoc(import 'buildspec.libsonnet'),
        },
        cache: {
          type: 'S3',
          location: '${aws_s3_bucket.build_test_cache.bucket}',
        },
        logs_config: {
          cloudwatch_logs: {
            status: 'ENABLED',
            group_name: '${aws_cloudwatch_log_group.hello_codebuild.name}',
            stream_name: '${aws_cloudwatch_log_stream.codebuild.name}',
          },
        },
      },
    },

    aws_codepipeline: {
      dev: pipeline.dev,
    },

    aws_codedeploy_app: {
      hello: {
        compute_platform: 'Lambda',
        name: 'akerr-lab-hello-lambda',
      },
    },

    aws_codedeploy_deployment_config: {
      hello: {
        deployment_config_name: 'akerr-lab-hello',
        compute_platform: 'Lambda',
        traffic_routing_config: {
          type: 'AllAtOnce',
        },
      },
    },

    aws_codedeploy_deployment_group: {
      hello: {
        app_name: '${aws_codedeploy_app.hello.name}',
        deployment_group_name: 'akerr-lab-hello-deployment-group',
        deployment_config_name: '${aws_codedeploy_deployment_config.hello.id}',
        deployment_style: {
          deployment_option: 'WITH_TRAFFIC_CONTROL',
          deployment_type: 'BLUE_GREEN',
        },
        service_role_arn: '${aws_iam_role.codedeploy_role.arn}',
        auto_rollback_configuration: {
          enabled: true,
          events: ['DEPLOYMENT_STOP_ON_ALARM'],
        },
      },
    },

    aws_s3_bucket: {
      pipeline: {
        bucket: 'akerr-lab-hello-pipeline',
        acl: 'private',
      },
      build_test_cache: {
        bucket: 'akerr-lab-hello-build-test-cache',
        acl: 'private',
      },
    },

  },

}
