
[![Build Status](https://travis-ci.org/cyber-dojo/saver.svg?branch=master)](https://travis-ci.org/cyber-dojo/saver)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/saver docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Creates group and individual practice sessions.
- Stores the files, [stdout, stderr, status], and traffic-light of every test event.
- Work in progress - not yet used

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET sha()](#get-sha)
- [GET group_exists?(id)](#get-group_existsid)
- [POST group_create(manifest)](#post-group_createmanifest)
- [GET group_manifest(id)](#get-group_manifestid)
- [POST group_join(id,indexes)](#post-group_joinidindexes)
- [GET group_joined(id)](#get-group_joinedid)
- [GET kata_exists?(id)](#get-kata_existsid)
- [POST kata_create(manifest)](#post-kata_createmanifest)
- [GET kata_manifest(id)](#get-kata_manifestid)
- [POST kata_ran_tests(id,n,files,now,stdout,stderr,status,colour)](#post-kata_ran_testsidnfilesnowstdoutstderrstatuscolour)
- [GET kata_tags(id)](#get-kata_tagsid)
- [GET kata_tag(id,n)](#get-kata_tagidn)

- - - -

## GET sha()
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

## GET group_exists?(id)
Asks whether the group practice-session with the given id exists.
- parameter, eg
```
  { "id": "55D3B9" }
```
- returns true if it does, false if it doesn't, eg
```
  { "group_exists?": true   }
  { "group_exists?": false  }
```

- - - -

## POST group_create(manifest)
Creates a group practice-session from the given manifest.
- parameter, eg
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
  { "group_create": "55D3B9" }
```

- - - -

## GET group_manifest(id)
Returns the group manifest used to create the group practice-session with the given id.
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

## POST group_join(id,indexes)
Join the group practice-session with the given group id.
The indexes parameter, when sorted, must be (0..63).to_a
and determines the avatar join attempt order.
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

## GET group_joined(id)
Returns the individual practice-session avatar-index and id of everyone
who has joined the group practice-session with the given id.
- parameter, eg
```
  { "id": "55D3B9" }
```
- returns null if the id does not exist, or the index:id of the
individual practice-sessions if it does. eg
```
  { "group_joined": null }
  { "group_joined": {
       "6": "D6A57F",
      "34": "C4AC8B",
      "11": "454F91"
    }
  }
```

- - - -

## GET kata_exists?(id)
Asks whether the individual practice-session with the given id exists.
- parameter, eg
```
  { "id": "15B9AD" }
```
- returns true if it does, false if it doesn't, eg
```
  { "kata_exist?": true   }
  { "kata_exist?": false  }
```

- - - -

## POST kata_create(manifest)
Creates an individual practice-session from the given manifest.
- parameter, eg
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
```
- returns the id of the created individual practice-session, eg
```
  { "kata_create": "A551C5" }
```

- - - -

## GET kata_manifest(id)
Returns the manifest used to create the individual practice-session with the given id.
- parameter, eg
```
  { "id": "A551C5" }
```
- returns, eg
```
    { "kata_manifest": {
                        "id": "A551C5",
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

## POST kata_ran_tests(id,n,files,now,stdout,stderr,status,colour)
In the individual practice-session with the given id,
the given files were submitted as tag number n,
at the given time, which produced the given stdout, stderr, status,
with the given traffic-light colour.
- parameters, eg
```
  {      "id": "A551C5",
          "n": 3,
      "files": {       "hiker.h" : "ifndef HIKER_INCLUDED\n...",
                       "hiker.c" : "#include \"hiker.h\"...",
                 "hiker.tests.c" : "#include <assert.h>\n...",
                  "instructions" : "Write a program that...",
                      "makefile" : "CFLAGS += -I. -Wall...",
                 "cyber-dojo.sh" : "make"
               }
        "now": [2016,12,6, 12,31,15],
     "stdout": "",
     "stderr": "Assert failed: answer() == 42",
     "status": 23,
     "colour": "red"
  }
```
Returns tags, eg
```
  { "kata_ran_tests": [
      {  "event": "created", "time": [2016,12,5, 11,15,18], "number": 0 },
      { "colour": "red,      "time": [2016,12,6, 12,31,15], "number": 1 }
    ]
  }
```

- - - -

## GET kata_tags(id)
Returns details of all traffic-lights, for the individual practice-session
with the given id.
- parameter, eg
```
  { "id": "A551C5" }
```
- returns, eg
```
  { "kata_tags": [
      {  "event": "created", "time": [2016,12,5, 11,15,18], "number": 0 },
      { "colour": "red,      "time": [2016,12,6, 12,31,15], "number": 1 },
      { "colour": "green",   "time": [2016,12,6, 12,32,56], "number": 2 },
      { "colour": "amber",   "time": [2016,12,6, 12,43,19], "number": 3 }
    ]
  }
```

- - - -

## GET kata_tag(id,n)
Returns the files, stdout, stderr, status,
for the individual practice-session with the given id,
and the given tag number n.
- parameters, eg
```
  { "id": "A551C5",
     "n": 3
  }
```
- returns, eg
```
  { "kata_tag": {
           "files": {
              "hiker.h" : "ifndef HIKER_INCLUDED\n...",
              "hiker.c" : "#include \"hiker.h\"...",
        "hiker.tests.c" : "#include <assert.h>...",
         "instructions" : "Write a program that...",
             "makefile" : "CFLAGS += -I. -Wall...",
        "cyber-dojo.sh" : "make"
      },
      "stdout": "",
      "stderr": "Assert failed: answer() == 42",
      "status": 23,
    }
  }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
