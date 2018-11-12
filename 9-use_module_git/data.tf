data "template_file" "cloud_watch_custom_metric" {
  template = "${file("scripts/init.sh")}"

  vars {
    CRON = "${var.cloud_watch_cron}"
  }
}
