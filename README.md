# nimMultiGit
bulk execute your git commands



    mgit filePattern command
    filepattern is like:
        *
        nim*
    
    command is like:
        status
        commit -m "wip $REPO"
    variables in command:
        $REPO points to the actual repository name (withouth path)
        $TIMESTAMP gives an unix timestamp 
        ...
