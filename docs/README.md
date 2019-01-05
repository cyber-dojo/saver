
[![Build Status](https://travis-ci.org/cyber-dojo/saver.svg?branch=master)](https://travis-ci.org/cyber-dojo/saver)
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/saver docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Creates group and individual practice sessions.
- Stores the files, [stdout, stderr, status], and traffic-light of every test event.
- Stores data in a host dir volume-mounted to /cyber-dojo

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET ready?()](#get-ready)
- [GET sha()](#get-sha)
- [GET group_exists?(id)](#get-group_existsid)
- [POST group_create(manifest)](#post-group_createmanifest)
- [GET group_manifest(id)](#get-group_manifestid)
- [POST group_join(id,indexes)](#post-group_joinidindexes)
- [GET group_joined(id)](#get-group_joinedid)
- [GET group_events(id)](#get-group_eventsid)
- [GET kata_exists?(id)](#get-kata_existsid)
- [POST kata_create(manifest)](#post-kata_createmanifest)
- [GET kata_manifest(id)](#get-kata_manifestid)
- [POST kata_ran_tests(id,index,files,now,stdout,stderr,status,colour)](#post-kata_ran_testsidindexfilesnowstdoutstderrstatuscolour)
- [GET kata_events(id)](#get-kata_eventsid)
- [GET kata_event(id,index)](#get-kata_eventidindex)

- - - -

## GET ready?()
- parameters, none
```
  {}
```
- returns true if the service is ready, otherwise false.
```
  { "ready?": true }
  { "ready?": false }
```

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
Asks whether a group practice-session with the given id exists.
- parameter, eg
```
  { "id": "55d3B9" }
```
- returns true if it does, eg
```
  { "group_exists?": true   }
```
- returns false if it doesn't, eg
```
  { "group_exists?": false  }
```

- - - -

## POST group_create(manifest)
Creates a group practice-session from the given manifest.
- parameter, eg
```
    { "manifest": {
                   "created": [2017,12,15, 11,13,38,456],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
             "visible_files": {
                       "hiker.h": {
                         "content": "#ifndef HIKER_INCLUDED..."
                       },
                       "hiker.c": {
                         "content": "#include \"hiker.h\"..."
                       },
                 "hiker.tests.c": {
                         "content": "#include <assert.h>\n..."
                       },
                    "readme.txt": {
                         "content": "Write a program that..."
                       },
                      "makefile": {
                         "content": "CFLAGS += -I. -Wall..."
                      },
                 "cyber-dojo.sh": {
                         "content": "make"
                 }
            }
        }
    }
```
- returns the id of the created group practice-session, eg
```
  { "group_create": "55d3B9" }
```

- - - -

## GET group_manifest(id)
Returns the group manifest used to create the group practice-session with the given id.
- parameter, eg
```
  { "id": "55d3B9" }
```
- returns, eg
```
    { "group_manifest": {
                        "id": "55d3B9",
                   "created": [2017,12,15, 11,13,38,456],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
             "visible_files": {
                      "hiker.h": {
                        "content": "#ifndef HIKER_INCLUDED..."
                      },
                      "hiker.c": {
                        "content": "#include \"hiker.h\"..."
                      },
                "hiker.tests.c": {
                        "content": "#include <assert.h>\n..."
                      },
                   "readme.txt": {
                        "content": "Write a program that..."
                      },
                     "makefile": {
                        "content": "CFLAGS += -I. -Wall..."
                     },
                "cyber-dojo.sh": {
                        "content": "make"
                }
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
  { "id": "55d3B9",
    "indexes": [61, 8, 28, ..., 13, 32, 42]
  }
```
Returns null if the group is full, eg
```
  { "group_join": null }
```
Returns the individual practice-session id if not full, eg
```
  { "group_join": "D6a57F" }
```

- - - -

## GET group_joined(id)
Returns the individual practice-session ids of everyone
who has joined the group practice-session with the given id.
- parameter, eg
```
  { "id": "55d3B9" }
```
- returns null if the id does not exist, eg
```
  { "group_joined": null }
```
- returns the ids of the individual practice-sessions if it does, eg
```
{ "group_joined": [
     "D6a57F",
     "C4Ac8b",
     "454F91"
  ]
}
```

- - - -

## GET group_events(id)
Returns the index and events of all the individual practice-sessions
of everyone who has joined the group practice-session with the given id.
A BatchMethod designed for web's dashboard.
- parameter, eg
```
  { "id": "55d3B9" }
```
- returns null if the id does not exist, eg
```
  { "group_events": null }
```
- returns...
```
{ "group_events": {
    "D6a57F": {
      "index": 7,
      "events": [
        ...
      ]
    },
    "C4Ac8b": {
      "index": 34,
      "events": [
        ...
      ]
    },
    "454F91": {
      "index": 59,
      "events": [
        ...
      ]
    }
  }
}
```

- - - -

## GET kata_exists?(id)
Asks whether an individual practice-session with the given id exists.
- parameter, eg
```
  { "id": "15B9aD" }
```
- returns true if it does, eg
```
  { "kata_exist?": true   }
```
- returns false if it doesn't, eg
```
  { "kata_exist?": false  }
```

- - - -

## POST kata_create(manifest)
Creates an individual practice-session from the given manifest.
- parameter, eg
```
    { "manifest": {
                   "created": [2017,12,15, 11,13,38,456],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
                  "visible_files": {
                           "hiker.h": {
                             "content": "#ifndef HIKER_INCLUDED..."
                           },
                           "hiker.c": {
                             "content": "#include \"hiker.h\"..."
                           },
                     "hiker.tests.c": {
                             "content": "#include <assert.h>\n..."
                           },
                        "readme.txt": {
                             "content": "Write a program that..."
                           },
                          "makefile": {
                             "content": "CFLAGS += -I. -Wall..."
                          },
                     "cyber-dojo.sh": {
                             "content": "make"
                     }
                 }
    }
```
- returns the id of the created individual practice-session, eg
```
  { "kata_create": "a551C5" }
```

- - - -

## GET kata_manifest(id)
Returns the manifest used to create the individual practice-session with the given id.
- parameter, eg
```
  { "id": "a551C5" }
```
- returns, eg
```
    { "kata_manifest": {
                        "id": "a551C5",
                   "created": [2017,12,15, 11,13,38,456],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
             "visible_files": {
                       "hiker.h": {
                         "content": "#ifndef HIKER_INCLUDED..."
                       },
                       "hiker.c": {
                         "content": "#include \"hiker.h\"..."
                       },
                 "hiker.tests.c": {
                         "content": "#include <assert.h>\n..."
                       },
                    "readme.txt": {
                         "content": "Write a program that..."
                       },
                      "makefile": {
                         "content": "CFLAGS += -I. -Wall..."
                      },
                 "cyber-dojo.sh": {
                         "content": "make"
                 }
            }
        }
    }
```

- - - -

## POST kata_ran_tests(id,index,files,now,stdout,stderr,status,colour)
In the individual practice-session with the given id,
the given files were submitted as the given index number,
at the given time, which produced the given stdout, stderr, status,
with the given traffic-light colour.
- parameters, eg
```
  {      "id": "a551C5",
      "index": 3,
        "now": [2016,12,6, 12,31,15,823],      
      "files": {       
              "hiker.h": {
                "content": "ifndef HIKER_INCLUDED\n..."
              },
              "hiker.c": {
                "content": "#include \"hiker.h\"..."
              },
        "hiker.tests.c": {
                "content": "#include <assert.h>\n..."
        },
           "readme.txt": {
                "content": "Write a program that..."
           },
             "makefile": {
                "content": "CFLAGS += -I. -Wall..."
             },
        "cyber-dojo.sh": {
                "content": "make"
        }
     }
     "stdout": {
         "content": "",
       "truncated": false
     },
     "stderr": {
         "content": "Assert failed: answer() == 42",
       "truncated": false
     },
     "status": 23,
     "colour": "red"
  }
```
Returns nothing.

- - - -

## GET kata_events(id)
Returns details of all events, for the individual practice-session
with the given id.
- parameter, eg
```
  { "id": "a551C5" }
```
- returns, eg
```
  { "kata_events": [
      {  "event": "created", "time": [2016,12,5, 11,15,18,340] },
      { "colour": "red,      "time": [2016,12,6, 12,31,15,134] },
      { "colour": "green",   "time": [2016,12,6, 12,32,56,833] },
      { "colour": "amber",   "time": [2016,12,6, 12,43,19, 29] }
    ]
  }
```

- - - -

## GET kata_event(id,index)
Returns [files, stdout, stderr, status],
for the individual practice-session with the given id,
and the given event index.
- parameters, eg
```
  {    "id": "a551C5",
    "index": 3
  }
```
- returns, eg
```
  { "kata_event": {
      "files": {
              "hiker.h": {
                "content": "ifndef HIKER_INCLUDED\n..."
              },
              "hiker.c": {
                "content": "#include \"hiker.h\"..."
              },
        "hiker.tests.c": {
                "content": "#include <assert.h>..."
              },
           "readme.txt": {
                "content": "Write a program that..."
           },
             "makefile": {
                "content": "CFLAGS += -I. -Wall..."
             },
        "cyber-dojo.sh": {
                "content": "make"
              },
      },
      "stdout": {
          "content": "",
        "truncated": false
      },
      "stderr": {
          "content": "Assert failed: answer() == 42",
        "truncated": false
      },
      "status": 23,
    }
  }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
