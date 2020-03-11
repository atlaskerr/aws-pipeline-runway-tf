local resources = [
  {
    path:: '/hello',
    get: {
      'x-amazon-apigateway-integration': {
        httpMethod: 'GET',
        type: 'aws_proxy',
        uri: {
          'Fn::Sub':
          'arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${LambdaHelloArn}/invocations',
        },
        responses: {},
      },
    },
  },
];

{
  swagger: '2.0',
  info: {
    version: '1.0',
    title: 'Greeter API',
  },
  paths: {
    [resource.path]: resource
    for resource in resources
  },
}
