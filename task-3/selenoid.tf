variable "browsers" {
  type = "list"
  default = [
    "selenoid/chrome:69.0",
    "selenoid/firefox:62.0",
    //"selenoid/opera:55.0"
  ]
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "selenoid" {
  name = "aerokube/selenoid:1.8.2"
  keep_locally = true
}

resource "docker_image" "browser_images" {
  count        = "${length(var.browsers)}"
  name         = "${element(var.browsers, count.index)}"
  keep_locally = true
}

resource "docker_container" "selenoid" {
  name    = "selenoid"
  image   = "${docker_image.selenoid.latest}"

  command = ["-limit", "4", "-timeout", "2m0s"]

  ports {
    internal = 4444
    external = 4444
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = "/Users/leonid.rudenko/selenoid/"
    container_path = "/etc/selenoid/"
  }

  upload {
    content = "{}"
    file    = "/etc/selenoid/browsers.json"
  }
}

resource "local_file" "browsers_json" {
  content  = "${file("browsers.json")}"
  filename = "/Users/leonid.rudenko/selenoid/browsers.json"

  provisioner "local-exec" {
    command = "docker kill -s HUP ${docker_container.selenoid.id}"
  }
}
