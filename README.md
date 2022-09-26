Basically `nohuppy` around the `docker-compose` of the unix `nohup` & `kill` utility.

> powered by ~800k of classic, battlehardened unix dependencies (`find awk lsof readlink socat dirname find kill`)

It is slimmer than [pm.sh](https://github.com/coderofsalvation/pm.sh) and works without git/ssh (like [podi](https://github.com/coderofsalvation/podi))

# install on your server!

```
$ sudo su
# wget "https://raw.githubusercontent.com/coderofsalvation/nohuppy/main/nohuppy" > /usr/bin/nohuppy
# chmod 755 /usr/bin/nohuppy
# nohuppy
usage: 
    install                   allow process to keep running after logout 
    start [dir]               starts ./app.sh [recursive] in background
    stop [dir]                stops ./app.sh [recursive]
    restart                   runs stop & start
    ps                        lists running process(es) 
    logs                      show logs of ./app.sh
    http                      receive trigger from http
```

# create some apps!

```
$ echo 'pwd; sleep 1m' > /home/john/app1/app.sh
$ echo 'pwd; sleep 1m' > /home/john/app1/app2/app.sh
$ echo 'pwd; sleep 1m' > /home/sarah/app3/app.sh
```

> these could be git-repositories with an `app.sh` file as entry-point

# run all them user apps during boot!

/root/nohuppy_start.sh
```
for i in /home/*; do 
  user=$(basename $i)
  su $user -c 'nohuppy start /home/$user'
done
```

/lib/systemd/system/nohuppy.service 
```
[Unit]
Description=nohuppy apps 

[Service]
ExecStart=/root/nohuppy_start.sh

[Install]
WantedBy=multi-user.target
```

then enable it:
```
# systemctl daemon-reload 
# systemctl enable shellscript.service 
# systemctl start shellscript.service 
```

# enable control over ssh ('lingering'):

```
$ ssh john@myserver
myserver $ nohuppy install
 [✓] install
+ sudo loginctl enable-linger john
[sudo] password for john: ******

myserver $ nohuppy restart .     # restart all apps
myserver $ exit                  # apps will now linger(*) after logout
```

> \* = `nohup` apps won't be killed after logout

# allow (limited) triggers from http!

in case your app has zero http-features, now it has (using `socat`):

```
$ cd /home/john/app1
$ nohuppy http
 [✓] http
enter portnumber: 3889
  │  created '.port'
enter max parallel processes: 4
  │  created '.parallel'
  │  created '.on.http'
  │  listening on 3889 [max 4 processes]
  │  ./.on.http is triggered by: curl http://127.0.0.1:3889 --http0.9 
```

> now everytime `nohuppy start` is invoked, the `.on.http` will listen on your port

use-cases for `.on.http`:

* let CI/CD curl-cmd trigger a deployment: `git reset --hard && git pull origin master && nohuppy restart`
* run a backup thru scheduled CI/CD curl-cmd: `zip -ru /backup.zip /`
* any situation which doesn't require millions of requests

# why nohuppy

Because single-app-servers combined with moore's law (multi-core cpus) is a bit silly in some cases. 
This is a 'docker-compose' for nohup (which allows you to start all apps using 1 systemd/runit file).

# test

```
$ ./test/test.sh
```
