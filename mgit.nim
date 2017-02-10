##executes a git command line on ever git repo in the actual folder
##going one folder level down
##
## mgit status
## mgit push
## mgit remote add origin host:port/folder/$repo
import sets
import os
import strutils
import osproc

var orgCurrentDir = getCurrentDir()

proc buildIndex(pattern: string): HashSet[string] =
  ## walks the current dir, 
  ## collects and returns found repos matching the pattern
  result = initSet[string]()
  for path in walkPattern(pattern):  #getCurrentDir()):
    let pathBuf = joinPath(path , ".git")
    if existsDir( pathBuf ):
      result.incl(path )

proc dumpFundRepos(locations: HashSet[string]) =
  for each in locations:
    echo "R: ", each

proc dumpRepoHeadline(repo: string) = 
  echo "\n"
  echo '#'.repeat(80)
  echo $("  " & repo & "  ").center(80,'#')
  echo '#'.repeat(80)

proc writeHelp() = 
  echo """
    mgit filePattern command

    filepattern is like:
        *
        nim*
    
    command is like:
        status
        commit -m "wip $REPO"

    variables in command:
        $REPO points to the actual repository
        $TIMESTAMP gives an unix timestamp 
        ...
  """

when isMainModule:

  if paramCount() == 0: 
    writeHelp()
    quit()

  var locations = buildIndex(paramStr(1))
  if paramCount() == 1:
    dumpFundRepos(locations)  
    quit()

  for each in locations:
    setCurrentDir(orgCurrentDir)
    var quoted = each.replace(" ","\\ ") # TODO how fukd is windows??
    try:
        setCurrentDir(quoted)
    except:
        echo "Could not switch to dir: ", quoted
        discard readLine(stdin)
    dumpRepoHeadline(quoted)
    var cmdLine: seq[string] = @[]
    for each in 2..paramCount():
      cmdLine.add paramStr(each)

    discard execShellCmd( "git " & cmdLine.join(" ") )

  setCurrentDir(orgCurrentDir)


