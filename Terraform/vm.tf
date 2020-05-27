provider "ibm" {
  generation         = 1
  region             = "us-south"
}

data "ibm_resource_group" "group" {
  name = "${var.resource_group}"
}

resource "ibm_is_ssh_key" "sshkey" {
  name       = "keysshforwebsphere"
  public_key = "${var.ssh_public}"
}

resource "ibm_is_vpc" "vpcforwebsphere" {
  name = "vpcwebsphere"
  resource_group = "${data.ibm_resource_group.group.id}"
}

resource "ibm_is_subnet" "subnetwebsphere" {
  name            = "subnetwebsphere"
  vpc             = "${ibm_is_vpc.vpcforwebsphere.id}"
  zone            = "us-south-1"
  total_ipv4_address_count= "256"
}

resource "ibm_is_security_group" "securitygroupforwebsphere" {
  name = "securitygroupforwebsphere"
  vpc  = "${ibm_is_vpc.vpcforwebsphere.id}"
  resource_group = "${data.ibm_resource_group.group.id}"
}


resource "ibm_is_instance" "vsi1" {
  name    = "websphere-oracle"
  image   = "cc8debe0-1b30-6e37-2e13-744bfb2a0c11"
  profile = "b-2x8"
  resource_group = "${data.ibm_resource_group.group.id}"


  primary_network_interface {
    subnet = "${ibm_is_subnet.subnetwebsphere.id}"
    security_groups = ["${ibm_is_security_group.securitygroupforwebsphere.id}"]
  }

  vpc       = "${ibm_is_vpc.vpcforwebsphere.id}"
  zone      = "us-south-1"
  keys = ["${ibm_is_ssh_key.sshkey.id}"]
}

resource "ibm_is_security_group_rule" "testacc_security_group_rule_all" {
  group     = "${ibm_is_security_group.securitygroupforwebsphere.id}"
  direction = "inbound"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "testacc_security_group_rule_icmp" {
  group     = "${ibm_is_security_group.securitygroupforwebsphere.id}"
  direction = "inbound"
  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "testacc_security_group_rule_out" {
  group     = "${ibm_is_security_group.securitygroupforwebsphere.id}"
  direction = "outbound"
}

resource "ibm_is_floating_ip" "ipf1" {
  name   = "ipforwebsphere"
  target = "${ibm_is_instance.vsi1.primary_network_interface.0.id}"
  resource_group = "${data.ibm_resource_group.group.id}"
}

resource "ibm_container_vpc_cluster" "iks-websphere" {
  name              = "iks-websphere"
  vpc_id            = "${ibm_is_vpc.vpcforwebsphere.id}"
  flavor            = "c2.2x4"
  worker_count      = "1"
  resource_group_id = "${data.ibm_resource_group.group.id}"
  zones {
    subnet_id = "${ibm_is_subnet.subnetwebsphere.id}"
    name      = "${ibm_is_subnet.subnetwebsphere.zone}"
  }
}

output sshcommand {
  value = "ssh root@${ibm_is_floating_ip.ipf1.address}"
}
