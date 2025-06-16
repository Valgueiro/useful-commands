# Linux

## SSH

* Disable pasword auth - https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/
* Create a jump host - https://goteleport.com/blog/ssh-jump-server/
* Authorized keys and permissions - https://superuser.com/a/925859/1863774

### SUDO

* Sudo without password - https://askubuntu.com/a/147265/1098742

### Disable/enable GUI (UBUNTU)

Switch to "text mode" (you can simply run this in e.g. gnome-terminal):

```bash
sudo systemctl isolate multi-user.target
```
Switch to "graphical mode":

```bash
sudo systemctl isolate graphical.target
```

Set boot target
You can set the default target that is reached after boot (persists across reboot), e.g.:

```bash
sudo systemctl set-default multi-user.target
```
You can also set a target with the kernel parameter systemd.unit, e.g.

```yaml
systemd.unit=multi-user.target
```

The kernel parameter has precedence over the default target.

This can be used to boot to a specific target once by editing the grub boot entry before boot. Or you could add multiple boot entries for different targets.

Source: https://askubuntu.com/questions/1242965/how-to-enable-or-disable-gui-in-ubuntu

### Disable IPV6

Already had some problems when running in a VM inside VMWARE player Pro where it could not access anything when trying IPV6, Not sure why. But anyhow, just disable it:


I successfully disabled IPv6 once putting the following lines in /etc/sysctl.conf:

```conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

also run this command to load changes

```bash
sudo sysctl -p
```

source: https://askubuntu.com/questions/309461/how-to-disable-ipv6-permanently

### Troubleshooting 

![image](https://github.com/user-attachments/assets/e20de41f-0697-43bc-b4e5-d8b68db8cf4b)

