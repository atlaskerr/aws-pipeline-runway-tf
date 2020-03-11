local openapi = import 'openapi/openapi.libsonnet';

{
  AWSTemplateFormatVersion: '2010-09-09',
  Resources: {
    ApiGateway: {
      Type: 'AWS::ApiGateway::RestApi',
      Properties: {
        Body: openapi,
      },
    },
  },

  Outputs: {
    ApiGatewayId: {
      Description: '',
      Value: { Ref: 'ApiGateway' },
    },
  },

}
