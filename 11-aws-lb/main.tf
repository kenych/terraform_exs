

module "aws_lb_test1" {
  source = "./modules/lb"
  internal = true
  name = "hello1"

}

module "aws_lb_test2" {
  source = "./modules/lb"
  internal = false
  eip = "eipalloc-01bb0d0331c39d9f7"
  name = "hello2"
}