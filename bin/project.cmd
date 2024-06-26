::/*#! 2> /dev/null                                 #
@ 2>/dev/null # 2>nul & echo off & goto BOF         #
if [ -z ${SIREUM_HOME} ]; then                      #
  echo "Please set SIREUM_HOME env var"             #
  exit -1                                           #
fi                                                  #
exec ${SIREUM_HOME}/bin/sireum slang run "$0" "$@"  #
:BOF
setlocal
if not defined SIREUM_HOME (
  echo Please set SIREUM_HOME env var
  exit /B -1
)
%SIREUM_HOME%\bin\sireum.bat slang run "%0" %*
exit /B %errorlevel%
::!#*/
// #Sireum

import org.sireum._
import org.sireum.project.ProjectUtil._
import org.sireum.project.{Module, Project, PublishInfo, Target}

val homeDir = Os.slashDir.up.canon

val versions = Sireum.versions
val antlr4Version = versions.get("org.antlr:antlr4-runtime:").get
(homeDir / "versions.properties").writeOver(s"org.antlr%antlr4-runtime%=$antlr4Version")

val project = Project.empty + Module(
  id = "smtlib-parser",
  basePath = s"$homeDir",
  subPathOpt = Some("src"),
  deps = ISZ(),
  targets = ISZ(Target.Jvm),
  ivyDeps = ISZ("org.antlr:antlr4-runtime:"),
  sources = ISZ("."),
  resources = ISZ(),
  testSources = ISZ(),
  testResources = ISZ(),
  publishInfoOpt = Some(PublishInfo(
    description = "This package contains ANTLR v4 generated parser for SMT-LIB.",
    url = "https://github.com/sireum/smtlib-parser",
    licenses = ISZ(
      PublishInfo.License(
        name = "MIT",
        url = "https://github.com/julianthome/smtlibv2-grammar/blob/master/LICENCE.md",
        distribution = "repo"
      )
    ),
    developers = ISZ(
      robby
    )
  ))
)

projectCli(Os.cliArgs, project)
