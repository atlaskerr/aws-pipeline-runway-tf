{
  terraform: { backend: { s3: {
    bucket: 'akerr-lab-tfstate',
    key: 'projects/api-gateway/terraform.tfstate',
    region: 'us-east-1',
  } } },

  provider: { aws: { region: 'us-east-1' } },

  resource: { aws_api_gateway_rest_api: { greeter: {
    id:: '${aws_api_gateway_rest_api.greeter.id}',
    root_resource_id:: '${aws_api_gateway_rest_api.greeter.root_resource_id}',
    name: 'greeter-api',
    description: 'An API that greets you.',
  } } },

  output: {

    id: {
      description: 'API Gateway ID.',
      value: $.resource.aws_api_gateway_rest_api.greeter.id,
    },

    root_resource_id: {
      description: 'API Gateway root resource ID.',
      value: $.resource.aws_api_gateway_rest_api.greeter.root_resource_id,
    },

  },
}
