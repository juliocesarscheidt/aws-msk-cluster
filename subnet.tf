data "aws_availability_zones" "available_azs" {
  state = "available"
}

######## PUBLIC SUBNET ########
resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available_azs.names)
  cidr_block              = cidrsubnet(aws_vpc.vpc_0.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  vpc_id                  = aws_vpc.vpc_0.id
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index}"
  }
  depends_on = [aws_vpc.vpc_0]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_0.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "public_route_table"
  }
  depends_on = [aws_internet_gateway.internet_gw]
}

resource "aws_route_table_association" "assoc_route_public" {
  count          = length(data.aws_availability_zones.available_azs.names)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_subnet.public_subnet, aws_route_table.public_route_table]
}

# change the main route
resource "aws_main_route_table_association" "assoc_main_route" {
  vpc_id         = aws_vpc.vpc_0.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_vpc.vpc_0, aws_route_table.public_route_table]
}
