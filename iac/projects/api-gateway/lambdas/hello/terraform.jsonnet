{
  terraform: { backend: {
    s3: {
      bucket: 'akerr-lab-tfstate',
      key: 'projects/api-gateway/lambdas/hello/terraform.tfstate',
      region: 'us-east-1',
    },
  } },

  provider: { aws: { region: 'us-east-1' } },

  data: {
    aws_iam_policy_document: {

      lambda_assume_role: {
        json:: '${data.aws_iam_policy_document.lambda_assume_role.json}',
        statement: [
          {
            sid: '1',
            effect: 'Allow',
            actions: ['sts:AssumeRole'],
            principals: [{
              type: 'Service',
              identifiers: ['lambda.amazonaws.com'],
            }],
          },
        ],
      },

      //lambda_policy: {
      //  json:: '${aws_iam_policy_document.lambda_policy.json}',
      //},

    },
  },
  resource: {

    aws_iam_role: {
      lambda: {
        arn:: '${aws_iam_role.lambda.arn}',
        name: 'akerr-lab-lambda',
        assume_role_policy:
          $.data.aws_iam_policy_document.lambda_assume_role.json,
      },
    },

    aws_lambda_function: {
      hello: {
        function_name: 'akerr-lab-hello',
        description: 'Test lambda that says hello.',
        memory_size: '128',
        filename: 'main.zip',
        source_code_hash: '${filebase64sha256("main.zip")}',
        runtime: 'go1.x',
        timeout: '3',
        publish: true,
        handler: 'main',
        role: $.resource.aws_iam_role.lambda.arn,
      },
    },

  },

}
