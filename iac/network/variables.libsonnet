{

  vpc: {
    resource: '${aws_vpc.main}',
    id: '${aws_vpc.main.id}',
  },

  subnets: {
    public: {
      resource:: '${aws_subnet.public}',
    },
  },

}
