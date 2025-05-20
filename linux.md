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
