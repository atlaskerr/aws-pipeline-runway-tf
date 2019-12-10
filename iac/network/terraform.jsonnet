{
  terraform: {
    backend: {
      s3: {
        bucket: 'akerr-lab-tfstate',
        region: 'us-east-1',
        key: 'network/terraform.tfstate',
      },
    },
  },

  provider: {
    aws: { region: 'us-east-1' },
  },

  resource: {
    aws_vpc: {
      main: {
        cidr_block: '10.55.0.0/16',
        enable_dns_support: true,
        enable_dns_hostnames: true,
        tags: { Name: 'akerr-lab' },
      },
    },
  },

  output: {
    vpc: { value: '${aws_vpc.main.id}' },
  },
}
