{
  terraform: { backend: { s3: {
    bucket: 'akerr-lab-tfstate',
    key: 'projects/api-gateway/lambdas/hello/terraform.tfstate',
    region: 'us-east-1',
  } } },

  provider: { aws: { region: 'us-east-1' } },

  data: {

    terraform_remote_state: { api_gateway: {
      id:: '${data.terraform_remote_state.api_gateway.outputs.id}',
      root_resource_id::
        '${data.terraform_remote_state.api_gateway.outputs.root_resource_id}',
      backend: 's3',
      config: {
        bucket: $.terraform.backend.s3.bucket,
        key: 'projects/api-gateway/terraform.tfstate',
        region: 'us-east-1',
      },
    } },

    aws_iam_policy_document: { lambda_assume_role: {
      json:: '${data.aws_iam_policy_document.lambda_assume_role.json}',
      statement: [{
        sid: '1',
        effect: 'Allow',
        actions: ['sts:AssumeRole'],
        principals: [{
          type: 'Service',
          identifiers: ['lambda.amazonaws.com'],
        }],
      }],
    } },

  },

  resource: {

    aws_iam_role: { lambda: {
      arn:: '${aws_iam_role.lambda.arn}',
      name: 'akerr-lab-lambda',
      assume_role_policy:
        $.data.aws_iam_policy_document.lambda_assume_role.json,
    } },

    aws_lambda_function: { hello: {
      invoke_arn:: '${aws_lambda_function.hello.invoke_arn}',
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
    } },

    local api_gateway = $.data.terraform_remote_state.api_gateway,
    aws_api_gateway_resource: { hello: {
      id:: '${aws_api_gateway_resource.hello.id}',
      rest_api_id: api_gateway.id,
      parent_id: api_gateway.root_resource_id,
      path_part: 'hello',
    } },

    local api_gateway_resource = $.resource.aws_api_gateway_resource.hello,
    aws_api_gateway_method: { post: {
      http_method: 'POST',
      rest_api_id: api_gateway.id,
      resource_id: api_gateway_resource.id,
      authorization: 'NONE',
    } },

    aws_api_gateway_integration: { post: {
      rest_api_id: api_gateway.id,
      resource_id: api_gateway_resource.id,
      http_method: 'POST',
      integration_http_method: 'POST',
      type: 'AWS',
      uri: $.resource.aws_lambda_function.hello.invoke_arn,
    } },

    aws_api_gateway_deployment: { dev: {
      rest_api_id: api_gateway.id,
      stage_name: 'dev',
      depends_on: [
        'aws_api_gateway_method.post',
        'aws_api_gateway_integration.post',
      ],
    } },

  },

}
