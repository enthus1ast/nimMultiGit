##executes a git command line on every git repo in the current folder
##going one folder level down
##
## mgit nim* status
## mgit nim* push
## mgit nim* remote add origin host:port/folder/$REPO
import sets
import os
import strutils
import osproc
import strtabs
import times

var context = newStringTable()
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
        $REPO points to the actual repository name (withouth path)
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
    context["$REPO"] = each
    context["$TIMESTAMP"] = $(epochTime().int)
    setCurrentDir(orgCurrentDir)
    var quoted = each.replace(" ","\\ ") # TODO how fukd is windows??
    try:
        setCurrentDir(quoted)
    except:
        echo "Could not switch to dir: ", quoted
        echo "[Press any key to continue]"
        discard readLine(stdin)
    dumpRepoHeadline(quoted)
    var cmdLine: seq[string] = @[]
    for each in 2..paramCount():
      if paramStr(each).contains(" "):
        cmdLine.add "\"" & paramStr(each) & "\""
      else:  
        cmdLine.add paramStr(each)
    
    var cmdLineStr = cmdLine.join(" ")
    for k,v in context:
      cmdLineStr = cmdLineStr.replace(k,v)
    echo cmdLineStr
    discard execShellCmd( "git " & cmdLineStr )

  setCurrentDir(orgCurrentDir)


