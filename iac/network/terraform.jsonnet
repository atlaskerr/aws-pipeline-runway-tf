local subnets = import 'subnets.libsonnet';
local ref = import 'variables.libsonnet';

local tag_format(resource_name) = std.strReplace(resource_name, '_', '-');

std.prune({
  terraform: { backend: { s3: {
    bucket: 'akerr-lab-tfstate',
    region: 'us-east-1',
    key: 'network/terraform.tfstate',
  } } },

  provider: { aws: { region: 'us-east-1' } },

  resource: {

    aws_vpc: { main: {
      id:: '${aws_vpc.main.id}',
      output:: '${aws_vpc.main}',
      cidr_block: '10.55.0.0/16',
      enable_dns_support: true,
      enable_dns_hostnames: true,
      tags: { Name: 'akerr-lab-vpc' },
    } },

    aws_internet_gateway: { main: {
      id:: '${aws_internet_gateway.main.id}',
      vpc_id: $.resource.aws_vpc.main.id,
    } },

    local active_azs = std.set(std.map(function(subnet) subnet.az, subnets)),

    local azs_with_private_subnets = std.set(std.map(
      function(subnet)
        if !subnet.is_public
        then subnet.az,
      subnets
    )),

    aws_eip: {
      [if az != null then std.format('nat_%s', az)]: {
        vpc: true,
      }
      for az in azs_with_private_subnets
    },

    aws_nat_gateway: {
      [az]: {
        allocation_id: std.format('${aws_eip.nat_%s.id}', az),
        subnet_id: std.format('${aws_subnet.public_%s.id}', az),
      }
      for az in azs_with_private_subnets
    },

    aws_route: {} + {
      [std.format('%s_default', subnet.name)]: {
        destination_cidr_block: '0.0.0.0/0',
        route_table_id: std.format(
          '${aws_route_table.%s.id}', subnet.name
        ),
        [if subnet.is_public then 'gateway_id']:
          $.resource.aws_internet_gateway.main.id,
        [if !subnet.is_public then 'nat_gateway_id']: std.format(
          '${aws_nat_gateway.%s.id}', subnet.az,
        ),

      }
      for subnet in subnets
    },

    aws_route_table_association: {} + {
      [subnet.name]: {
        subnet_id: std.format('${aws_subnet.%s.id}', subnet.name),
        route_table_id: std.format('${aws_route_table.%s.id}', subnet.name),
      }
      for subnet in subnets
    },

    aws_route_table: {
      [subnet.name]: {
        vpc_id: $.resource.aws_vpc.main.id,
        tags: {
          Name: std.format('akerr-lab-rt-%s', tag_format(subnet.name)),
        },
      }
      for subnet in subnets
    },

    aws_subnet: {
      [subnet.name]: {
        vpc_id: ref.vpc.id,
        availability_zone: $.provider.aws.region + subnet.az,
        cidr_block: subnet.cidr,
        tags: { Name: std.format(
          'akerr-lab-%s', [std.strReplace(subnet.name, '_', '-')]
        ) },
        map_public_ip_on_launch: subnet.is_public,
      }
      for subnet in subnets
    },

  },

  output: {

    vpc: {
      description: 'Lab VPC resource',
      value: ref.vpc.resource,
    },
  } + {
    // subnet resource outputs.
    [std.format('subnet_%s', subnet.name)]: {
      description: std.format('Subnet %s metadata', subnet.name),
      value: std.format('${aws_subnet.%s}', subnet.name),
    }
    for subnet in subnets
  },
})
