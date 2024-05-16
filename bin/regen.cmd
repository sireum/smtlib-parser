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

val home: Os.Path = Os.slashDir.up.canon
val sireum: Os.Path = Os.path(Os.env("SIREUM_HOME").get) / "bin" / (if (Os.isWin) "sireum.bat" else "sireum")
val versions = home / "versions.properties"

val antlr4Version: String =
  if (versions.exists) versions.properties.get("org.antlr%antlr4-runtime%").get
  else Sireum.versions.get("org.antlr:antlr4-runtime:").get

def regenSysML(): Unit = {
  val outDir = home / "src" / "org" / "sireum" / "smtlib" / "parser"
  outDir.removeAll()
  outDir.mkdirAll()
  (outDir / "SMTLIBv2.g4").downloadFrom("https://raw.githubusercontent.com/julianthome/smtlibv2-grammar/master/src/main/resources/SMTLIBv2.g4")
  val deps = Coursier.fetch(Sireum.scalaVer, ISZ(s"org.antlr:antlr4:$antlr4Version"))
  val classpath: ISZ[String] = for (dep <- deps) yield dep.path.string
  val java = Os.path(Sireum.javaHomePathString) / "bin" / (if (Os.isWin) "java.exe" else "java")
  Os.proc(ISZ(java.string, "-cp", st"${(classpath, Os.pathSep)}".render, "org.antlr.v4.Tool", "-o",
    outDir.string, "-Xexact-output-dir", "-package", "org.sireum.smtlib.parser", (outDir / "SMTLIBv2.g4").string)).console.runCheck()
  println("Regenerated lexer/parser")
}

regenSysML()
