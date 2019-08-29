
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

# cyberdojo/saver docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Stores (key,value) data in a volume-mounted dir.

- - - -
API:
  * All methods receive a json hash.
    * The hash contains any method arguments as key-value pairs.
  * All methods return a json hash.
    * If the method completes, a key equals the method's name.
    * If the method raises an exception, a key equals "exception".

#
- [GET sha()](#get-sha)
- [GET ready?()](#get-ready)
- [GET exists?(key)](#get-existskey)
- [POST create(key)](#post-createkey)
- [POST write(key,value)](#post-writekeyvalue)
- [POST append(key,value)](#post-appendkeyvalue)
- [GET read(key)](#get-readkey)
- [GET read_batch(keys)](#get-read_batchkeys)
- [POST batch_until_false(commands)](#post-batch_until_falsecommands)
- [POST batch_until_true(commands)](#post-batch_until_truecommands)

- - - -
## GET sha()
Returns the git commit sha used to create the docker image.
- parameters, none
```json
  {}
```
- returns the sha, eg
```json
  { "sha": "8210a96a964d462aa396464814d9e82cad99badd" }
```

- - - -
## GET ready?()
- parameters, none
```json
  {}
```
- returns true if the service is ready, otherwise false, eg
```json
  { "ready?": true }
  { "ready?": false }
```

- - - -
## GET group_exists?(id)
Asks whether a group practice-session with the given **id** exists.
- parameter, eg
```json
  { "id": "55d3B9" }
```
- returns true if it does, false if it doesn't, eg
```json
  { "group_exists?": true   }
  { "group_exists?": false  }
```

- - - -
## POST group_create(manifest)
Creates a group practice-session from the given **manifest**.
- parameter, eg
```json
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
```json
  { "group_create": "55d3B9" }
```

- - - -
## GET group_manifest(id)
Returns the group manifest used to create the group practice-session with the given **id**.
- parameter, eg
```json
  { "id": "55d3B9" }
```
- returns, eg
```json
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
Join the group practice-session with the given group **id**.
The **indexes** parameter, when sorted, must be (0..63).to_a
and determines the avatar join attempt order.
- parameters, eg
```json
  { "id": "55d3B9",
    "indexes": [61, 8, 28, ..., 13, 32, 42]
  }
```
Returns null if the group is full, eg
```json
  { "group_join": null }
```
Returns the individual practice-session id if not full, eg
```json
  { "group_join": "D6a57F" }
```

- - - -
## GET group_joined(id)
Returns the individual practice-session ids of everyone
who has joined the group practice-session with the given **id**.
- parameter, eg
```json
  { "id": "55d3B9" }
```
- returns null if the id does not exist, eg
```json
  { "group_joined": null }
```
- returns the ids of the individual practice-sessions if it does, eg
```json
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
of everyone who has joined the group practice-session with the given **id**.
A BatchMethod designed for web's dashboard.
- parameter, eg
```json
  { "id": "55d3B9" }
```
- returns null if the id does not exist, eg
```json
  { "group_events": null }
```
- returns...
```json
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
Asks whether an individual practice-session with the given **id** exists.
- parameter, eg
```json
  { "id": "15B9aD" }
```
- returns true if it does, false if it doesn't, eg
```json
  { "kata_exist?": true   }
  { "kata_exist?": false  }
```

- - - -
## POST kata_create(manifest)
Creates an individual practice-session from the given **manifest**.
- parameter, eg
```json
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
- returns the id of the created individual practice-session, eg
```json
  { "kata_create": "a551C5" }
```

- - - -
## GET kata_manifest(id)
Returns the manifest used to create the individual practice-session with the given **id**.
- parameter, eg
```json
  { "id": "a551C5" }
```
- returns, eg
```json
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
In the individual practice-session with the given **id**,
the given **files** were submitted as the given **index** number,
at the given time **now**, which produced the given **stdout**, **stderr**, **status**,
with the given traffic-light **colour**.
- parameters, eg
```json
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
     "colour": "red"
  }
```
Returns nothing.

- - - -
## GET kata_events(id)
Returns details of all events, for the individual practice-session
with the given **id**.
- parameter, eg
```json
  { "id": "a551C5" }
```
- returns, eg
```json
  { "kata_events": [
      {  "event": "created", "time": [2016,12,5, 11,15,18,340] },
      { "colour": "red",     "time": [2016,12,6, 12,31,15,134] },
      { "colour": "green",   "time": [2016,12,6, 12,32,56,833] },
      { "colour": "amber",   "time": [2016,12,6, 12,43,19, 29] }
    ]
  }
```

- - - -
## GET kata_event(id,index)
Returns [files, stdout, stderr, status],
for the individual practice-session with the given **id**,
and the given event **index**.
- parameters, eg
```json
  {    "id": "a551C5",
    "index": 3
  }
```
- returns, eg
```json
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

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
