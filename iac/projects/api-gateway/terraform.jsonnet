{
  terraform: { backend: { s3: {
    bucket: 'akerr-lab-tfstate',
    key: 'projects/api-gateway/terraform.tfstate',
    region: 'us-east-1',
  } } },

  provider: { aws: { region: 'us-east-1' } },

  data: { aws_iam_policy_document: {
    cloudwatch: {
      json:: '${data.aws_iam_policy_document.cloudwatch.json}',
      statement: [{
        effect: 'Allow',
        resources: ['*'],
        actions: [
          'logs:CreateLogGroup',
          'logs:CreateLogStream',
          'logs:DescribeLogGroups',
          'logs:DescribeLogStreams',
          'logs:PutLogEvents',
          'logs:GetLogEvents',
          'logs:FilterLogEvents',
        ],
      }],
    },

    cloudwatch_assume_role: {
      json:: '${data.aws_iam_policy_document.cloudwatch_assume_role.json}',
      statement: [{
        sid: '1',
        effect: 'Allow',
        principals: [{
          type: 'Service',
          identifiers: ['apigateway.amazonaws.com'],
        }],
        actions: ['sts:AssumeRole'],

      }],
    },

  } },

  resource: {

    aws_iam_role: { cloudwatch: {
      id:: '${aws_iam_role.cloudwatch.id}',
      arn:: '${aws_iam_role.cloudwatch.arn}',
      name: 'api-gateway-cloudwatch-global',
      assume_role_policy: $.data.aws_iam_policy_document.cloudwatch_assume_role.json,
    } },

    aws_iam_role_policy: { cloudwatch: {
      name: 'default',
      role: $.resource.aws_iam_role.cloudwatch.id,
      policy: $.data.aws_iam_policy_document.cloudwatch.json,
    } },

    aws_api_gateway_account: { main: {
      cloudwatch_role_arn: $.resource.aws_iam_role.cloudwatch.arn,
    } },

    aws_api_gateway_rest_api: { greeter: {
      id:: '${aws_api_gateway_rest_api.greeter.id}',
      root_resource_id:: '${aws_api_gateway_rest_api.greeter.root_resource_id}',
      execution_arn:: '${aws_api_gateway_rest_api.greeter.execution_arn}',
      name: 'greeter-api',
      description: 'An API that greets you.',
    } },

  },

  output: {

    id: {
      description: 'API Gateway ID.',
      value: $.resource.aws_api_gateway_rest_api.greeter.id,
    },

    root_resource_id: {
      description: 'API Gateway root resource ID.',
      value: $.resource.aws_api_gateway_rest_api.greeter.root_resource_id,
    },

    execution_arn: {
      description: 'API Gateway execution arn.',
      value: $.resource.aws_api_gateway_rest_api.greeter.execution_arn,
    },

  },
}
