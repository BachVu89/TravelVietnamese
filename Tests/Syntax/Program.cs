using System;
using System.IO;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
int files=0,errors=0;
foreach(string file in Directory.EnumerateFiles(args[0],"*.cs",SearchOption.AllDirectories)){
    files++;
    var tree=CSharpSyntaxTree.ParseText(File.ReadAllText(file),new CSharpParseOptions(LanguageVersion.CSharp9),file);
    foreach(var diagnostic in tree.GetDiagnostics())if(diagnostic.Severity==DiagnosticSeverity.Error){errors++;Console.WriteLine(diagnostic);}
}
Console.WriteLine($"SYNTAX: {files} source files, {errors} parse errors. Roslyn parsing only, NOT Unity API/assembly compilation.");
return errors==0?0:1;
