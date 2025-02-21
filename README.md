## Discourse Naver Login Auth 
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
- git clone https://github.com/centromics-forum/discourse-naver-auth.git
```

2. source

``` shell
$ cd $home/plugins
$ git clone https://github.com/centromics-forum/discourse-naver-auth.git
$ cd discourse-naver-auth
$ bundle install
```

## How to use



## Screenshots


## Read More



## License

GPLv2
