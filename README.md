
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
- [POST create](#post-create)
- [GET manifest](#get-manifest)
- [GET id?](#get-id)
- [GET id_completed](#get-id_completed)
- [GET id_completions](#get-id_completions)
- [POST join](#post-join)
- [GET joined](#get-joined)

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

## POST create
Creates a practice-session from the given json manifest.
- parameter, eg
```
    { "manifest": {
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "visible_files": {        "hiker.h": "#ifndef HIKER_INCLUDED...",
                                       "hiker.c": "#include \"hiker.h\"...",
                                "hiker.tests.c" : "#include <assert.h>\n...",
                                 "instructions" : "Write a program that...",
                                     "makefile" : "CFLAGS += -I. -Wall...",
                                "cyber-dojo.sh" : "make"
                              },
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
      }
    }
```
- returns the id of the practice session created from the given manifest, eg
```
  { "create": "55D3B97CF7"
  }
```

- - - -

## GET manifest
Returns the manifest used to create the practice-session with the given id.
- parameter, eg
```
  { "id": "55D3B97CF7" }
```
- returns, eg
```
    { "manifest": {
                        "id": "55D3B97CF7",
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "visible_files": {       "hiker.h" : "ifndef HIKER_INCLUDED\n...",
                                      "hiker.c" : "#include \"hiker.h\"...",
                                "hiker.tests.c" : "#include <assert.h>\n...",
                                 "instructions" : "Write a program that...",
                                     "makefile" : "CFLAGS += -I. -Wall...",
                                "cyber-dojo.sh" : "make"
                              },
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4
      }
    }
```

- - - -

## GET id?
Asks whether the practice-session with the given id exists.
- parameters, eg
```
  { "id": "55D3B97CF7" }
```
- returns true if it does, false if it doesn't, eg
```
  { "id?": true   }
  { "id?": false  }
```

- - - -

## GET id_completed
If it exists, returns the 10-digit practice-session id which uniquely
completes the given partial_id, otherwise returns the empty string.
- parameter, the partial-id to complete, eg
```
  { "partial_id": "55D3B9" } # must be at least 6 characters long.
```
- returns, eg
```
  { "id_completed": "55D3B97CF7"  } # completed
  { "id_completed": ""            } # not completed
```

- - - -

## GET id_completions
Returns all the practice-session id's starting with the given outer_id.
- parameter, eg
```
  { "outer_id": "55" } # must be 2 characters long
```
- returns, eg
```
  { "id_completions": [
       "55D3B97CF7",
       "55D3B97CF8",
       "55D3B97CF9"
    ]
  }
```

- - - -

## POST join
Join the practice-session with the given id.
- parameters, eg
```
  { "id": "55D3B97CF7" }
```
Returns the avatar name and its individual practice-session id, eg
```
  { "join": {
       "avatar": "lion",
           "id": "D6A57FC1A5"
     }
  }
```

- - - -

## GET joined
Returns the names and ids of everyone who has joined the practice-session
with the given id.
- parameters, eg
```
  { "id": "55D3B97CF7" }
```
- returns, eg
```
  { "joined": {
       "lion": "D6A57FC1A5",
      "tiger": "C4AC8BF502",
       "swan": "454F917286"
    }
  }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

