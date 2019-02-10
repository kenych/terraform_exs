resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id   = "${var.destination_vpc_id}"
  vpc_id        = "${var.source_vpc_id}"
  auto_accept   = "${var.auto_accept}"

  tags {
    Name = "peering with ${var.destination_vpc_id}"
  }
}

data "aws_vpc_peering_connection" "peering_connection" {
  id = "${aws_vpc_peering_connection.vpc_peering.id}"
}

data "aws_route_table" "source_route_table" {
  count     = "${length(var.source_subnets)}"
  subnet_id = "${element(var.source_subnets, count.index)}"
}

resource "aws_route" "source_routes" {
  count                     = "${length(var.source_subnets)}"
  route_table_id            = "${element(data.aws_route_table.source_route_table.*.route_table_id, count.index)}"
  destination_cidr_block    = "${data.aws_vpc_peering_connection.peering_connection.peer_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
}

data "aws_route_table" "destination_route_table" {
  count     = "${length(var.destination_subnets)}"
  subnet_id = "${element(var.destination_subnets, count.index)}"
}

resource "aws_route" "destination_routes" {
  count                     = "${length(var.destination_subnets)}"
  route_table_id            = "${element(data.aws_route_table.destination_route_table.*.route_table_id, count.index)}"
  destination_cidr_block    = "${data.aws_vpc_peering_connection.peering_connection.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
}

