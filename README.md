the 6K minimalist way to manage an multi-app server 

> powered by ~800k of tiny, battlehardened unix classics (`find awk lsof readlink socat dirname find`)

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

# run all them user apps!

```
$ nohuppy start /home
```

# allow restart/stop for ssh-users:

```
$ ssh john@myserver
myserver $ nohuppy install
 [✓] install
+ sudo loginctl enable-linger john
[sudo] password for john: ******

myserver $ nohuppy restart
myserver $ exit           # app will now linger(*) after logout
```

> \* = `nohup` apps won't be killed after logout


# allow (limited) triggers from http!

in case your app has no http-features, now it has:

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

use-cases for `.on.http`:

* let CI/CD curl-cmd trigger a deployment: `git reset --hard && git pull origin master && nohuppy restart`
* run a backup thru scheduled CI/CD curl-cmd: `zip -ru /backup.zip /`
* any situation which doesn't require millions of requests

# why nohuppy

Because single-app-servers combined with moore's law (multi-core cpus) is a bit silly in some cases. 

# test

```
$ ./test/test.sh
```
