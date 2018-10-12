
[![Build Status](https://travis-ci.org/cyber-dojo/grouper.svg?branch=master)](https://travis-ci.org/cyber-dojo/grouper)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/grouper docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Creates group practice sessions.
- Work in progress - not yet used

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET sha](#get-sha)
- [GET group_exists?](#get-group_exists)
- [POST group_create](#post-group_create)
- [GET group_manifest](#get-group_manifest)
- [POST group_join](#post-group_join)
- [GET group_joined](#get-group_joined)

- - - -

## GET sha
Returns the git commit sha used to create the docker image.
- parameters, none
```
  {}
```
- returns the sha, eg
```
  { "sha": "8210a96a964d462aa396464814d9e82cad99badd" }
```

- - - -

## POST group_create
Creates a practice-session from the given manifest
and given files.
- parameters, eg
```
    { "manifest": {
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
             "visible_files": {
               "hiker.h": "#ifndef HIKER_INCLUDED...",
               "hiker.c": "#include \"hiker.h\"...",
        "hiker.tests.c" : "#include <assert.h>\n...",
         "instructions" : "Write a program that...",
             "makefile" : "CFLAGS += -I. -Wall...",
        "cyber-dojo.sh" : "make"
        }
      }
    }
```
- returns the id of the created group practice-session, eg
```
  { "group_create": "55D3B9"
  }
```

- - - -

## GET group_manifest
Returns the manifest used to create the practice-session with the given group id.
- parameter, eg
```
  { "id": "55D3B9" }
```
- returns, eg
```
    { "group_manifest": {
                        "id": "55D3B9",
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
             "visible_files": {
               "hiker.h": "#ifndef HIKER_INCLUDED...",
               "hiker.c": "#include \"hiker.h\"...",
        "hiker.tests.c" : "#include <assert.h>\n...",
         "instructions" : "Write a program that...",
             "makefile" : "CFLAGS += -I. -Wall...",
        "cyber-dojo.sh" : "make"
        }
      }
    }
```

- - - -

## GET group_exists?
Asks whether the practice-session with the given id exists.
- parameters, eg
```
  { "id": "55D3B9" }
```
- returns true if it does, false if it doesn't, eg
```
  { "group_exists?": true   }
  { "group_exists?": false  }
```

- - - -

## POST group_join
Join the practice-session with the given group id.
The indexes parameter, when sorted, must be (0..63).to_a
and determines the join attempt order.
- parameters, eg
```
  { "id": "55D3B9",
    "indexes": [61, 8, 28, ..., 13, 32, 42]
  }
```
Returns the individual practice-session avatar-index and id, eg
```
  { "group_join": [ 6, "D6A57F" ] }
```

- - - -

## GET group_joined
Returns the individual practice-session avatar-index and id of everyone
who has joined the practice-session with the given group id.
- parameters, eg
```
  { "id": "55D3B9" }
```
- returns, eg
```
  { "group_joined": {
       "6": "D6A57F",
      "34": "C4AC8B",
      "11": "454F91"
    }
  }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

