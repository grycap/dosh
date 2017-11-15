# Scripts invoked on Docker calls
This is a folder that holds the scripts that are run when the docker calls are going to happen or have happened.


The distribution includes a file called ```/etc/dosh/scripts/template``` that you can use as a template to create your custom scripts. Some comments are included to explain when the scripts are called and the parameters that the script will receive in each case.

The content of the template is the next:

```bash
COMMAND=$1
CONTAINER=$2
shift
shift

case "$COMMAND" in
  prerun)
    # called before the container is created
    #  $@: the parameters to the docker run call that is being executed
    ;;
  run)
    # called after the container has been created
    #  $@: the parameters to the docker run call that has been executed
    ;;
  prestart) 
    # called before the container is started (if it was stopped)
    #  * no parameteres
    ;;
  start) 
    # called after the container has been started (if it was stopped)
    #  * no parameteres
    ;;
  preexec) 
    # called before the user gets the session in the container
    #  $1: the shell that is being used to run the container
    ;;
  exec) 
    # called after the user leaves the session in the container
    #  $1: the shell that has been used to run the container
    ;;
  *)
    echo "unexpected command" >&2
    ;;
esac
```

**NOTE:** please make sure that you set the +x permission to the scripts that you want to be invoked. If they do not have the +x permission, the scripts will not be executed. 

```bash
$ chmod +x 00addinterface
```