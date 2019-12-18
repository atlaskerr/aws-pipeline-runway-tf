local new_subnet(
  name=error 'subnet name not defined',
  cidr=error 'subnet cidr not defined',
  az=error 'subnet availability zone not defined',
  public=false,
      ) = {
  name: name,
  cidr: cidr,
  az: az,
  is_public: public,
};

[
  new_subnet('public_a', '10.55.1.0/24', 'a', true),
  new_subnet('foo_a', '10.55.2.0/24', 'a'),
  new_subnet('bar_a', '10.55.3.0/24', 'a'),
  new_subnet('baz_a', '10.55.4.0/24', 'a'),
]
