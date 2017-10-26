#!/usr/bin/python
import subprocess, re
services = re.findall("\(\d+?\) (.+?)\n\(Hardware Port: (.+?), Device: (.+?)\)\n",
  subprocess.check_output(["/usr/sbin/networksetup", "-listnetworkserviceorder"]))
for service in services:
  if service[1] == "Wi-Fi":
    subprocess.check_output(["/usr/sbin/networksetup", "-setairportpower", service[2], "off"])
  else:
    subprocess.check_output(["/usr/sbin/networksetup", "-setnetworkserviceenabled", service[0], "off"])
