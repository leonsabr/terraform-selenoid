variable "browsers" {
  type = "list"
  default = [
    "selenoid/chrome:69.0",
    "selenoid/firefox:62.0"
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

  upload {
    content = "${file("browsers.json")}"
    file    = "/etc/selenoid/browsers.json"
  }
}
