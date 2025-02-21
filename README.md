## New Poll
correct answer, management function and provides main page summary link

## Installation

1. docker   
   edit container/app.yml
``` dockerfile
hooks:
after_code:
- exec:
  cd: $home/plugins
  cmd:
- rm -Rf poll
- git clone https://github.com/centromics-forum/discourse-poll.git
```

2. source

``` shell
$ cd $home/plugins
$ rm -Rf poll
$ git clone https://github.com/centromics-forum/discourse-poll.git
$ cd $home
$ bundle exec rake db:migrate
```

## How to use



## Screenshots


## Read More

## License

GPLv2
