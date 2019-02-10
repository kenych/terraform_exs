resource "aws_subnet" "subnet" {
  count             = "${length(var.availability_zones)}"
  availability_zone = "${var.availability_zones[count.index]}"
  cidr_block        = "${var.cidr_blocks[count.index]}"
  vpc_id            = "${var.vpc_id}"

  tags {
    Name = "${var.component}_${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "route_table" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.route_table.*.id, count.index)}"
}

resource "aws_route_table" "route_table" {
  count  = "${length(var.availability_zones)}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.component}_${element(var.availability_zones, count.index)}"
  }
}

resource "aws_route" "public_route" {
  count                  = "${var.is_public ? length(var.availability_zones) : 0}"
  route_table_id         = "${element(aws_route_table.route_table.*.id, count.index)}"
  gateway_id             = "${var.gateway_id}"
  destination_cidr_block = "0.0.0.0/0"
}
